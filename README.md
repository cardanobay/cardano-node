# The Lightweight & Secure Cardano Node

* We are currently in the FF (Friends & Family testnet) phase, so this guide is a work in progress. More detailed informations and concrete use cases to run a node will follow.

* I am running my node with buildah/podman, which is exactly the same as docker. So it may be possible you find some references to theses tools in this. If this is the case, just replace the terms "**buildah/podman**" by "**docker**"

## Why lightweight ?

Because the container is based on [the scratch image](https://hub.docker.com/_/scratch "The Scratch Image"), which is basically **an empty image**.

List of stuff packaged in the container :

* The domain name service (DNS) libraries (~80 KB)
* The cardano-node [fully statically linked binary](https://github.com/cardanobay/cardano-builder) (~101 MB)
* The nologin binary (used as default shell for users) (~14 KB)
* Two users (cardano-node and root) [~150 b]

Container bundle : **25 MB compressed** <-> **105 MB uncompressed**

...and this is it :) Nothing more, nothing less ! Hard to do smaller, isn't it ? ^_^

## Why secure ?

Because the node runs, by default, with an **unprivileged user**. \
Another reason is the attack surface is reduced to the strict minimum, because the container contains nothing except the **cardano-node binary**. It may be dangerous to add unnecessary commands or libraries, because if an attacker gains remote shell access on your node, he will have more tools to play with to alterate or destroy your node. \
One more reason, the **Dockerfile(s) and the building scripts are published** on the github repository. So you can (and should always) verify by yourself what is packaged inside the container. \
And finally, I include in the examples the best practice to run a container : dropping all [the linux kernel capabilities](https://docs.docker.com/engine/security/security/#linux-kernel-capabilities "the linux kernel capabilities") by default, then adding thoses who are mandatory.

## Where can I find the container ?

You can find the latest compiled version of the cardano-node container on the [Cardanobay Docker Hub Repository](https://hub.docker.com/repository/docker/cardanobay/cardano-node "the Cardanobay Docker Hub Repository")

There are two types of tags : **version** and **version-debug**. You should always use the **version** tag (1.13.0, latest etc.) when running in production. The **version-tag** includes somes tools to debug the container if needed.

```
docker run --name cardano-node --rm -it --entrypoint /bin/bash cardanobay/cardano-node:latest-debug
```

## Examples

### Fast examples

#### Pulling the container (production unsecure mode)
```
docker pull cardanobay/cardano-node:latest
```
#### Starting the container (production unsecure mode)
```
docker run --name cardano-node --rm --cap-drop=ALL --cap-add=NET_RAW cardanobay/cardano-node:latest <command>
```

#### Pulling the container (⚠️ debug mode ⚠️)
```
docker pull cardanobay/cardano-node:latest-debug
```

#### Starting the container  (⚠️ debug mode ⚠️)
```
docker run --name cardano-node --rm --cap-drop=ALL --cap-add=NET_RAW cardanobay/cardano-node:latest-debug <command>
```

Current available commands for debugging are : **bash**, **ls**, **cat**, **echo**, **ip**, **ping**, **grep**, **whoami**, **id**, **tail**, **du**, **find**

### Running the node in production, with extra security

The container must write in the local (mounted) database folder. It is  **${PWD}/database** in the examples. So make sure the cardano-node user inside the container can read-write in this folder. By default, it you don't rebuild the container, the user and group ID of cardano-node user are `256`. And if you update the cardano-node version, it may be necessary to drop everything in the database folder `rm -rf ${PWD}/database/*`

**Securing the database folder**

<code>
sudo chown root:256 ${PWD}/database
sudo chmod 770 ${PWD}/database
sudo chmod g+s ${PWD}/database
</code>

**Running the container in production (very secure environnement)**

```
docker run \
  --name cardano-node \
  --rm \
  --cap-drop=ALL \
  --cap-add=NET_RAW \
  --volume ${PWD}/configuration:/configuration \
  --volume ${PWD}/database:/database \
  --publish 3001:3001 \
  cardanobay/cardano-node:latest \
    run  \
      --database-path /database/ \
      --socket-path /socket \
      --port 3001 \
      --config /configuration/ff-config.json \
      --topology /configuration/ff-topology.json
```

### Debugging the node (as root)

```
docker run \
  --name cardano-node \
  --rm \
  -it \
  -u root \
  --cap-drop=ALL \
  --cap-add=NET_RAW \
  --entrypoint /bin/bash \
  --volume ${PWD}/sandbox/configuration:/configuration \
  --volume ${PWD}/sandbox/database:/database \
  --publish 3001:3001 \
  cardanobay/cardano-node:latest-debug
```

### Debugging the node (as unprivileged user)

```
docker run \
  --name cardano-node \
  --rm \
  -it \
  --cap-drop=ALL \
  --cap-add=NET_RAW \
  --entrypoint /bin/bash \
  --volume ${PWD}/sandbox/configuration:/configuration \
  --volume ${PWD}/sandbox/database:/database \
  --publish 3001:3001 \
  cardanobay/cardano-node:latest-debug
```

## Building the container locally (require some sysops skills)

⚠️ Depending on your ~~battlestation~~ workstation, it can takes up to 60 minutes to build ⚠️

```
git clone https://github.com/cardanobay/cardano-node.git
cd cardano-node
./scripts/02-build-image
```

```
Usage: ./scripts/02-build-image --node_version <version> [OPTIONS]
  Build the Cardano Node container.

Available options:
 *--node_version  The cardano-node binary version [Default: N/A] [Example: 1.13.0]
 *--tag           The cardano-node container tag [Default: none] [Example: latest, 1.13.0, 1.13.0-debug]
  --user_name     The cardano-node user name [Default: cardano-node]
  --user_id       The cardano-node user id [Default: 256]
  --group_name    The cardano-node group name [Default: cardano-node]
  --group_id      The cardano-node group id [Default: 256]
                  and Libraries [Default: 3.2.0.0]
  --port          The default EXPOSED TCP port [Default: 3001]
  --agent         Which agent to use to build the container [Default: docker] [docker|buildah]
  --help          Display this message
 * = mandatory options
```

## Contact

Admin email : pascha+cardanobay@protonmail.com \
Website : https://www.cardanobay.com \
Docker Hub : https://hub.docker.com/r/cardanobay/cardano-node \
Github : https://github.com/cardanobay/cardano-node
