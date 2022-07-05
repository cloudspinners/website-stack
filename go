#!/usr/bin/env sh

set -euo pipefail

fail()
{
  >&2 echo "FAIL: $*"
  exit 1
}

for arg in "$@"
do
	case "$arg" in
	test)
		echo "Running offline tests"
		spin-stack-code validate || fail "validate failed"
		// time bats ./test/bats || fail "offline bats tests failed"
		;;
	*)
		echo "Usage: go [test]"
		exit 0
		;;
	esac
done
