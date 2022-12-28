FROM ubuntu:20.04

LABEL "repository"="https://github.com/pacphi/gha-workflows-with-gitops-for-tanzu-application-platform/docker/toolset-image"
LABEL "maintainer"="Chris Phillipson <cphillipson@vmware.com>"

COPY scripts scripts

RUN chmod +x scripts/*.sh \
      && chmod +x scripts/aws/*.sh \
      && chmod +x scripts/azure/*.sh \
      && ./scripts/init.sh
