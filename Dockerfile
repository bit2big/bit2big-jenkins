# Dockerfile
FROM jenkins/jenkins:alpine

LABEL maintainer="Michael Kiberu <mail@kipya.com>"

# Preinstall necessary plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Copy init scripts
COPY scripts/init.groovy.d /usr/share/jenkins/ref/init.groovy.d

# Copy configuration as code files
COPY jenkins/casc.yaml /usr/share/jenkins/ref/casc.yaml

# Setting environment variables
ENV CASC_JENKINS_CONFIG=/usr/share/jenkins/ref/casc.yaml


USER root
RUN apk add --no-cache sudo
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers
USER jenkins