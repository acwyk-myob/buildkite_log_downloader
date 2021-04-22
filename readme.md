# Buildkite log downloader/test failure stats reporter

Download logs via the buildkite API, counts test failures.

Run `./count_test_file_failures.sh`. That's it!

# todo
- Currently limited to the latest 100 builds, as the scripts don't support
  pagination in the buildkite API
- Use [sumologic reporter](https://webdriver.io/docs/sumologic-reporter/)
