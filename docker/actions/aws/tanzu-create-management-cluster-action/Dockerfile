FROM alpine:3

LABEL "com.github.actions.name"="tanzu-runsh-setup-action"
LABEL "com.github.actions.icon"="server"
LABEL "com.github.actions.color"="blue"

LABEL "repository"="https://github.com/clicktruck/gha-workflows-with-gitops-for-tanzu-application-platform/docker/actions/aws/tanzu-runsh-setup-action"
LABEL "maintainer"="Chris Phillipson <cphillipson@vmware.com>"

ENV HELM_VERSION=3.13.1 \
    IMGPKG_VERSION=0.39.0 \
    KAPP_VERSION=0.59.1 \
    KBLD_VERSION=0.38.1 \
    KCTRL_VERSION=0.48.2 \
    KUBECTL_VERSION=1.26.10 \
    MKPCLI_VERSION=0.15.0 \
    VENDIR_VERSION=0.35.0 \
    YQ_VERSION=4.35.1 \
    YTT_VERSION=0.46.0

RUN apk add --update --no-cache bash coreutils ca-certificates curl docker gcompat jq openrc python3 py3-pip wget \
    && rc-update add docker boot \
    && pip3 install --upgrade pip \
    && pip3 install awscli \
    && curl -s -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && wget -O imgpkg https://github.com/vmware-tanzu/carvel-imgpkg/releases/download/v${IMGPKG_VERSION}/imgpkg-linux-amd64 \
    && chmod +x imgpkg \
    && mv imgpkg /usr/local/bin \
    && wget -O ytt https://github.com/vmware-tanzu/carvel-ytt/releases/download/v${YTT_VERSION}/ytt-linux-amd64 \
    && chmod +x ytt \
    && mv ytt /usr/local/bin \
    && wget -O vendir https://github.com/vmware-tanzu/carvel-vendir/releases/download/v${VENDIR_VERSION}/vendir-linux-amd64 \
    && chmod +x vendir \
    && mv vendir /usr/local/bin \
    && wget -O kapp https://github.com/vmware-tanzu/carvel-kapp/releases/download/v${KAPP_VERSION}/kapp-linux-amd64 \
    && chmod +x kapp \
    && mv kapp /usr/local/bin \
    && wget -O kbld https://github.com/vmware-tanzu/carvel-kbld/releases/download/v${KBLD_VERSION}/kbld-linux-amd64 \
    && chmod +x kbld \
    && mv kbld /usr/local/bin \
    && wget -O kctrl https://github.com/vmware-tanzu/carvel-kapp-controller/releases/download/v${KCTRL_VERSION}/kctrl-linux-amd64 \
    && chmod +x kctrl \
    && mv kctrl /usr/local/bin \
    && curl -LO "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" \
    && tar -xvf helm-v${HELM_VERSION}-linux-amd64.tar.gz \
    && mv linux-amd64/helm /usr/local/bin \
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
