#!/usr/bin/env bash

function echoerr {
    echo "============================================" 1>&2;
    echo "ERROR: $@" 1>&2;
    echo "============================================" 1>&2;
}
function error_exit { echoerr "$1"; exit 1; }

function export_persist {
    export "$1=$2"
    echo "$1='$2'" >> /etc/environment
}

restore_backup() {
    echo '>>> Restoring Jenkins backup from S3'

    S3_BACKUP="s3://akl.om3.cloud/backups/jenkins/"
    S3_REGION="eu-central-1"

    if [ -z "${S3_BACKUP}" ] ; then error_exit "S3_BACKUP env var missing."; fi

    S3_BACKUP_ARCHIVE=$(aws s3 ls --region ${S3_REGION} ${S3_BACKUP} | tail -1 | awk '{print $NF}')
    if [ -z "${S3_BACKUP_ARCHIVE}" ] ; then
        echo "No backup found"
    else
        echo "Downloading backup file: ${S3_BACKUP}${S3_BACKUP_ARCHIVE}"
        aws s3 cp --region ${S3_REGION} "${S3_BACKUP}${S3_BACKUP_ARCHIVE}" "/tmp/restore.tar.gz" || error_exit "Failed to download the backup file"

        JENKINS_HOME="/var/lib/jenkins"

        echo "Deleting current Jenkins home directory (${JENKINS_HOME})"
        if [[ -d "${JENKINS_HOME}" ]]; then
            rm -rf "${JENKINS_HOME}" || error_exit "Failed to remove an existing Jenkins home"
        fi
        mkdir -p "${JENKINS_HOME}" || error_exit "Failed to create Jenkins home"

        echo "Extracting /tmp/restore.tar.gz to ${JENKINS_HOME}"
        tar zxf "/tmp/restore.tar.gz" -C "${JENKINS_HOME}" || error_exit "Failed to extract the jenkins backup"
        rm "/tmp/restore.tar.gz"

        service jenkins restart || error_exit "Failed restarting Jenkins"
    fi

    echo '<<< Done restoring Jenkins backup from S3'
}

echo ">>> Upgrading system packages"
export_persist DEBIAN_FRONTEND noninteractive
apt-get update || error_exit "Failed running apt-get update"
apt-get install apt-transport-https || error_exit "Failed installing apt-transport-https"
apt-get dist-upgrade -y || error_exit "Failed upgrading packages"


echo ">>> Installing additional system packages (python, unzip, etc.)"
apt-get -y install unzip python || error_exit "Failed installing additional system packages"


echo '>>>> Installing AWS Cli'
curl -s "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" || error_exit 'Failed downloading awscli'
unzip awscli-bundle.zip && ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws || error_exit 'Failed installing awscli'


echo '>>>> Add github.com to list of known hosts'
sudo -u jenkins ssh -o StrictHostKeyChecking=no git@github.com


echo ">>> Installing Jenkins"
wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add - || error_exit "Failed adding key"
sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list' || error_exit "Failed adding key"
apt-get update
apt-get -y install jenkins || error_exit "Failed installing Jenkins"
apt-get -y install git jq pv || error_exit "Failed installing tools"
restore_backup


echo '>>> Installing Docker'
apt-get update || error_exit "Failed updating packages"
apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual || error_exit "Failed installing linux-image-extra"
apt-get install -y apt-transport-https ca-certificates || error_exit "Failed installing misc packages"
apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-precise main" | sudo tee /etc/apt/sources.list.d/docker.list
apt-get update || error_exit "Failed updating packages"
apt-get install -y --allow-unauthenticated docker-engine || error_exit "Failed installing docker"
service docker restart
usermod -aG docker jenkins || error_exit "Failed adding Jenkins user to docker group"
service jenkins restart || error_exit "Failed restarting Jenkins"



echo '>>> Installing kubectl'
wget \
    -O /usr/local/bin/kubectl \
    https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    || error_exit "Failed installing kubectl"
chmod +x /usr/local/bin/kubectl || error_exit "Failed setting executable bit to kubectl binary"



echo '>>> Installing terraform'
TERRAFORM_VERSION="0.9.0-beta1"
wget -q -O /tmp/terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    unzip /tmp/terraform.zip -d /usr/local/bin || error_exit "Failed installing terraform"
chmod +x /usr/local/bin/terraform || error_exit "Failed setting executable bit to terraform binary"
