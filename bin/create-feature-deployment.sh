#!/usr/bin/env bash

TEMPLATE_APP_FILE="templates/argocd-feature/template.yaml"
TEMPLATE_OVERLAY_DIRECTORY="templates/kustomize-feature"

echo 
echo "Feature branch overlay builder"
echo 

if [[ -z "$2" ]]; then
    echo "Usage: $0 branch-name image-id"
    echo """Example:
    $0 feature/jira-1234-branch-name sha-148e9d9
    """
    exit 1
fi


function checkFile() {
  local _file="$1"
  _full_path=$( test -r  "$_file" )
  commandStatus=$?
  if [ $commandStatus -ne 0 ]; then
    echo "File '$_file' not found"
    exit 1
  fi
}

function checkENVLength() {
  str="$1"
  length=${#str}
  echo "Length is empty"
}

function checkENV() {
  if [[ -z "$1" ]]; then
      echo "env var '$1' does not exist"
      exit 1
      checkENVLength $1
  fi
}

checkFile $TEMPLATE_APP_FILE
checkFile $TEMPLATE_OVERLAY_DIRECTORY

BRANCH_NAME=$1
echo "Branch name = $BRANCH_NAME"
if [[ $BRANCH_NAME != feature* ]]; then
      echo "Error: branch name should start with feature"
      exit 1
fi


IMAGE_ID=$2
echo "Image ID = $IMAGE_ID"
if [[ $IMAGE_ID != sha* ]]; then
      echo "Error: image id should start with sha-"
      exit 1
fi


FEATURE_BRANCH_CODE=$(set +x; echo ${BRANCH_NAME} | sed 's/[^a-zA-Z0-9-]/-/g' | sed 's/\\([A-Z]\\)/\\L\\1/g' | cut -c -24; set -x)
echo "Branch code = $FEATURE_BRANCH_CODE"
echo 

echo "Rendering the app template"
TARGET_APP_FILE="argocd-feature/${FEATURE_BRANCH_CODE}.yaml"
echo "Template app file = $TEMPLATE_APP_FILE"
echo "Target app file = $TARGET_APP_FILE"

export FEATURE_BRANCH_CODE
./bin/sempl -f -v $TEMPLATE_APP_FILE $TARGET_APP_FILE

# echo
# echo "Rendering kustomize overlay"

# TARGET_OVERLAY_DIRECTORY="kustomize-feature/overlays/${FEATURE_BRANCH_CODE}"
# echo "Template directory ${TEMPLATE_OVERLAY_DIRECTORY}"
# echo "Target directory ${TARGET_OVERLAY_DIRECTORY}"

# echo "Recreating target directory"
# rm -rf ${TARGET_OVERLAY_DIRECTORY}
# cp -r ${TEMPLATE_OVERLAY_DIRECTORY} ${TARGET_OVERLAY_DIRECTORY}

# export BUILD_DATABASE_NAME="$FEATURE_BRANCH_CODE"
# export BUILD_CELERY_VHOST="$FEATURE_BRANCH_CODE"
# export IMAGE_ID
# ./bin/sempl -f -v "${TARGET_OVERLAY_DIRECTORY}/kustomization.yaml"
# ./bin/sempl -f -v "${TARGET_OVERLAY_DIRECTORY}/files/config.env"
