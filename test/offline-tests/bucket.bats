load "${BATS_HELPER_DIR}/bats-support/load.bash"
load "${BATS_HELPER_DIR}/bats-assert/load.bash"
load "/opt/spin-tools/lib/spin-bats-support.bash"


setup_file() {
    test_out "Running stack-spin up to create resources"
    ZONE_ID=$(aws \
        --endpoint-url=http://localstack:4566 \
        route53 create-hosted-zone \
        --name example-website-xyz \
        --caller-reference r1 | \
        jq -r '.HostedZone.Id')
    stack-spin -i instances/offline-instance.yml -s ./src up
}


@test "The s3 bucket exists" {
    run aws --endpoint-url=http://localstack:4566 s3api get-bucket-location --bucket "offline.example-website-xyz"
    echo "command: $BATS_RUN_COMMAND"
    echo "output: $output"
    assert_success
}


teardown_file() {
    test_out "Running stack-spin down to destroy the resources"
    stack-spin -i instances/offline-instance.yml -s ./src down
    aws --endpoint-url=http://localstack:4566 route53 delete-hosted-zone --id ${ZONE_ID}
}
