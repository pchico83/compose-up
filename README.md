pchico83/compose-up
===================

A docker image that clones a git repository and runs the `docker-compose.yml` file on it.


# Usage

## Run `docker-compose.yml` from Git repository

Run the following command:

	docker run --rm -it --privileged -e REPOSITORY=$REPOSITORY -e COMMIT=$COMMIT -e PATH=$PATH -e VERSION=$VERSION pchico83/compose-up

Where:

* `$REPOSITORY` is the git repository to clone, i.e. `https://github.com/pchico83/compose-up.git`.
* `$COMMIT` (optional, defaults to _HEAD_) is the git commit to be used.
* `$PATH` (optional, defaults to _/docker-compose.yml_) is the relative path to the root of the repository where the `docker-compose.yml` file is located.
* `$VERSION` (optional, defaults to _1.3.2_) is the _docker-compose_ version to be used.

Note that you need to publish the required ports if you want you `docker-compose.yml` file to be accesible from the host network.

## Adding credentials via .dockercfg

If your `docker-compose.yml` file requires private images, you can pass their credentials either by mounting your local `.dockercfg` file inside the container appending:

```
-v $HOME/.dockercfg:/.dockercfg:r
```

or by providing the contents of this file via an environment variable called `$DOCKERCFG`:

```
-e DOCKERCFG=$(cat $HOME/.dockercfg)
```

## Using the host docker daemon instead of docker-in-docker

If you want to use the host docker daemon instead of letting the container run its own, mount the host's docker unix socket inside the container by appending:

```
-v /var/run/docker.sock:/var/run/docker.sock:rw
-v /usr/bin/docker:/usr/bin/docker:rw

```

to the `docker run` command. Note that this will cache your `docker-compose.yml` iamges between different executions of the `compose-up` image and will make ports published in the `docker-compose.yml` file directly accesible from the host network, but will not clean the created container when the `compose-up` container is terminated.