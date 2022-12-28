apiVersion: v1
kind: Secret
metadata:
  name: git-ssh-for-carvel
  namespace: tap-install-gitops
  annotations:
    kapp.k14s.io/change-group: tap-install-gitops/rbac
    kapp.k14s.io/change-rule: "delete after deleting tap-install-gitops/app"
type: kubernetes.io/ssh-auth
data:
  ssh-privatekey: {{ .git_ssh_private_key }}
  ssh-knownhosts: {{ .git_ssh_known_hosts }}
