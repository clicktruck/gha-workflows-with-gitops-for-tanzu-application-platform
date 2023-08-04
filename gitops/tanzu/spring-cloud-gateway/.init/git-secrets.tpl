apiVersion: v1
kind: Secret
metadata:
  name: git-https-for-carvel
  namespace: spring-cloud-gateway
  annotations:
    kapp.k14s.io/change-group: scg-install/rbac
    kapp.k14s.io/change-rule: "delete after deleting scg-install-gitops/app"
type: kubernetes.io/basic-auth
stringData:
  username: {{ .git_username }}
  password: {{ .git_personal_access_token }}
