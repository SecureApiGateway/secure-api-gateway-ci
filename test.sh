#!/bin/bash

versionBump="patch"
sapigType="ob"
# Check if sapigType is either core or ob
sapigType=$(echo "$sapigType" | tr "[:upper:]" "[:lower:]")
versionBump=$(echo "$versionBump" | tr "[:upper:]" "[:lower:]")

if [ "$versionBump" != "major" ] && [ "$versionBump" != "minor" ] && [ "$versionBump" != "patch" ] && [ "$versionBump" != "bug" ]; then
  echo "Warning: versionBump can only be Major | Minor | Patch | Bug "
  exit 1
fi
if [ "$sapigType" != "core" ] && [ "$sapigType" != "ob" ]; then
  echo "Warning: sapigType can only be 'ob' or 'core'"
  exit 1
fi
if [ "$sapigType" == "core" ]; then
  echo "Core Components to be built; Core"
  components="Core"
else
  echo "OB Components to be built; IG, RCS, RS, RCS-UI, Test Data Initializer, Functional Tests & DCR Conformance Tests"
  components="IG RCS RS RCSUI TDI FUNC DCR"
fi
versionToUse=$(./scripts/docker-get-next-version.sh "$components" "$versionBump")
echo "Use '$versionToUse' in the release workflows"