load "${BATS_HELPER_DIR}/bats-support/load.bash"
load "${BATS_HELPER_DIR}/bats-assert/load.bash"
load "${SPIN_TOOLS_LIB_DIR}/spin-bats-support.bash"


setup_file() {
    test_out "Setup"
    export AWS_ACCESS_KEY_ID=$(get_spin_test_parameter_value "aws_access_key_id")
    export AWS_SECRET_ACCESS_KEY=$(get_spin_test_parameter_value "aws_secret_access_key")
    export AWS_REGION=us-east-2
    export TEST_FILES=$(readlink -f "${BATS_TEST_DIRNAME}/../files")

    test_out "Spinning up the test stack"
    spin_up_test_stack

    export S3_BUCKET_NAME=$(yq -r .website_bucket_name.value _tmp/stack-output-values.json)
    export WEBSITE_HOSTNAME=$(yq -r .website_hostname.value _tmp/stack-output-values.json)
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

    run aws s3 cp ${TEST_FILES}/index.html "s3://${S3_BUCKET_NAME}/"
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
    test_out "Running stack-spin down to destroy the resources"
    spin_down_test_stack
}
