FROM=registry.access.redhat.com/rhscl/s2i-base-rhel7
IMAGE_NAME=nearform/redhat7-s2i-nodejs

SLASH := /
DASH := -


# These values are changed in each version branch
# This is the only place they need to be changed
# other than the README.md file.
include versions.mk

TARGET=$(IMAGE_NAME):$(IMAGE_TAG)
ARCHIVE=sources-$(subst $(SLASH),$(DASH),$(TARGET)).tgz

.PHONY: all
all: build squash test

.PHONY: build
build:
	./contrib/etc/get_node_source.sh "${NODE_VERSION}" $(PWD)/src/
	docker build \
	--build-arg NODE_VERSION=$(NODE_VERSION) \
	--build-arg NPM_VERSION=$(NPM_VERSION) \
	--build-arg V8_VERSION=$(V8_VERSION) \
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
ifdef DEBUG_BUILD
undefine MAJOR_TAG
undefine MINOR_TAG
undefine LTS_TAG
endif
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
