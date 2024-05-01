#!/bin/bash

components=$1
version=$2
returnedVersions=()
for component in $components; do
  component=$(echo "$component" | tr "[:upper:]" "[:lower:]")
  case $component in
    core)
      repo="europe-west4-docker.pkg.dev/sbat-gcr-release/sapig-docker-artifact/securebanking/sapig-core"
      ;;
    ig)
      repo="europe-west4-docker.pkg.dev/sbat-gcr-release/sapig-docker-artifact/securebanking/ig"
      ;;
    rcs)
      repo="europe-west4-docker.pkg.dev/sbat-gcr-release/sapig-docker-artifact/securebanking/securebanking-openbanking-uk-rcs"
      ;;
    rs)
      repo="europe-west4-docker.pkg.dev/sbat-gcr-release/sapig-docker-artifact/securebanking/securebanking-openbanking-uk-rs"
      ;;
    rcsui)
      repo="europe-west4-docker.pkg.dev/sbat-gcr-release/sapig-docker-artifact/securebanking/ui/rcs"
      ;;
    tdi)
      repo="europe-west4-docker.pkg.dev/sbat-gcr-release/sapig-docker-artifact/securebanking/securebanking-test-data-initializer"
      ;;
    func)
      repo="europe-west4-docker.pkg.dev/sbat-gcr-release/sapig-docker-artifact/securebanking/uk-functional-tests"
      ;;
    dcr)
      repo="europe-west4-docker.pkg.dev/sbat-gcr-release/sapig-docker-artifact/securebanking/uk-conformance-dcr"
      ;;
    *)
      echo "Warning, component not known"
      exit 1
      ;;
    esac
  returnedVersions+=("$(./scripts/docker-find-rc-version.sh "$repo" "$version")")
done

max=${returnedVersions[0]}
for n in "${returnedVersions[@]}" ; do
    ((n > max)) && max=$n
done

echo "$max"