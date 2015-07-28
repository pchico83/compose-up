#!/bin/bash
set -e

curl -L https://github.com/docker/compose/releases/download/${VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

if [ -S /var/run/docker.sock ]; then
	echo "=> Detected unix socket at /var/run/docker.sock"

LOOP_LIMIT=90
for (( i=0; ; i++ )); do
    if [ ${i} -eq ${LOOP_LIMIT} ]; then
        echo "   Failed to connect to docker (did you use --privileged when running this container?"
        exit 1
    fi
    sleep 1
    docker version > /dev/null 2>&1 && break
done

echo "=> Loading docker auth configuration"
if [ -f /.dockercfg ]; then
	echo "   Using existing configuration in /.dockercfg"
	ln -s /.dockercfg /root/.dockercfg
elif [ ! -z "$DOCKERCFG" ]; then
	echo "   Detected configuration in \$DOCKERCFG"
	echo "$DOCKERCFG" > /root/.dockercfg
fi

echo "   Cloning repo from ${REPOSITORY##*@}"
git clone --recursive REPOSITORY /src
cd /src
if [ ! -z "$COMMIT" ]; then
    git checkout $COMMIT
fi
export SHA1=$(git rev-parse HEAD)
export MESSAGE=$(git log --format=%B -n 1 $SHA1)
unset REPOSITORY

if [ -d "hooks" ]; then
	chmod +x hooks/*
fi

if [ -f "hooks/run" ]; then
	source hooks/run
else
    if [ -f "hooks/pre_run" ]; then
        source hooks/pre_run

    echo "=> running docker-compose.yml"
    cat $PATH | grep "image:" | awk '{print $2}' | xargs -n1 docker pull
    docker-compose -f $PATH -p app up

    if [ -f "hooks/pre_run" ]; then
        source hooks/post_run
fi
