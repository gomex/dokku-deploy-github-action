#!/bin/bash

# Consume environment variables
SSH_PRIVATE_KEY=$1
DOKKU_USER=$2
DOKKU_HOST=$3
DOKKU_APP_NAME=$4
DOKKU_REMOTE_BRANCH=$5
DOKKU_PORT=$6

echo -n "Deploying application to Dokku host\n"

# Setup the SSH environment
mkdir -p ~/.ssh
eval `ssh-agent -s`
ssh-add - <<< $SSH_PRIVATE_KEY
ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub
ssh-keyscan $DOKKU_HOST >> ~/.ssh/known_hosts
chown 400 ~/.ssh/id_rsa

# Setup the git environment
REMOTE=$DOKKU_USER@$DOKKU_HOST:$DOKKU_PORT:$DOKKU_APP_NAME
echo $REMOTE
cd $GITHUB_WORKSPACE
git remote add dokku $REMOTE

# Prepare to push to Dokku git repository
REMOTE_REF=$GITHUB_SHA:refs/heads/$DOKKU_REMOTE_BRANCH:master
GIT_COMMAND="git push dokku $REMOTE_REF"
echo "GIT_COMMAND=$GIT_COMMAND"

# Push to Dokku git repository
GIT_SSH_COMMAND="ssh -i ~/.ssh/id_rsa -F /dev/null -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" $GIT_COMMAND
