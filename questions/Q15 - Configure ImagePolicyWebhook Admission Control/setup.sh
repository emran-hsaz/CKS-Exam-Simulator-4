#!/bin/bash
echo "Setting up Q15 — ImagePolicyWebhook..."

APISERVER="/etc/kubernetes/manifests/kube-apiserver.yaml"
mkdir -p /etc/kubernetes

# Create the admission config file
cat > /etc/kubernetes/admission-config.yaml << 'ADMCFG'
apiVersion: apiserver.config.k8s.io/v1
kind: AdmissionConfiguration
plugins:
  - name: ImagePolicyWebhook
    configuration:
      imagePolicy:
        kubeConfigFile: /etc/kubernetes/admission-webhook-kubeconfig.yaml
        allowTTL: 50
        denyTTL: 50
        retryBackoff: 500
        defaultAllow: false
ADMCFG

# Create dummy webhook kubeconfig (pointing to localhost — will not be called in sandbox)
cat > /etc/kubernetes/admission-webhook-kubeconfig.yaml << 'KUBECONF'
apiVersion: v1
kind: Config
clusters:
  - name: image-policy-webhook
    cluster:
      server: https://localhost:8443/validate
      insecure-skip-tls-verify: true
users:
  - name: api-server
    user: {}
contexts:
  - context:
      cluster: image-policy-webhook
      user: api-server
    name: webhook
current-context: webhook
KUBECONF

# Remove plugin flags if already present (clean state)
if [ -f "$APISERVER" ]; then
  cp "$APISERVER" "${APISERVER}.bak.q15"
  sed -i '/ImagePolicyWebhook/d;/admission-control-config-file/d' "$APISERVER"
fi

echo ""
echo "Done."
echo "  Admission config: /etc/kubernetes/admission-config.yaml (defaultAllow: false)"
echo "  Edit /etc/kubernetes/manifests/kube-apiserver.yaml to enable ImagePolicyWebhook."
