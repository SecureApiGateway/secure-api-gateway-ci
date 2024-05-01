#!/bin/bash

repo=$1
version=$2
rcNumber=1
foundVersions=()
# Get the list of tags
existingTags=$(gcloud container images list-tags "$repo" --format=json)
# Add tags into an array
mapfile -t tags_array< <(echo "$existingTags" | jq -r '.[].tags[]')
# Search for existing version
for existingTag in "${tags_array[@]}"; do
  # Only want tags that match the input
  if [[ "$existingTag" =~ ^[0-9]+\.[0-9]+\.[0-9]+\-rc[0-9]+$ ]]; then
    if [[ "$existingTag" =~ $version ]]; then
      foundVersions+=("$(echo "$existingTag" | grep -Eo '[0-9]+$')")
    fi
  fi
done

if [[ -n "${foundVersions[*]}" ]]; then
  rcNumber=${foundVersions[0]}
  for n in "${foundVersions[@]}" ; do
      ((n > rcNumber)) && rcNumber=$n
  done
  # Increment number by 1
  rcNumber=$(("$rcNumber"+1))
fi

# Return the number to be used in comparison with other numbers in workflow
echo "$rcNumber"