          sapigType=$(echo "${{ inputs.sapigType }}" | tr "[:upper:]" "[:lower:]")
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
          versionToUse=$(./scripts/docker-get-max-rc-version.sh "$components" "$versionToChange" )
          slackMessage="The next available version to use for a ${{ inputs.versionToChange }} release is : $versionToUse"
          curl -X POST -H "Content-type: application/json" --data '{"text": "'"$slackMessage"'"}' "${{ env.SLACK_WEBHOOK }}" || echo "ERROR - Could not send message"