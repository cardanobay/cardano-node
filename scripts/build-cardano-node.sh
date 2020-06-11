#!/bin/sh

set -e

trap 'catch $? $LINENO' EXIT

usage() {
  echo "Usage: $0 --node_version <version> [OPTIONS]"
  echo "  Build the Cardano Node container."
  echo ""
  echo "Available options:"
  echo " *--node_version  The cardano-node version [Default: N/A] [Example: latest, 1.13.0]"
  echo "                  'latest' will results in resolving the latest version from github"
  echo "  --user_name     The cardano-node user name [Default: cardano-node]"
  echo "  --user_id       The cardano-node user id [Default: 256]"
  echo "  --group_name    The cardano-node group name [Default: cardano-node]"
  echo "  --group_id      The cardano-node group id [Default: 256]"
  echo "  --ghc_version   The Glasgow Haskell Compiler version [Default: 8.6.5]"
  echo "  --cabal_version The Common Architecture for Building Applications"
  echo "                  and Libraries [Default: 3.2.0.0]"
#  echo "  --os_arch       The operating system architecture [Default: x86_64]"
  echo "  --port          The default EXPOSED TCP port [Default: 3001]"
  echo "  --builder       Which binary to use to build the container [Default: docker] [docker|buildah]"
  echo "  --help          Display this message"
  echo " * = mandatory options"
  exit 0
}

catch() {
  if [ "$1" != "0" ]; then
    echo "An error has occured. Abording."
    exit 0
  fi
}

help=${help:-false}
node_version=${node_version:-}
user_name=${user_name:-cardano-node}
user_id=${user_id:-256}
group_name=${GROUP_NAME:-cardano-node}
group_id=${group_id:-256}
ghc_version=${ghc_version:-8.6.5}
cabal_version=${cabal_version:-3.2.0.0}
#os_arch=${os_arch:-x86_64}
os_arch="x86_64"
port=${port:-3001}
builder=${builder:-docker}

while [ $# -gt 0 ]; do
   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2" 2>/dev/null
   fi
  shift
done

if [ "$help" != false ]; then
  usage
fi

if [ -z "$node_version" ]; then
  usage
fi

if [ ! -x "$(command -v ${builder})" ]; then
  echo "Error: builder '${builder}' not found if \$PATH"
  exit 1
fi

build_path=$(echo "${PWD}/${node_version}/")
if [ ! -d "${build_path}" ]; then
  echo "Build path ${build_path} doesn't exist"
  exit 0
fi

echo ""
echo "!!! Verify carefully the options before continuing !!!"
echo ""
echo "node_version  : $node_version"
echo "user_name     : $user_name"
echo "user_id       : $user_id"
echo "group_name    : $group_name"
echo "group_id      : $group_id"
echo "ghc_version   : $ghc_version"
echo "cabal_version : $cabal_version"
echo "os_arch       : $os_arch"
echo "port          : $port"
echo "builder       : $builder"
echo ""

read -n 1 -s -r -p "Press any key to continue"
echo ""

tag="cardano-node:${node_version}"

echo "Cleaning local repository ${tag}..."
set +e
buildah rmi "localhost/${tag}" 2>/dev/null
set -e

echo "Building image ${tag}..."

case "${builder}" in
   "docker")
      docker build --tag ${tag} --build-arg NODE_VERSION=${node_version} --build-arg USER_NAME=${user_name} \
                   --build-arg USER_ID=${user_id} --build-arg GROUP_NAME=${group_name} --build-arg GROUP_ID=${group_id} \
		   --build-arg GHC_VERSION=${ghc_version} --build-arg CABAL_VERSION=${cabal_version} \
		   --build-arg OS_ARCH=${os_arch} --build-arg PORT=${port} ${build_path}
      ;;
   "buildah")
       buildah bud --layers --tag ${tag} --build-arg NODE_VERSION=${node_version} --build-arg USER_NAME=${user_name} \
                   --build-arg USER_ID=${user_id} --build-arg GROUP_NAME=${group_name} --build-arg GROUP_ID=${group_id} \
		   --build-arg GHC_VERSION=${ghc_version} --build-arg CABAL_VERSION=${cabal_version} \
		   --build-arg OS_ARCH=${os_arch} --build-arg PORT=${port} ${build_path}
      ;;
esac

echo "Image built ${tag}..."
buildah images | grep -i "cardano-node"
