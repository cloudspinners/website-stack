load "${BATS_HELPER_DIR}/bats-support/load.bash"
load "${BATS_HELPER_DIR}/bats-assert/load.bash"


setup_file() {
    >&3 echo "setup_file started"
    export AWS_ACCESS_KEY_ID=${AWS_SANDBOX_ACCESS_KEY_ID}
    export AWS_SECRET_ACCESS_KEY=${AWS_SANDBOX_SECRET_ACCESS_KEY}
    >&3 echo "setup_file completed"
}


@test "The AWS sandbox credentials are provided in the environment" {
  refute [ -z ${AWS_ACCESS_KEY_ID+x} ]
  refute [ -z ${AWS_SECRET_ACCESS_KEY+x} ]
  # refute [ -z ${AWS_SANDBOX_ACCESS_KEY_ID+x} ]
  # refute [ -z ${AWS_SANDBOX_SECRET_ACCESS_KEY+x} ]
}


@test "The aws cli can use the AWS API" {
    run aws s3api list-buckets
    echo "command: $BATS_RUN_COMMAND"
    echo "output: $output"
    assert_success
}

