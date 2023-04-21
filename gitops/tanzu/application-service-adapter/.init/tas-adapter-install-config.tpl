#@ load("@ytt:yaml", "yaml")
---
#@ def config():
tap:
  credentials:
    registry:
      host: {{ .container_image_registry_url }}

tas_adapter:
  domains:
    main: {{ .domain }}
  ingress:
    contour_tls_secret: tls
    contour_tls_namespace: contour-tls
  registry:
    prefix: {{ or .container_image_registry_prefix "tas-adapter" }}

#@ end
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .app_name }}
  namespace: tas-adapter-install-gitops
data:
  tap-config.yml: #@ yaml.encode(config())