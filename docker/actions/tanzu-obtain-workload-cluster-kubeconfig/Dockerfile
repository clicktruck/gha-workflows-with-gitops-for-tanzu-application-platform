FROM alpine:3

LABEL "com.github.actions.name"="tanzu-runsh-setup-action"
LABEL "com.github.actions.icon"="server"
LABEL "com.github.actions.color"="blue"

LABEL "repository"="https://github.com/pacphi/gha-workflows-with-gitops-for-tanzu-application-platform/docker/actions/tanzu-obtain-workload-cluster-kubeconfig"
LABEL "maintainer"="Chris Phillipson <cphillipson@vmware.com>"

ENV KUBECTL_VERSION=1.26.6 \
    MKPCLI_VERSION=0.15.0 \
     YQ_VERSION=4.34.2

RUN apk add --update --no-cache bash coreutils ca-certificates curl docker gcompat jq openrc wget \
    && rc-update add docker boot \
    && curl -s -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && curl -LO https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64 \
    && chmod +x yq_linux_amd64 \
    && mv yq_linux_amd64 /usr/local/bin/yq \
    && curl -LO https://github.com/vmware-labs/marketplace-cli/releases/download/v${MKPCLI_VERSION}/mkpcli-linux-amd64.tgz \
    && tar -xvf mkpcli-linux-amd64.tgz \
    && chmod +x mkpcli \
    && mv mkpcli /usr/local/bin \
    && rm -rf /var/cache/apk/*

# Copies scripts from action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
