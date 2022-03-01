# RealFullStack Frontend Infra/GitOps

This is the frontend infra code


## Namespaces

Ensure that the `realfullstack-prod` namespace exists.


## ArgoCD Configuration

Run `kubectl apply -k argocd`

## Secrets

`sealed-secrets` is required for the secrets found in this repo to work.
To update secrets on the `prod` deployment, use the following snippet:
```bash
mkdir .secrets/

# fetch the seal certificate 
kubeseal \
 --controller-name=sealed-secrets \
 --controller-namespace=security \
 --fetch-cert > .secrets/kube-seal.pem

# add your secrets as env vars
vim .secrets/prod/secrets.env

# create a secret config locally and pass it through the kubeseal for encryption
./bin/encrypted-generator.sh \
  .secrets/kube-seal.pem\
  .secrets/prod/secrets.env\
  kustomize/overlays/prod/patches/sealed-secret.yaml


# make sure that the sealedsecret is not altered (name+data should not be changed by kustomize)
kustomize build kustomize/overlays/prod  |  k apply -f -

```