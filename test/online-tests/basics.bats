load "${BATS_HELPER_DIR}/bats-support/load.bash"
load "${BATS_HELPER_DIR}/bats-assert/load.bash"


setup_file() {
    >&3 echo "setup_file started"
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY

    echo "mkdir -p ~/.aws"
    mkdir -p ~/.aws
    echo "
[spintools_aws]
aws_access_key_id=${AWS_SANDBOX_ACCESS_KEY_ID}
aws_secret_access_key=${AWS_SANDBOX_SECRET_ACCESS_KEY}
" > ~/.aws/credentials
    >&3 echo "Running stack-spin up to create resources"
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

