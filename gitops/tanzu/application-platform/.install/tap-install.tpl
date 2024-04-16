apiVersion: kappctrl.k14s.io/v1alpha1
kind: App
metadata:
  name: {{ .app_name }}
  namespace: tap-install-gitops
  annotations:
    kapp.k14s.io/change-group: tap-install-gitops/app
    kapp.k14s.io/change-rule.1: "upsert after upserting tap-install-gitops/rbac"
spec:
  serviceAccountName: tap-install-gitops-sa
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
      - gitops/tanzu/application-platform/base
      - gitops/tanzu/application-platform/profiles/base/{{ .profile }}

      valuesFrom:
      - configMapRef:
          name: {{ .app_name }}
      - secretRef:
          name: {{ .app_name }}
      - secretRef:
          name: metadata-store-token
  deploy:
  - kapp: {}
