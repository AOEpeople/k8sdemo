#!/usr/bin/env bash

# export kops state from S3 bucket
kops export kubecfg --v=10 --name="kops.aoeplay.net" --state="s3://muckops/"


