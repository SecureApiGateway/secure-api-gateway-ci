# secure-api-gateway-ci  
NOTE:This repository is for internal PingID use only, and not designed for customers to base their deployments on.
## Individual Components
### conformance-dcr
[![Merge - Build and Deploy](https://github.com/SecureApiGateway/conformance-dcr/actions/workflows/merge.yml/badge.svg)](https://github.com/SecureApiGateway/conformance-dcr/actions/workflows/merge.yml)
### fr-platform-config
[![Check Json Order](https://github.com/SecureApiGateway/fr-platform-config/actions/workflows/merge.yml/badge.svg)](https://github.com/SecureApiGateway/fr-platform-config/actions/workflows/merge.yml)
### sapig-openbanking-uk-developer-envs
[![Check Json Order](https://github.com/SecureApiGateway/sapig-openbanking-uk-developer-envs/actions/workflows/merge.yml/badge.svg)](https://github.com/SecureApiGateway/sapig-openbanking-uk-developer-envs/actions/workflows/merge.yml)
### secure-api-gateway-core
[![Merge - Build and Deploy](https://github.com/SecureApiGateway/secure-api-gateway-core/actions/workflows/merge.yml/badge.svg)](https://github.com/SecureApiGateway/secure-api-gateway-core/actions/workflows/merge.yml)
### secure-api-gateway-ob-uk
[![Merge - Build and Deploy](https://github.com/SecureApiGateway/secure-api-gateway-ob-uk/actions/workflows/merge.yml/badge.svg)](https://github.com/SecureApiGateway/secure-api-gateway-ob-uk/actions/workflows/merge.yml)
### secure-api-gateway-ob-uk-common
[![Merge - Build and Deploy](https://github.com/SecureApiGateway/secure-api-gateway-ob-uk-common/actions/workflows/merge.yml/badge.svg)](https://github.com/SecureApiGateway/secure-api-gateway-ob-uk-common/actions/workflows/merge.yml)
[![CodeQL](https://github.com/SecureApiGateway/secure-api-gateway-ob-uk-common/actions/workflows/codeql.yml/badge.svg)](https://github.com/SecureApiGateway/secure-api-gateway-ob-uk-common/actions/workflows/codeql.yml)
### secure-api-gateway-ob-uk-fidc-initializer
[![Merge - Build and Deploy](https://github.com/SecureApiGateway/secure-api-gateway-ob-uk-fidc-initializer/actions/workflows/merge.yml/badge.svg)](https://github.com/SecureApiGateway/secure-api-gateway-ob-uk-fidc-initializer/actions/workflows/merge.yml)
### secure-api-gateway-ob-uk-functional-tests
[![Merge - Build and Deploy](https://github.com/SecureApiGateway/secure-api-gateway-ob-uk-functional-tests/actions/workflows/merge.yml/badge.svg)](https://github.com/SecureApiGateway/secure-api-gateway-ob-uk-functional-tests/actions/workflows/merge.yml)
### secure-api-gateway-ob-uk-rcs
[![Merge - Build and Deploy](https://github.com/SecureApiGateway/secure-api-gateway-ob-uk-rcs/actions/workflows/merge.yml/badge.svg)](https://github.com/SecureApiGateway/secure-api-gateway-ob-uk-rcs/actions/workflows/merge.yml)
[![CodeQL](https://github.com/SecureApiGateway/secure-api-gateway-ob-uk-rcs/actions/workflows/codeql.yml/badge.svg)](https://github.com/SecureApiGateway/secure-api-gateway-ob-uk-rcs/actions/workflows/codeql.yml)
### secure-api-gateway-ob-uk-rs
[![Merge - Build and Deploy](https://github.com/SecureApiGateway/secure-api-gateway-ob-uk-rs/actions/workflows/merge.yml/badge.svg)](https://github.com/SecureApiGateway/secure-api-gateway-ob-uk-rs/actions/workflows/merge.yml)
[![CodeQL](https://github.com/SecureApiGateway/secure-api-gateway-ob-uk-rs/actions/workflows/codeql.yml/badge.svg)](https://github.com/SecureApiGateway/secure-api-gateway-ob-uk-rs/actions/workflows/codeql.yml)
### secure-api-gateway-ob-uk-test-data-initializer
[![Merge - Build and Deploy](https://github.com/SecureApiGateway/secure-api-gateway-ob-uk-test-data-initializer/actions/workflows/merge.yml/badge.svg)](https://github.com/SecureApiGateway/secure-api-gateway-ob-uk-test-data-initializer/actions/workflows/merge.yml)
### secure-api-gateway-ob-uk-ui
[![merge-master](https://github.com/SecureApiGateway/secure-api-gateway-ob-uk-ui/actions/workflows/merge.yml/badge.svg)](https://github.com/SecureApiGateway/secure-api-gateway-ob-uk-ui/actions/workflows/merge.yml)
### secure-api-gateway-parent
[![Merge - Build and Deploy](https://github.com/SecureApiGateway/secure-api-gateway-parent/actions/workflows/merge.yml/badge.svg)](https://github.com/SecureApiGateway/secure-api-gateway-parent/actions/workflows/merge.yml)
### secure-api-gateway-release
### secure-api-gateway-release-helpers
## Nightly Builds 
[![Nightly Build](https://github.com/SecureApiGateway/secure-api-gateway-ci/actions/workflows/nightly-build.yml/badge.svg)](https://github.com/SecureApiGateway/secure-api-gateway-ci/actions/workflows/nightly-build.yml)

This action will trigger each morning before the cluster is deployed. 

Its purpose is to build each individual component from new (uses the -U option in the maven build command).

This will allow us to spot any potential issues from changes made in dependant repositories and ensure our development team are working on the very latest images each morning. 

## CI/CD

Within this repo, there is the idea of having reusable workflows, which our individual components repo will use when performing actions, such as `PR`, `Merge` & `Release`. 

The individual components check out this repo, as well as their own. The workflow for the individual components are as basic as can be. For example;

```
name: PR - Build and Deploy
on:
  pull_request:
    branches:
      - main
    paths-ignore:
      - '**/README.md'
jobs:
  run_pr-template:
    name: PR - Build and Deploy
    uses: SecureApiGateway/secure-api-gateway-ci/.github/workflows/reusable-pr.yml@main
    secrets: inherit
    with:
      componentName: secure-api-gateway-core
      dockerTag: pr-${{ github.event.number }}
```

What may differ from repo to repo is
- branches name
- paths-ignore
- componentName

There is no versioning within this part of the workflow by design. This is so that within the secure-api-gateway-ci repo, there is a `component-config` folder, which has many `.env` files. The reusable workflows use the `componentName` passed from the calling workflow, to retrieve the corresponding .env file within the folder. The `.env` files will have various different variables within, such as `JAVA_DISTRIBUTION`,`SERVICE_NAME` and `SAPIG_TYPE`. There are also `STEPS_PR_*` and `STEPS_MERGE_*` variables which control which actions in the reusable workflow are ran. 

For example using our `Core` repo again, we need to build a docker image, and build the maven project os that we get artifacts produced. Within the `.env` file we have `STEPS_MERGE_BUILD_DOCKER_IMAGE`,`STEPS_MERGE_BUILD_MAVEN_PROJECT` set to `true`. We don't want functional tests to run so `STEPS_MERGE_RUN_FUNCTIONAL_TESTS` is set to `false`. 

The main improvement for this way of structuring our workflows, is that if a change is needed to go to a newer version of Java for example, instead of checking out each individual component repository which uses java, making the change, creating a PR, getting the PR approved, and finally merging, we can create one PR with in the CI repo, with one PR.

We are also getting the additional security of requiring PRs to be reviewed before a change like this is able to be made, if github variables|secrets were used for this, then there wouldn't be anything stopping someone changing the value of the variable, if they had the required permissions. 

