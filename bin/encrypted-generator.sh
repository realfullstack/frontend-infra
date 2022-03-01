#!/usr/bin/env bash

echo "Sealed secrets encryptedData kustomize patch generator"

if [[ -z "$3" ]]; then
    echo "Usage: $0 certificate envfile destination_patch"
    echo """Example:
    $0 .secrets/kube-seal.pem .secrets/dev/secrets.env kustomize/overlays/dev/patches/sealed-secret.yaml
    """
    exit 1
fi

function checkBin() {
  local _binary="$1"
  _full_path=$( command -v "$_binary" )
  commandStatus=$?
  if [ $commandStatus -ne 0 ]; then
    echo "Command '$_binary' not found"
    exit 1
  fi
}

function checkFile() {
  local _file="$1"
  _full_path=$( test -r  "$_file" )
  commandStatus=$?
  if [ $commandStatus -ne 0 ]; then
    echo "File '$_binary' not found"
    exit 1
  fi
}

indent() { sed 's/^/    /'; }

checkFile $1
checkFile $2

checkBin kubectl
checkBin kubeseal
checkBin yq

CERT_FILE=$1
ENV_FILE=$2
DESTINATION_FILE=$3

echo "Generating patch using $ENV_FILE into $DESTINATION_FILE"


SEALED_DATA=$(kubectl create secret generic authenticator \
  --dry-run=client \
  --from-env-file="$ENV_FILE" \
  -o yaml | kubeseal \
  --cert "$CERT_FILE" \
  --allow-empty-data \
  --scope cluster-wide \
  -o yaml | yq -M --yaml-output .spec.encryptedData | sed 's/^/    /')

if [ $? -ne 0 ]; then
    echo "Failed sealing data"
    exit 1
fi

echo  """---
- op: replace
  path: /spec/encryptedData
  value:
$SEALED_DATA
""" > "$DESTINATION_FILE"