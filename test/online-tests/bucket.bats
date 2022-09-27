load "${BATS_HELPER_DIR}/bats-support/load.bash"
load "${BATS_HELPER_DIR}/bats-assert/load.bash"

S3_BUCKET_NAME="spinsite-cloudspin-examples.com-online-test-online123"
S3_BUCKET_ENDPOINT="spinsite-cloudspin-examples.com-online-test-online123.s3-website.us-east-2.amazonaws.com"


setup_file() {
    >&3 echo "spinning the online stack up for testing"
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY

    echo "mkdir -p ~/.aws"
    mkdir -p ~/.aws
    echo "
[spintools_aws]
aws_access_key_id=${AWS_SANDBOX_ACCESS_KEY_ID}
aws_secret_access_key=${AWS_SANDBOX_SECRET_ACCESS_KEY}
" > ~/.aws/credentials

    stack-spin -i instances/online-instance.yml up
    >&3 echo "setup_file completed"
}


@test "The AWS credentials are provided in the expected environment variables" {
    refute [ -z "${AWS_SANDBOX_ACCESS_KEY_ID}" ]
    refute [ -z "${AWS_SANDBOX_SECRET_ACCESS_KEY}" ]
}


@test "The AWS access key id looks like an AWS access key id" {
    assert [ "${AWS_SANDBOX_ACCESS_KEY_ID:0:4}" == "AKIA" ]
}


@test "The aws cli can use the AWS API" {
    run aws --profile spintools_aws s3api list-buckets
    echo "command: $BATS_RUN_COMMAND"
    echo "output: $output"
    assert_success
}


@test "The s3 bucket exists" {
    run aws --output json --profile spintools_aws s3api get-bucket-location --bucket "${S3_BUCKET_NAME}"
    echo "command: $BATS_RUN_COMMAND"
    echo "output: $output"
    assert_success
}


@test "Can reach upload a page and then access it through the http endpoint" {
    run aws --profile spintools_aws s3 cp test/content/index.html "s3://${S3_BUCKET_NAME}/"
    echo "command: $BATS_RUN_COMMAND"
    echo "output: $output"
    assert_success

    run curl -s "http://${S3_BUCKET_ENDPOINT}/index.html"
    echo "command: $BATS_RUN_COMMAND"
    echo "output: $output"
    assert_output --partial "Hello there"
}

@test "The hostname is found" {
    run host online-test.cloudspin-examples.com
    echo "command: $BATS_RUN_COMMAND"
    echo "output: $output"
    assert_success
}

teardown_file() {
    >&3 echo "spinning the online stack down"
    stack-spin -i instances/online-instance.yml down
}
