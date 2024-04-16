apiVersion: kappctrl.k14s.io/v1alpha1
kind: App
metadata:
  name: {{ .app_name }}
  namespace: tas-adapter-install-gitops
  annotations:
    kapp.k14s.io/change-group: tas-adapter-install-gitops/app
    kapp.k14s.io/change-rule.1: "upsert after upserting tas-adapter-install-gitops/rbac"
spec:
  serviceAccountName: tas-adapter-install-gitops-sa
  syncPeriod: 1m
  fetch:
  - git:
      url: https://github.com/clicktruck/gha-workflows-with-gitops-for-tanzu-application-platform
      ref: origin/{{ .git_ref_name }}
      secretRef:
        name: git-https-for-carvel
  template:
  - ytt:
      paths:
      - gitops/tanzu/application-service-adapter/base

      valuesFrom:
      - configMapRef:
          name: {{ .app_name }}
      - secretRef:
          name: {{ .app_name }}
  deploy:
  - kapp: {}
