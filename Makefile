FROM=registry.access.redhat.com/rhscl/s2i-base-rhel7

SLASH := /
DASH := -
DOT := .
COLON := :

PREBUILT := N

# These values are changed in each version branch
# This is the only place they need to be changed
# other than the README.md file.
include versions.mk

IMG_STRING=$(shell echo $(IMAGE_NAME) | cut -d'/' -f2)
RH_TARGET=registry.rhc4tp.openshift.com:443/$(RH_PID)/$(IMG_STRING):$(IMAGE_TAG)
TARGET=$(IMAGE_NAME):$(IMAGE_TAG)
ARCHIVE_NAME=$(IMAGE_NAME)-$(IMAGE_TAG)
ARCHIVE=sources-$(subst $(SLASH),$(DASH),$(ARCHIVE_NAME)).tgz

envinfo:
	@echo $(call .FEATURES)
	@env
.PHONY: all
all: build squash test

.PHONY: build
build:
	PREBUILT=$(PREBUILT) ./contrib/etc/get_node_source.sh "${NODE_VERSION}" $(PWD)/src/
	docker build \
	--build-arg NODE_VERSION=$(NODE_VERSION) \
	--build-arg NPM_VERSION=$(NPM_VERSION) \
	--build-arg V8_VERSION=$(V8_VERSION) \
	--build-arg PREBUILT=$(PREBUILT) \
	-t $(TARGET) .

.PHONY: squash
squash:
	docker-squash -f $(FROM) $(TARGET) -t $(TARGET)

.PHONY: test
test:
	 BUILDER=$(TARGET) NODE_VERSION=$(NODE_VERSION) ./test/run.sh

.PHONY: clean
clean:
	docker rmi `docker images $(TARGET) -q`

.PHONY: tag
tag:
	if [ ! -z $(LTS_TAG) ]; then docker tag $(TARGET) $(IMAGE_NAME):$(LTS_TAG); fi

.PHONY: publish
publish:
	@echo $(DOCKER_PASS) | docker login --username $(DOCKER_USER) --password-stdin
	docker push $(TARGET)
ifndef DEBUG_BUILD
ifdef MAJOR_TAG
	docker tag $(TARGET) $(IMAGE_NAME):$(MAJOR_TAG)
	docker push $(IMAGE_NAME):$(MAJOR_TAG)
endif
ifdef MINOR_TAG
	docker tag $(TARGET) $(IMAGE_NAME):$(MINOR_TAG)
	docker push $(IMAGE_NAME):$(MINOR_TAG)
endif
ifdef LTS_TAG
	docker tag $(TARGET) $(IMAGE_NAME):$(LTS_TAG)
	docker push $(IMAGE_NAME):$(LTS_TAG)
endif
endif


.PHONY: redhat_publish
redhat_publish:
	echo "Publishing to RedHat repository"
ifndef DEBUG_BUILD
	RH_TARGET="registry.rhc4tp.openshift.com:443/p936591153adf2db17145e97afc3511f2549b5dfa3/redhat7-s2i-nodejs:$(TAG)"
	docker tag nearform/rhel7-s2i-nodejs:$(TAG) $(RH_TARGET)
	PUSH_OUTPUT=$(shell docker push $(RH_TARGET))
	IMAGE_ID=$(shell echo ${PUSH_OUTPUT} | grep sha | cut -d' ' -f3)
	curl -X POST \
		-H "Content-Type: application/json" \
		-d "{\"pid\":\"$(RH_PID)\", \"docker_image_digest\":\"$(IMAGE_ID)\", \"secret\":\"$(RH_SECRET)\"}" \
		https://connect.redhat.com/api/container/publish
endif

.PHONY: archive
archive:
	mkdir -p dist
	git archive --prefix=build-tools/ --format=tar HEAD | gzip >dist/build-tools.tgz
	cp -v versions.mk dist/versions.mk
	git rev-parse HEAD >dist/build-tools.revision
	cp -v src/* dist/
	shasum dist/* >checksum
	cp -v checksum dist/dist.checksum
	tar czvf $(ARCHIVE) dist/*


.PHONY: upload
upload:
	echo "Attempting Upload of sources to S3 bucket $(S3BUCKET)"
	s3cmd put $(ARCHIVE) "$(S3BUCKET)"
