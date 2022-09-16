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
    >&3 echo "Running stack-spin up to create resources"
    # stack-spin -i instances/online-instance.yml up
    >&3 echo "setup_file completed"
}


@test "The s3 bucket exists" {
    run aws --profile spintools_aws s3api get-bucket-location --bucket "spinsite-cloudspin.xyz-online.dev.cloudspin.xyz-online123"
    echo "command: $BATS_RUN_COMMAND"
    echo "output: $output"
    assert_success
}


@test "Can reach upload a page and then access it through the http endpoint" {
    run aws --profile spintools_aws s3 cp test/content/index.html "s3://spinsite-cloudspin.xyz-online.dev.cloudspin.xyz-online123/"
    echo "command: $BATS_RUN_COMMAND"
    echo "output: $output"
    assert_success

    run curl -s "https://s3.us-east-2.amazonaws.com/spinsite-cloudspin.xyz-online.dev.cloudspin.xyz-online123/index.html"
    echo "command: $BATS_RUN_COMMAND"
    echo "output: $output"
    assert_output --partial "Hello there"
}


teardown_file() {
    >&3 echo "Running stack-spin down to destroy the resources"
    # stack-spin -i instances/online-instance.yml down
}
