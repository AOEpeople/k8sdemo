#!/bin/bash

SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

VPC_ID=""
CLUSTER_NAME=""
KOPS_STATE_STORE=""
ZONES=""
MASTER_ZONES=""
KEY_NAME=""

function echoerr {
    echo "============================================" 1>&2;
    echo "ERROR: $@" 1>&2;
    echo "============================================" 1>&2;
}
function error_exit { echoerr "$1"; exit 1; }

while getopts 'v:c:k:z:m:n:' OPTION ; do
    case "${OPTION}" in
        v) VPC_ID="${OPTARG}" ;;
        c) CLUSTER_NAME="${OPTARG}" ;;
        k) KOPS_STATE_STORE="${OPTARG}" ;;
        z) ZONES="${OPTARG}" ;;
        m) MASTER_ZONES="${OPTARG}" ;;
        n) KEY_NAME="${OPTARG}" ;;
    esac
done

if [ -z "$VPC_ID" ] ; then error_exit "VPC_ID (-v) not set"; fi
if [ -z "$CLUSTER_NAME" ] ; then error_exit "CLUSTER_NAME (-c) not set"; fi
if [ -z "$KOPS_STATE_STORE" ] ; then error_exit "KOPS_STATE_STORE (-k) not set"; fi
if [ -z "$ZONES" ] ; then error_exit "ZONES (-z) not set"; fi
if [ -z "$MASTER_ZONES" ] ; then error_exit "MASTER_ZONES (-m) not set"; fi
if [ -z "$KEY_NAME" ] ; then error_exit "KEY_NAME (-n) not set"; fi

export KOPS_STATE_STORE

kops create cluster \
  --name=${CLUSTER_NAME} \
  --zones=${ZONES} \
  --master-zones=${MASTER_ZONES} \
  --vpc=${VPC_ID} || echo "Cluster ${CLUSTER_NAME} already exists. Ignoring..."

#  --ssh-public-key=${SOURCE_DIR}/${KEY_NAME}.pub || echo "Cluster ${CLUSTER_NAME} already exists. Ignoring..."

kops update cluster "${CLUSTER_NAME}" --yes || error_exit "kops update cluster failed"

