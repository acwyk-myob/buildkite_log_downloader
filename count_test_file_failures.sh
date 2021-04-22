#!/bin/bash
#
# Prints regression test failure counts, grouped by test file. Downloads all
# logs from the given date (up to 100 builds), so may take a while.

## SECRET!!!! ##
access_token=<your buildkite API token goes here>

## Configure your details here
org=MY_ORG
pipeline=MY_PIPELINE
created_from=2021-04-20T00:00:00Z
url="https://api.buildkite.com/v2/organizations/${org}/pipelines/${pipeline}/builds?branch=master&created_from=${created_from}&include_retried_jobs=true&per_page=100"

function get_builds {
    curl \
        -H "Authorization: Bearer ${access_token}" \
        $url
}

# test
# cat demo_builds_output.json | jq -r '.[] | (.number|tostring) + " " + (.jobs[] | select(.started_at != null) | .id + " " + .name)'

function extract_test_runs {
    jq -r '.[] | (.number|tostring) + " " + (.jobs[] | select(.started_at != null) | .id + " " + .name)' | grep -i "run.*tests" | sort -k 4
}

function download_log {
    build_number=$1
    job_id=$2
    out_file=$3

    log_url="https://api.buildkite.com/v2/organizations/${org}/pipelines/${pipeline}/builds/${build_number}/jobs/${job_id}/log"
    echo $log_url
    echo $out_file

    curl \
    -H "Authorization: Bearer ${access_token}" \
    -H "Accept: text/plain" \
    $log_url \
    -o $out_file
}

get_builds | extract_test_runs | sort -k 4 > test_runs.txt

cat test_runs.txt |
while read test_run; do
    build_num="$(echo $test_run | cut -d' ' -f 1)"
    job_id="$(echo $test_run | cut -d' ' -f 2)"
    test_name="$(echo $test_run | cut -d' ' -f 4- | tr -d ' ')"
    mkdir -p "logs/$test_name"
    download_log $build_num $job_id "logs/$test_name/$build_num-$job_id"
done

grep -roh "FAILED.*" logs | sort | uniq -c | sort -r
