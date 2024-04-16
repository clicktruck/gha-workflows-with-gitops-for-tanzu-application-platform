apiVersion: kappctrl.k14s.io/v1alpha1
kind: App
metadata:
  name: tanzu-standard
  namespace: tanzu-package-repo-global
  annotations:
    kapp.k14s.io/change-rule.create-order: "upsert after upserting tanzu-standard/rbac"
    kapp.k14s.io/change-rule.delete-order: "delete before deleting tanzu-standard/rbac"
spec:
  serviceAccountName: tanzu-standard-sa
  fetch:
  - git:
      url: https://github.com/clicktruck/gha-workflows-with-gitops-for-tanzu-application-platform
      ref: origin/{{ .git_ref_name }}
      secretRef:
        name: git-https-for-carvel
  template:
  - ytt:
      paths:
      - gitops/tanzu/standard/base

      valuesFrom:
      - configMapRef:
          name: tanzu-standard
      - secretRef:
          name: tanzu-standard
  deploy:
  - kapp: {}
