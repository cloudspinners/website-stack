load "${BATS_HELPER_DIR}/bats-support/load.bash"
load "${BATS_HELPER_DIR}/bats-assert/load.bash"


setup_file() {
    mkdir -p ~/.aws
    echo "
[spintools_aws]
aws_access_key_id=${AWS_SANDBOX_ACCESS_KEY_ID}
aws_secret_access_key=${AWS_SANDBOX_SECRET_ACCESS_KEY}
" > ~/.aws/credentials
    >&2 echo "Running stack-spin up to create resources"
    stack-spin -i instances/online-instance.yml up >&2
}


@test "The aws cli can use the AWS API" {
    run aws --profile spintools_aws s3api list-buckets
    echo "output: $output"
    assert_success
}


@test "The s3 bucket exists" {
    run aws --profile spintools_aws s3api get-bucket-location --bucket "spinsite-cloudspin.xyz-online.dev.cloudspin.xyz-online123"
    echo "output: $output"
    assert_success
}


@test "Can reach upload a page and then access it through the http endpoint" {
    run aws --profile spintools_aws s3 cp test/content/index.html "s3://spinsite-cloudspin.xyz-online.dev.cloudspin.xyz-online123/"
    echo "output: $output"
    assert_success

    run curl -s "https://s3.us-east-2.amazonaws.com/spinsite-cloudspin.xyz-online.dev.cloudspin.xyz-online123/index.html"
    echo "output: $output"
    assert_output --partial "Hello there"
}


teardown_file() {
    >&2 echo "Running stack-spin down to destroy the resources"
    stack-spin -i instances/online-instance.yml -s ./src down >&2
}
