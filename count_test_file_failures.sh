#!/bin/bash
#
# Prints regression test failure counts, grouped by test file. Downloads all
# logs from the given date (up to 100 builds), so may take a while.

## SECRET!!!! ##
# Either define your BuildKite API key here, or set as an env variable under BK_API_KEY
access_token=$BK_API_KEY

## Configure your details here
org=myob
pipeline=compliance-regression-tests
created_from=2021-12-13T00:00:00Z
url="https://api.buildkite.com/v2/organizations/${org}/pipelines/${pipeline}/builds?branch=master&created_from=${created_from}&include_retried_jobs=true&per_page=100"

function get_builds {
    curl \
        -H "Authorization: Bearer ${access_token}" \
        $url
}

function extract_test_runs {
    #jq --raw-output '...'
    # .[] |                                             - take all indecies and pipe them to the next part (below)
    # (.number|tostring)                                - extract top level (all array items) and matches converts ".number" to string.
    # + " " +                                           - appends empty space
    # (.jobs[] | select(.started_at != null) |          - Find all get the .jobs fields and pipe them to the select 
    #                                                       statement - select statement gets all items in .jobs where .started_at is not null, pipe the result
    # select(.name | contains("compliance_service"))    - Selects all .name fields that contain "compliance_service" in jobs[]
    # .id + " " + .name)                                - get .id and .name and append empty space between them
    
    # grep -i                                           - grep and ignore case
    # sort -k 4                                         - sort at key position 4

    jq -r '.[] | (.number|tostring) + " " + (.jobs[] | select(.started_at != null) | select(.name | contains("compliance_service")) | .id + " " + .name )' | grep -i "run.*tests" | sort -k 4
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

if [ ! -d "./logs" ]
then
    mkdir "./logs"
fi

cat test_runs.txt |
while read test_run; do
    build_num="$(echo $test_run | cut -d' ' -f 1)"
    job_id="$(echo $test_run | cut -d' ' -f 2)"
    test_name="$(echo $test_run | cut -d' ' -f 4- | tr -d ' ')"
    mkdir -p "logs/$test_name"
    download_log $build_num $job_id "logs/$test_name/$build_num-$job_id"
done

grep -roh "FAILED.*" logs | sort | uniq -c | sort -r


# ideal situation:
# [-] - make script more readable!
# [x] - filter out the compliance regression suite and run against those
#       [x] - (BUILDKITE_LABEL=":hammer: Run AU-compliance_service Tests [SIT]")
# [?] - ioutput to list only (maybe csv)
