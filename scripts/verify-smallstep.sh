#!/usr/bin/env bash

set -eo pipefail

# Verfies that SmallStep's StepClusterIssuer is installed
## Expects that namespace for certficate and tls secret already exists!

if [ -z "$1" ]; then
	echo "Usage: verify-smallstep.sh {domain}"
	exit 1
fi

DOMAIN="$1"

## Create the certificate in the small-step namespace
cat << EOF | tee tls.yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: tls
  namespace: contour-tls
spec:
  secretName: tls
  commonName: "*.${DOMAIN}"
  dnsNames:
  - "*.${DOMAIN}"
  duration: 24h
  renewBefore: 8h
  issuerRef:
    group: certmanager.step.sm
    kind: StepClusterIssuer
    name: step-cluster-issuer
EOF

kubectl apply -f tls.yaml

echo "Waiting..."
sleep 1m 30s

## If the above worked, you should get back a secret named tls in the contour-tls namespace.  We should also see that the challenge succeeded (i.e., there should be no challenges in the namespace).
## Let's verify...

kubectl get certificaterequest -A
kubectl get cert -A
kubectl get secret -n contour-tls | grep tls
kubectl describe challenges -n contour-tls