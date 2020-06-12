# The Lightweight & Secure Cardano Node Container

* We are currently in the FF (Friends & Family testnet) phase, so this procedure is a work in progress. More detailed informations and concrete use cases to run a node will follow.

* I am running my node with buildah/podman, which is exactly the same as docker. So it may be possible you find some references to theses tools int this documentation. If this is the case, replace the terms "**buildah/podman**" by "**docker**"

## Why lightweight ?

Because the container is based on [the scratch image](https://hub.docker.com/_/scratch "The Scratch Image"), which is basically **an empty image**.

List of stuff packaged in the container :

* The cardano-node required libraries (~7 MB)
* The domain name service (DNS) libraries (~80 KB)
* The cardano-node binary (~104 MB)
* The nologin binary (used as default shell for users) (~14 KB)
* Two users (cardano-node and root) [~150 b]

Container bundle : **22 Mb compressed** <-> **116 Mb uncompressed**

...and this is it :) Nothing more, nothing less ! Hard to do smaller, isn't it ? ^_^

## Why secure ?

Because the node runs, by default, with an **unprivileged user**. \
Another reason is the attack surface is reduced to the strict minimum, because the container contains nothing except the **cardano-node binary**. \
One more reason, the **Dockerfile(s) and the building script are published** on the github repository. So you can verify by yourself what is packaged inside the container. You should **always verify** what is packaged inside a container before using it.\
And the examples to run the node includes good practices when running a Docker Container in production : dropping all [the linux kernel capabilities](https://docs.docker.com/engine/security/security/#linux-kernel-capabilities "the linux kernel capabilities"), then adding ONLY the needed ones to run the service.

## Where can I find the container ?
You can find the latest compiled version of the cardano-node container on [the Cardanobay Docker Hub Repository](https://hub.docker.com/repository/docker/cardanobay/cardano-node "the Cardanobay Docker Hub Repository")

### Pulling the container
```
docker pull cardanobay/cardano-node:latest
```
### Starting the container
```
docker run --name cardano-node --rm cardanobay/cardano-node:latest <command>
```

### Building the container

The current building script accepts both docker and buildah

⚠️ Depending on your ~~battlestation~~ workstation, it can take from 5-60 minutes to build ⚠️

```
git clone https://github.com/cardanobay/cardano-node.git
cd cardano-node
./scripts/build-cardano-node.sh
```


```
Usage: ./scripts/build-cardano-node.sh --node_version <version> [OPTIONS]
  Build the Cardano Node container.

Available options:
 *--node_version  The cardano-node version [Default: N/A] [Example: latest, 1.13.0]
                  'latest' will results in resolving the latest version from github
  --user_name     The cardano-node user name [Default: cardano-node]
  --user_id       The cardano-node user id [Default: 256]
  --group_name    The cardano-node group name [Default: cardano-node]
  --group_id      The cardano-node group id [Default: 256]
  --ghc_version   The Glasgow Haskell Compiler version [Default: 8.6.5]
  --cabal_version The Common Architecture for Building Applications
                  and Libraries [Default: 3.2.0.0]
  --port          The default EXPOSED TCP port [Default: 3001]
  --builder       Which binary to use to build the container [Default: docker] [docker|buildah]
  --help          Display this message
 * = mandatory options

```

## Debugging (require some sysops skills)

⚠️ Please do not use a container in debugging mode for production environment ⚠️

If you have any problem using this container, and want to debug it, please follow theses steps :
1. Grab the latest Docker file on the repo https://github.com/cardanobay/cardano-node/blob/master/latest/Dockerfile
2. Uncomment the [OPTIONAL] section (it will add the listed utilities)
   * You can add or remove any utilities
   * The path of each utility you want to add must exists in the container from "builder" stage
   * The needed libraries will be automatically resolved and installed on the final image
3. Build the container locally (you can use the building script from our repository)
4. Launch the container with this command line to obtain root + shell access + access to utilities :
`docker run --name cardano-node --rm -it -u root --entrypoint /bin/bash localhost/cardano-node:<TAG|VERSION>`

Current available commands are : **bash**, **ls**, **cat**, **echo**, **ip**, **ping**, **grep**, **whoami**, **id**, **tail**, **du**, **find**

## Examples

### Running the node
```
podman run \
  --name cardano-node \
  --rm \
  --cap-drop=ALL \
  --cap-add=NET_RAW \
  --volume ${PWD}/configuration:/configuration \
  --volume ${PWD}/database:/database \
  --publish 3001:3001 \
  localhost/cardano-node:latest \
    run  \
      --database-path /database/ \
      --socket-path /socket \
      --port 3001 \
      --config /configuration/ff-config.json \
      --topology /configuration/ff-topology.json
```

### Debugging the node (as root, needs to build the container locally)

```
podman run \
  --name cardano-node \
  --rm \
  -it \
  -u root \
  --cap-drop=ALL \
  --cap-add=NET_RAW \
  --entrypoint /bin/bash \
  --volume ${PWD}/configuration:/configuration \
  --volume ${PWD}/database:/database \
  --publish 3001:3001 \
  localhost/cardano-node:latest
```

### Debugging the node (as unprivileged user, requires to build the container locally)

```
podman run \
  --name cardano-node \
  --rm \
  -it \
  --cap-drop=ALL \
  --cap-add=NET_RAW \
  --entrypoint /bin/bash \
  --volume ${PWD}/configuration:/configuration \
  --volume ${PWD}/database:/database \
  --publish 3001:3001 \
  localhost/cardano-node:latest
```

## Contact

Admin email : pascha+cardanobay@protonmail.com \
Website : https://www.cardanobay.com \
Docker Hub : https://hub.docker.com/r/cardanobay/cardano-node \
Github : https://github.com/cardanobay/cardano-node
