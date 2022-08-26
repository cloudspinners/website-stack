load "${BATS_HELPER_DIR}/bats-support/load.bash"
load "${BATS_HELPER_DIR}/bats-assert/load.bash"


# setup_file() {
#     >&2 echo "Running stack-spin up to create resources"
#     stack-spin -i instances/offline-instance.yml -s ./src up >&2
# }


# @test "The s3 bucket exists" {
#     run aws --endpoint-url=http://localstack:4566 s3api get-bucket-location --bucket "spinsite-example-website-xyz-offline-123"
#     echo "output: $output"
#     assert_success
# }


# teardown_file() {
#     >&2 echo "Running stack-spin down to destroy the resources"
#     stack-spin -i instances/offline-instance.yml -s ./src down >&2
# }
