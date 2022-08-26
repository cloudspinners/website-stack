load "${BATS_HELPER_DIR}/bats-support/load.bash"
load "${BATS_HELPER_DIR}/bats-assert/load.bash"


@test "Something is listening on the localstack port" {
  run curl -s --show-error \
              --retry 20 \
              --retry-all-errors \
              --retry-connrefused \
              --connect-timeout 5 \
              --retry-delay 2 \
              --retry-max-time 30 \
              --verbose \
              "http://localstack:4566"
  echo "output: $output"
  assert_equal "$status" 0
}


@test "AWS cli can connect to localstack" {
  run aws --endpoint-url=http://localstack:4566 ssm describe-parameters
  assert_success
}


@test "Running plan on the stack shows that changes are needed" {
  run stack-spin -i instances/offline-instance.yml -s ./src plan
  echo "output: $output"
  assert_failure 2
}
