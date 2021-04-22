# Buildkite log downloader/test failure stats reporter

Download logs via the buildkite API, counts test failures.

# Usage
Create a token that has read access to the pipeline(s) you're interested in.
Add it to `count_test_file_failures.sh`, and set some other parameters in that
file.

Run `./count_test_file_failures.sh`.

Wait.

# todo
- Currently limited to the latest 100 builds, as the scripts don't support
  pagination in the buildkite API
- Use [sumologic reporter](https://webdriver.io/docs/sumologic-reporter/)
