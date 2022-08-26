load "${BATS_HELPER_DIR}/bats-support/load.bash"
load "${BATS_HELPER_DIR}/bats-assert/load.bash"

@test "Bucket exists after stack up" {
  run stack-spin -i instances/offline-instance.yml -s ./src up
  echo "output: $output"
  assert_success

  run aws --endpoint-url=http://localstack:4566 s3api get-bucket-location --bucket "spinsite-example-website-xyz-offline-123"
  echo "output: $output"
  assert_success

  run stack-spin -i instances/offline-instance.yml -s ./src down
  echo "output: $output"
  assert_success
}
