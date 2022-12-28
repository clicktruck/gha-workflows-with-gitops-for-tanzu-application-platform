#!/usr/bin/env bash
set -eo pipefail

# Uninstalls one or more Tanzu package(s) via kapp and kubectl CLIs
## Packages must conform to a specific directory structure
## +- application_name
##   +- .init
##   +- .install
##   +- base

## Do not change anything below unless you know what you're doing!

if [ "x${KUBECONFIG}" == "x" ]; then
  echo "Workload cluster KUBECONFIG environment variable not set."

  if [ -z "$1" ]; then
    echo "Workload cluster name was not supplied!"
	  exit 1
  fi

  if [ -z "$2" ]; then
    echo "Management cluster's KUBECONFIG base64-encoded contents was not supplied!"
	  exit 1
  fi

  WORKLOAD_CLUSTER_NAME="$1"

  echo "- Decoding the management cluster's KUBECONFIG contents and saving output to /tmp/.kube-tkg/config"
  mkdir -p /tmp/.kube-tkg
  echo "$2" | base64 -d > /tmp/.kube-tkg/config
  chmod 600 /tmp/.kube-tkg/config

  cluster_name=$(cat /tmp/.kube-tkg/config | yq '.clusters[].name')
  echo "- Management cluster name is [ $cluster_name ]"

  echo "- Logging in to management cluster"
  tanzu login --kubeconfig /tmp/.kube-tkg/config --context ${cluster_name}-admin@${cluster_name} --name ${cluster_name}

  echo "- Obtaining the workload cluster's KUBECONFIG and setting the current context for kubectl"
  tanzu cluster kubeconfig get ${WORKLOAD_CLUSTER_NAME} --admin
  kubectl config use-context ${WORKLOAD_CLUSTER_NAME}-admin@${WORKLOAD_CLUSTER_NAME}

  if [ -z "$4" ]; then
    echo "Application name was not supplied!"
    exit 1

  else
    if [ -z "$3" ]; then
      echo "Path to Tanzu package was not supplied!"
      exit 1

    else
      if [ -z "$GITHUB_WORKSPACE" ]; then
        GITOPS_DIR=../"$3"
        YTT_PARENT_DIR=".."
      else
        GITOPS_DIR=$GITHUB_WORKSPACE/$3
        YTT_PARENT_DIR=$GITHUB_WORKSPACE
      fi

      APP_NAME="${4}"
      cd ${GITOPS_DIR}

      if [ -d "${GITOPS_DIR}/.post-install" ]; then
        files=$(find ${GITOPS_DIR}/.post-install -type f -name "*.yml" | wc -l)
        if [ $files -eq 1 ]; then
          kind=$(yq -o=json '.kind' .post-install/*.yml | tr -d '"')
          if [ "$kind" == "App" ]; then
            ytt_paths=( $(yq -o=json '.spec.template.[].ytt.paths.[]' .post-install/*.yml | tr -d '"') )
            ytt_path_count=${#ytt_paths[@]}
            i=0
            for ytt_path in "${ytt_paths[@]}"
            do
              if [ -d "${YTT_PARENT_DIR}/${ytt_path}" ]; then
                  i=$((i+1))
              fi
            done
            if [ $i -gt 0 ] && [ $i -eq $ytt_path_count ]; then
              kapp delete --app $APP_NAME-ancillary --diff-changes --yes
            fi
          fi
        fi
      fi
      if [ -d "${GITOPS_DIR}/.init" ] && [ -d "${GITOPS_DIR}/.install" ]; then
        kapp delete --app $APP_NAME --diff-changes --yes
        kapp delete --app $APP_NAME-ns-rbac --diff-changes --yes
      else
        echo "Expected to find .init and .install sub-directories underneath $GITOPS_DIR"
        exit 1
      fi
      if [ -d "${GITOPS_DIR}/.prereq" ]; then
        kubectl delete -f .prereq
      fi
    fi
  fi

else
  echo "Workload cluster KUBECONFIG environment variable was set."

  if [ -z "$2" ]; then
    echo "Application name was not supplied!"
    exit 1

  else
    if [ -z "$1" ]; then
      echo "Path to Tanzu package was not supplied!"
      exit 1

    else
      if [ -z "$GITHUB_WORKSPACE" ]; then
        GITOPS_DIR=../"$1"
        YTT_PARENT_DIR=".."
      else
        GITOPS_DIR=$GITHUB_WORKSPACE/$1
        YTT_PARENT_DIR=$GITHUB_WORKSPACE
      fi

      APP_NAME="${2}"
      cd ${GITOPS_DIR}

      if [ -d "${GITOPS_DIR}/.post-install" ]; then
        files=$(find ${GITOPS_DIR}/.post-install -type f -name "*.yml" | wc -l)
        if [ $files -eq 1 ]; then
          kind=$(yq -o=json '.kind' .post-install/*.yml | tr -d '"')
          if [ "$kind" == "App" ]; then
            ytt_paths=( $(yq -o=json '.spec.template.[].ytt.paths.[]' .post-install/*.yml | tr -d '"') )
            ytt_path_count=${#ytt_paths[@]}
            i=0
            for ytt_path in "${ytt_paths[@]}"
            do
              if [ -d "${YTT_PARENT_DIR}/${ytt_path}" ]; then
                  i=$((i+1))
              fi
            done
            if [ $i -gt 0 ] && [ $i -eq $ytt_path_count ]; then
              kapp delete --app $APP_NAME-ancillary --diff-changes --yes
            fi
          fi
        fi
      fi
      if [ -d "${GITOPS_DIR}/.init" ] && [ -d "${GITOPS_DIR}/.install" ]; then
        kapp delete --app $APP_NAME --diff-changes --yes
        kapp delete --app $APP_NAME-ns-rbac --diff-changes --yes
      else
        echo "Expected to find .init and .install sub-directories underneath $GITOPS_DIR"
        exit 1
      fi
      if [ -d "${GITOPS_DIR}/.prereq" ]; then
        kubectl delete -f .prereq
      fi
    fi
  fi

fi
