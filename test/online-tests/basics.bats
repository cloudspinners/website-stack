load "${BATS_HELPER_DIR}/bats-support/load.bash"
load "${BATS_HELPER_DIR}/bats-assert/load.bash"


setup_file() {
    >&3 echo "setup_file started"
    >&3 echo "mkdir -p ~/.aws"
    >&3 mkdir -p ~/.aws
    echo "
[spintools_aws]
aws_access_key_id=${AWS_SANDBOX_ACCESS_KEY_ID}
aws_secret_access_key=${AWS_SANDBOX_SECRET_ACCESS_KEY}
" > ~/.aws/credentials
    >&3 echo "setup_file completed"
}


@test "The AWS sandbox credentials are provided in the environment" {
  refute [ -z ${AWS_SANDBOX_ACCESS_KEY_ID+x} ]
  refute [ -z ${AWS_SANDBOX_SECRET_ACCESS_KEY+x} ]
}

@test "The aws cli can use the AWS API" {
    run aws --profile spintools_aws s3api list-buckets
    echo "output: $output"
    assert_success
}

