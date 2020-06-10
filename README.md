# The Lightweight & Secure Cardano Node Container

## Why lightweight ?

Because the container is based on [the scratch image](https://hub.docker.com/_/scratch "The Scratch Image"), which is basically **an empty image**. Even the alpine or busybox images are bigger by design.

List of stuff packaged in the container :

* The cardano-node required libraries (~7Mb)
* The cardano-node binary (~104MB)
* The sh binary (RUN, CMD and ENTRYPOINT require a shell) (~120kb)
* The nologin binary (used as default shell for users) (~14Kb)
* Two users (cardano-node and root) [~150b]

The container bundle is **22 Mb compressed**, and **108 Mb uncompressed** !

...and this is it ! Nothing more, nothing less ! Hard to do smaller, isn't it ? ^_^

## Why secure ?

Because the node runs, by default, with an **unprivileged user**, and there is absolutely nothing an attacker could to even if he gain an interactive shell access.

Inside this container, you are trapped. The only option you have is to run (or not) the **cardano-node binary** :) No wget, rm, chmod, su or other fun commands to play with that could break the container :)

Another reason is I publish the Dockerfile on this repository, as well as the building scripts. So you can built it by yourself if you want to. You should **always verify** what is packaged inside a container before using it !

## How can I download the container ?
You can find the latest version of the cardano-node container on [the Cardanobay Docker Hub Repository](https://hub.docker.com/repository/docker/cardanobay/cardano-node "the Cardanobay Docker Hub Repository")

### Pulling the container
```
docker pull cardanobay/cardano-node
```

### @TODO Using the container

