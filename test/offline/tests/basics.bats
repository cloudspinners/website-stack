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
    test_out "Seup done"
}


@test "Something is listening on the localstack port" {
    run curl -s --show-error \
                            --retry 20 \
                            --retry-all-errors \
                            --retry-connrefused \
                            --connect-timeout 5 \
                            --retry-delay 2 \
                            --retry-max-time 30 \
                            --verbose \
                            "${localstack_endpoint}"
    echo "command: $BATS_RUN_COMMAND"
    echo "output: $output"
    assert_equal "$status" 0
}


@test "AWS cli can connect to localstack" {
    run aws --endpoint-url=${localstack_endpoint} ssm describe-parameters
    echo "command: $BATS_RUN_COMMAND"
    echo "output: $output"
    assert_success
}


@test "Running plan on the stack shows that changes are needed" {
    run stack-spin -v -i ${TEST_STACK_INSTANCE_SPECFILE} -s ${TEST_STACK_SOURCE} plan
    echo "command: $BATS_RUN_COMMAND"
    echo "output: $output"
    assert_failure 2
}


teardown_file() {
    test_out "Removing the hosted zone"
    aws --endpoint-url=${localstack_endpoint} route53 delete-hosted-zone --id ${ZONE_ID} || :
    test_out "Cleaning up stack files"
    run stack-spin -v -i ${TEST_STACK_INSTANCE_SPECFILE} -s ${TEST_STACK_SOURCE} clean
}

