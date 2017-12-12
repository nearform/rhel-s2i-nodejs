#!/bin/bash
#
# this script pulls the Image Id from the redhat catalog and the uses
# the connect api to 'publish' the image
#
if ! hash jq; then
  apt-get update
  apt-get install jq -y
fi
: ${RH_PID:=p936591153adf2db17145e97afc3511f2549b5dfa3}
echo "Project ID: ${RH_PID}"

if [ -z "$RH_SECRET" ]; then
  echo "RH_SECRET not found in Environment, exiting..."
  exit 1
else
  echo "RH_SECRET found in Environment, moving on..."
fi

echo "Getting docker image id from Red Hat Catalog Api."
IMAGE_ID=$(curl -s https://www.redhat.com/wapps/containercatalog/rest/v1/repository/registry.connect.redhat.com/nearform%252Frhel7-s2i-nodejs/images \
  | jq -r '.processed[0].images[0].docker_image_id')
echo "Image ID: ${IMAGE_ID}"

echo "Calling the Red Hat Connect API to publish the Image."
curl -X POST \
  -H "Content-Type: application/json" \
  -d "{\"pid\":\"${RH_PID}\", \"docker_image_digest\":\"${IMAGE_ID}\", \"secret\":\"${RH_SECRET}\"}" \
  https://connect.redhat.com/api/container/publish