#!/bin/bash

version="3.0.0"
# Check if sapigType is either core or ob
sapigType=$(echo "ob" | tr "[:upper:]" "[:lower:]")
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
versionToUse=$(./scripts/docker-get-max-rc-version.sh "$components" "$version")
echo "Creating rc$versionToUse"