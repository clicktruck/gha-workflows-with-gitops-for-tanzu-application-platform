#@ load("@ytt:data", "data")
---
apiVersion: kappctrl.k14s.io/v1alpha1
kind: App
metadata:
  name: spring-cloud-gateway
  namespace: spring-cloud-gateway
  annotations:
    kapp.k14s.io/change-group: scg-install-gitops/app
spec:
  serviceAccountName: scg-install-gitops-sa
  fetch:
  - git:
      url: https://github.com/clicktruck/gha-workflows-with-gitops-for-tanzu-application-platform
      ref: origin/{{ .git_ref_name }}
      secretRef:
        name: git-https-for-carvel
  template:
  - ytt:
      paths:
      - gitops/tanzu/spring-cloud-gateway/base

      valuesFrom:
      - secretRef:
          name: spring-cloud-gateway-values
  deploy:
  - kapp: {}
---
