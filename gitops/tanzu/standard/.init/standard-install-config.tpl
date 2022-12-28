#@ load("@ytt:yaml", "yaml")
---
#@ def config():
tkg:
  version: {{ .tkg_version }}
#@ end
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: tanzu-standard
  namespace: tanzu-package-repo-global
data:
  tkg-config.yml: #@ yaml.encode(config())