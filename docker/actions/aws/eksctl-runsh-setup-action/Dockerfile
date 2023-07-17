FROM alpine:3

LABEL "com.github.actions.name"="eksctl-runsh-setup-action"
LABEL "com.github.actions.description"="Execute a shell script where eksctl CLI commands may be invoked one or more times"
LABEL "com.github.actions.icon"="server"
LABEL "com.github.actions.color"="blue"

LABEL "repository"="https://github.com/pacphi/gha-workflows-with-gitops-for-tanzu-application-platform/docker/actions/aws/eksctl-runsh-setup-action"
LABEL "maintainer"="Chris Phillipson <cphillipson@vmware.com>"

RUN apk add --update --no-cache bash coreutils ca-certificates curl gcompat \
    && curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp \
    && mv /tmp/eksctl /usr/local/bin

# Copies scripts from action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]