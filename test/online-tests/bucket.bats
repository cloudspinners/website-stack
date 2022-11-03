load "${BATS_HELPER_DIR}/bats-support/load.bash"
load "${BATS_HELPER_DIR}/bats-assert/load.bash"
load "/opt/spin-tools/lib/spin-bats-support.bash"


setup_file() {
    test_out "setup for online testing"
    instance_configuration
    setup_real_aws_credentials
    assert [ -n "${AWS_ACCESS_KEY_ID}" ]

    test_out "Spinning the online test stack up using ${INSTANCE_CONFIGURATION_FILE}"
    stack-spin -i ${INSTANCE_CONFIGURATION_FILE} up
    test_out "stack-spin up has returned"

    export S3_BUCKET_NAME=$(yq -r .website_bucket_name.value _tmp/stack-output-values.json)
    export WEBSITE_HOSTNAME=$(yq -r .website_hostname.value _tmp/stack-output-values.json)
}


@test "The AWS credentials are provided in the expected environment variables" {
    refute [ -z "${AWS_SANDBOX_ACCESS_KEY_ID}" ]
    refute [ -z "${AWS_SANDBOX_SECRET_ACCESS_KEY}" ]
}


@test "The AWS access key id looks like an AWS access key id" {
    assert [ "${AWS_SANDBOX_ACCESS_KEY_ID:0:4}" == "AKIA" ]
}


@test "The aws cli can use the AWS API" {
    run aws s3api list-buckets
    echo "command: $BATS_RUN_COMMAND"
    echo "output: $output"
    assert_success
}


@test "The s3 bucket exists" {
    refute [ -z "${S3_BUCKET_NAME}" ]
    run aws --output json s3api get-bucket-location --bucket "${S3_BUCKET_NAME}"
    echo "command: $BATS_RUN_COMMAND"
    echo "output: $output"
    assert_success
}


@test "The hostname is found" {
    run host "${WEBSITE_HOSTNAME}"
    echo "command: $BATS_RUN_COMMAND"
    echo "output: $output"
    assert_success
}


@test "Can upload a page and then access it through the http endpoint and hostname" {
    S3_BUCKET_ENDPOINT=$(jq -r '.website_bucket_endpoint.value' ./_tmp/stack-output-values.json)

    run aws s3 cp test/content/index.html "s3://${S3_BUCKET_NAME}/"
    echo "command: $BATS_RUN_COMMAND"
    echo "output: $output"
    assert_success

    run curl -s "http://${S3_BUCKET_ENDPOINT}/index.html"
    echo "command: $BATS_RUN_COMMAND"
    echo "output: $output"
    assert_output --partial "Hello there"

    SITE_HOSTNAME=$(jq -r '.website_hostname.value' ./_tmp/stack-output-values.json)
    run curl -s "http://${SITE_HOSTNAME}/index.html"
    echo "command: $BATS_RUN_COMMAND"
    echo "output: $output"
    assert_output --partial "Hello there"
}


teardown_file() {
    test_out "Spinning the online test stack down"
    stack-spin -i ${INSTANCE_CONFIGURATION_FILE} down
    test_out "stack-spin down has returned"
}

