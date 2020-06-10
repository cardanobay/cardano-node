#!/bin/sh

set -e
trap 'catch $? $LINENO' EXIT

usage() {
  echo "Usage: $0 --tag <tag>"
  echo "  Tag a specific version of Cardano Node container as latest."
  echo ""
  echo "Available options:"
  echo " *--tag           The cardano-node container tag [Default: none] [Example: 1.13.0]"
  echo "  --help          Display this message"
  echo " * = mandatory options"
  exit 0
}

catch() {
  if [ "$1" != "0" ]; then
    echo "An error has occured, please verify the options"
    usage
  fi
}

help=${help:-false}
tag=${tag:-}

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

if [ -z "$tag" ]; then
  usage
fi

echo ""
echo "Check the options before continuing :"
echo "tag           : $tag"
echo ""

read -n 1 -s -r -p "Press any key to continue"
echo ""

if [ ! -d "./$tag" ]; then
  echo "Directory ./${tag} doesn't exist"
  exit 0
fi

echo "Tagging cardano-node:${tag} as cardano-node:latest"
podman image tag localhost/cardano-node:${tag} localhost/cardano-node:latest

echo "Copying content of ./${tag} to ./latest"
rm -rf ./latest
cp -R ./${tag} ./latest
