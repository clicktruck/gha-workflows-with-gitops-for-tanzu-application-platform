apiVersion: v1
kind: Secret
metadata:
  name: git-ssh-for-carvel
  namespace: spring-cloud-gateway
  annotations:
    kapp.k14s.io/change-group: scg-install/rbac
    kapp.k14s.io/change-rule: "delete after deleting scg-install-gitops/app"
type: kubernetes.io/ssh-auth
data:
  ssh-privatekey: {{ .git_ssh_private_key }}
  ssh-knownhosts: {{ .git_ssh_known_hosts }}
