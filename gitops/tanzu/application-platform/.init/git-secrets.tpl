apiVersion: v1
kind: Secret
metadata:
  name: git-https-for-carvel
  namespace: tap-install-gitops
  annotations:
    kapp.k14s.io/change-group: tap-install-gitops/rbac
    kapp.k14s.io/change-rule: "delete after deleting tap-install-gitops/app"
type: kubernetes.io/basic-auth
stringData:
  username: {{ .git_username }}
  password: {{ .git_personal_access_token }}
---
apiVersion: secretgen.carvel.dev/v1alpha1
kind: SecretExport
metadata:
  name: git-https-for-carvel
  namespace: tap-install-gitops
spec:
  toNamespaces:
  - '*'
