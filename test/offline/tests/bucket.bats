load "${BATS_HELPER_DIR}/bats-support/load.bash"
load "${BATS_HELPER_DIR}/bats-assert/load.bash"
load "${SPIN_TOOLS_LIB_DIR}/spin-bats-support.bash"


setup_file() {
    test_out "Setup"
    export AWS_ACCESS_KEY_ID=$(get_spin_test_parameter_value "aws_access_key_id")
    export AWS_SECRET_ACCESS_KEY=$(get_spin_test_parameter_value "aws_secret_access_key")
    export localstack_endpoint=$(get_spin_test_parameter_value "localstack_endpoint")
    export AWS_REGION=us-east-1

    test_out "Adding the hosted zone required by the stack"
    ZONE_ID=$(aws --endpoint-url=${localstack_endpoint} \
                            route53 create-hosted-zone \
                            --name example-website-xyz \
                            --caller-reference r1 \
                            | jq -r '.HostedZone.Id')

    test_out "Spinning up the test stack"
    spin_up_test_stack
}


@test "The s3 bucket exists" {
    run aws --endpoint-url=${localstack_endpoint} s3api get-bucket-location --bucket "offline.example-website-xyz"
    echo "command: $BATS_RUN_COMMAND"
    echo "output: $output"
    assert_success
}


teardown_file() {
    test_out "Running stack-spin down to destroy the resources"
    spin_down_test_stack
    test_out "Removing the hosted zone"
    aws --endpoint-url=${localstack_endpoint} route53 delete-hosted-zone --id ${ZONE_ID}
}

