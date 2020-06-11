# The Lightweight & Secure Cardano Node Container

## Why lightweight ?

Because the container is based on [the scratch image](https://hub.docker.com/_/scratch "The Scratch Image"), which is basically **an empty image**.

List of stuff packaged in the container :

* The cardano-node required libraries (~7Mb)
* The cardano-node binary (~104MB)
* The nologin binary (used as default shell for users) (~14Kb)
* Two users (cardano-node and root) [~150b]

Container bundle : **22 Mb compressed** <-> **116 Mb uncompressed**

...and this is it :) Nothing more, nothing less ! Hard to do smaller, isn't it ? ^_^

## Why secure ?

Because the node runs, by default, with an **unprivileged user**. \
Another reason is the attack surface is reduced to the strict minimum, because the container contains nothing except the **cardano-node binary**. \
One more reason, the **Dockerfile(s) and the building script are published** on the github repository and Docker Hub. So you can verifiy by yourself what is packaged inside the container. You should **always verify** what is packaged inside a container before using it.

## How can I download the container ?
You can find the latest version of the cardano-node container on [the Cardanobay Docker Hub Repository](https://hub.docker.com/repository/docker/cardanobay/cardano-node "the Cardanobay Docker Hub Repository")

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

```
git clone https://github.com/cardanobay/cardano-node.git
cd cardano-node
./scripts/build-cardano-node.sh
```

Command line options :

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

## Debugging
If you have some problem using the container, and want to look inside, you can build it by yourself.
1. Grab the latest Docker file on our repo https://github.com/cardanobay/cardano-node/blob/master/latest/Dockerfile
2. Uncomment the [OPTIONAL] section
3. Build the container locally
4. Launch the container with this command line to obtain root + shell access : `docker run --name cardano-node --rm -it -u root --entrypoint /bin/sh localhost/cardano-node:1.13.0`

Current available commands are : **sh**, **ls**, **cat**, **echo**, **whoami**, **id**, **tail**, **du**, **grep**, **find**

## Contact

Admin email : pascha+cardanobay@protonmail.com \
Website : https://www.cardanobay.com \
Docker Hub : https://hub.docker.com/r/cardanobay/cardano-node \
Github : https://github.com/cardanobay/cardano-node
