#!/bin/bash

makePackage()
{
  if test -f "$1"/Chart.yaml; then
    version=$(docker run --rm -v "${PWD}":/workdir mikefarah/yq:3.4.1 yq r "$1"/Chart.yaml version)
    make package_helm name="$1" version="$version"
  else
    echo "No Chart.yaml file in $1"
  fi
}

createPackage()
{
  for rootDir in */ ; do
    # Remove a trailing / if it exists
    dir=${rootDir%/}
    # Dont want Kustomize to run
    if [ "$dir" != "postman" ]; then
      if [ "$dir" == "ob" ] || [ "$dir" == "core" ]; then
        cd "$dir" || exit
        for subDir in */ ; do
          # Remove a trailing / if it exists
          subdir=${subDir%/}
          if [ "$subdir" != "kustomize" ]; then
            helmFile=$subdir
          fi
        done
        cd ../
        makePackage "$dir/$helmFile"
      else
        makePackage "$dir"
      fi
    fi
  done
}

publishPackage()
{
  for tgz in *.tgz
  do
    [[ -e "$tgz" ]] || break  # handle the case of no *.tgz files
    make publish_helm name="$tgz"
  done
}

"$@"