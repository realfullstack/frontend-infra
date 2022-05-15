#!/usr/bin/env bash


echo 
echo "Feature branch overlay cleanup"
echo 

if [[ -z "$1" ]]; then
    echo "Usage: $0 branch-name"
    echo """Example:
    $0 feature/jira-1234-branch-name
    """
    exit 1
fi


BRANCH_NAME=$1
echo "Branch name = $BRANCH_NAME"
if [[ $BRANCH_NAME != feature* ]]; then
      echo "Error: branch name should start with feature"
      exit 1
fi

FEATURE_BRANCH_CODE=$(set +x; echo ${BRANCH_NAME} | sed 's/[^a-zA-Z0-9-]/-/g' | sed 's/\\([A-Z]\\)/\\L\\1/g' | cut -c -24; set -x)


echo "Branch code = $FEATURE_BRANCH_CODE"
echo 

TARGET_APP_FILE="argocd-feature/${FEATURE_BRANCH_CODE}.yaml"
echo "Target app file = $TARGET_APP_FILE"
rm -fv ${TARGET_APP_FILE} && echo "deleted"


TARGET_OVERLAY_DIRECTORY="kustomize-feature/overlays/${FEATURE_BRANCH_CODE}"
echo "Target directory ${TARGET_OVERLAY_DIRECTORY}"
rm -rvf ${TARGET_OVERLAY_DIRECTORY} && echo "deleted"

