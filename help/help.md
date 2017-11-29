% rhel7-nodejs
% nearForm Developer Support
% __DATE__

# DESCRIPTION
This is a S2I nodejs-4 rhel base image:
To use it, install S2I: https://github.com/openshift/source-to-image

# USAGE
s2i build https://github.com/sclorg/s2i-nodejs-container.git --context-dir=6/test/test-app/ /rhel7-nodejs-6 nodejs-sample-app

You can then run the resulting image via:
docker run -p 8080:8080 nodejs-sample-app

# LABELS
This image is not intended to be used without some source code. See #usage

# SECURITY IMPLICATIONS
No ports are opened by default

# HISTORY
2017-11-29 - Initial version
