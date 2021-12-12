# Buildkite log downloader/test failure stats reporter

Download logs via the buildkite API, counts test failures.

# Scope
This script is scoped to only run against Buildkite E2E regression test jobs containing `compliance_service`.

## Modifying to run against your services
To run against services that are _not_ compliance service, change `compliance_service` in the `jq` params to your service's job name (example: `🔨 my_service Tests [SIT]` you would use `my_service`)


# Rerequisites
- Valid BuildKite API key set as `BK_API_KEY` environmant variable and has access to organization and read access to:
  - Read Agents
  - Read Teams
  - Read Artifacts
  - Read Builds
  - Read Job and Environment variables
  - Read Job Logs
  - Read Organizations
  - Read Pipelines
  - Read User

# Usage
Create a Buildkite API token that has read access to the pipeline(s) you're
interested in. Add it to `count_test_file_failures.sh`, and set some other
parameters in that file.

Run `./count_test_file_failures.sh`.

Wait.

# todo
- Currently limited to the latest 100 builds, as the scripts don't support
  pagination in the buildkite API
- Use [sumologic reporter](https://webdriver.io/docs/sumologic-reporter/)
- confirm read access requirments