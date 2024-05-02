#!/bin/bash

components=$1
versionBump=$2
returnedVersions=()

split_docker_tag()
{
  # Take a #.#.#.# tag and split it down to being ####
  IFS="."
  read -ra splitVersions <<< "$1"
  for splitVersion in "${splitVersions[@]}"; do
    version+="$splitVersion"
  done
  echo "$version"
}
increase_docker_tag()
{
    # Take a #.#.#.# tag and split it down, increase a version depending on the value of VersionBump and recreate a #.#.#.# version
    IFS="."
    read -ra splitVersions <<< "$1"
    case $versionBump in
      major)
        (( splitVersions[0]++ ))
        splitVersions[1]=0
        splitVersions[2]=0
        ;;
      minor)
        (( splitVersions[1]++ ))
        splitVersions[2]=0
        ;;
      patch)
        (( splitVersions[2]++ ))
        ;;
      bug)
        (( splitVersions[3]++ ))
        ;;
    esac
    for splitVersion in "${splitVersions[@]}"; do
      version+="$splitVersion."
    done
    # Remove the trailing . created above
    version=${version:0:-1}
    echo "$version"
}
get_docker_tags()
{
  # Get all the docker tags within a registry, that either has a #.#.#.# or #.#.#.#-rc# format, compare the results and return the highest value
  registry=$1
  versionBump=$2

  foundVersions=()
  if [ "$versionBump" != "bug" ]; then
    tagMatch="^[0-9]+\.[0-9]+\.[0-9]+$"
  else
    tagMatch="^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$"
  fi
  # Get the list of tags
  existingTags=$(gcloud container images list-tags "$registry" --format=json)
  # Add tags into an array
  mapfile -t tags_array< <(echo "$existingTags" | jq -r '.[].tags[]')
  # Search for existing version
  for existingTag in "${tags_array[@]}"; do
    # Only want tags that match the input
    if [[ "$existingTag" =~ $tagMatch ]]; then
      foundVersions+=("$existingTag")
    fi
  done
  # Split the version and compare to find what is the highest tag version
  if [[ -n "${foundVersions[*]}" ]]; then
    highestTag=${foundVersions[0]}
    splitTag=$(split_docker_tag "$highestTag")
    for foundVersion in "${foundVersions[@]}" ; do
       compareSplitTag=$(split_docker_tag "$foundVersion")
       if [[ $compareSplitTag -gt $splitTag ]]; then
         highestTag=$foundVersion
       fi
    done
  fi
  # Return the highest tag version found within the registry
  echo "$highestTag"
}

for component in $components; do
  # Force lowercase
  component=$(echo "$component" | tr "[:upper:]" "[:lower:]")
  case $component in
    core)
      registry="europe-west4-docker.pkg.dev/sbat-gcr-release/sapig-docker-artifact/securebanking/sapig-core"
      ;;
    ig)
      registry="europe-west4-docker.pkg.dev/sbat-gcr-release/sapig-docker-artifact/securebanking/ig"
      ;;
    rcs)
      registry="europe-west4-docker.pkg.dev/sbat-gcr-release/sapig-docker-artifact/securebanking/securebanking-openbanking-uk-rcs"
      ;;
    rs)
      registry="europe-west4-docker.pkg.dev/sbat-gcr-release/sapig-docker-artifact/securebanking/securebanking-openbanking-uk-rs"
      ;;
    rcsui)
      registry="europe-west4-docker.pkg.dev/sbat-gcr-release/sapig-docker-artifact/securebanking/ui/rcs"
      ;;
    tdi)
      registry="europe-west4-docker.pkg.dev/sbat-gcr-release/sapig-docker-artifact/securebanking/securebanking-test-data-initializer"
      ;;
    func)
      registry="europe-west4-docker.pkg.dev/sbat-gcr-release/sapig-docker-artifact/securebanking/uk-functional-tests"
      ;;
    dcr)
      registry="europe-west4-docker.pkg.dev/sbat-gcr-release/sapig-docker-artifact/securebanking/uk-conformance-dcr"
      ;;
    esac
  # Get the highest correctly formatted version from a registry
  returnedVersions+=("$(get_docker_tags "$registry" "$versionBump")")
done

# Make sure there have been some values returned
# If a matching value has been found
if [[ -n "${returnedVersions[*]}" ]]; then
  # Set highest tag as the first returned value
  highestTag=${returnedVersions[0]}
  # Split the tag so that is can be compared as an integer
  splitTag=$(split_docker_tag "${highestTag}")
  # For each of the other tags found in returnedVersions
  for foundVersion in "${returnedVersions[@]}" ; do
     # Split the next tag to be compared
     compareSplitTag=$(split_docker_tag "$foundVersion")
     # Compare the integer value ie 2.3.1.1 -> 2311 & 2.3.1.3 > 2313 2.3.1.3 is the higher
     if [[ $compareSplitTag -gt $splitTag ]]; then
       # Use the #.#.#.# version in highestVersion
       highestTag=$foundVersion
     fi
  done
  # Bump the version depending on what the value of versionBump is
  highestTag=$(increase_docker_tag "$highestTag" "$versionBump")
else
  highestTag="1.0.0"
fi

echo "$highestTag"