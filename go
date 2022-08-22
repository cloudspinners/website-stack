#!/usr/bin/env sh

set -euo pipefail

ME=`basename $0`
MYFULL=`readlink -f $0`
MYDIR=`dirname $MYFULL`
USAGE="USAGE: $ME <COMMAND>

    COMMANDS:
        test            Run local tests (using localstack)
        help                        Print this message
"

warn()
{
    >&2 echo "[$ME] WARN: $*"
}

fail()
{
    >&2 echo "[$ME] FAIL: $*"
    >&2 echo "USAGE: $USAGE"
    exit 1
}

info()
{
    echo "[$ME] INFO: $*"
}

print_usage()
{
    >&2 echo "USAGE: $USAGE"
}


if [ "$#" -eq 0 ] ; then
  fail "No command given"
fi

while [ "$#" -ne 0 ] ; do
    COMMAND=$1
    shift
    case "$COMMAND" in
        dojodev)
            dojo -image kiefm/spin-tools-dojo:dev
            ;;
        test)
            echo "Running offline tests"
            stack-spin -i instances/offline-instance.yml validate || fail "validate failed"
            stack-spin -i instances/offline-instance.yml plan || fail "plan failed"
            # time bats ./test/bats || fail "offline bats tests failed"
            ;;
        help)
            echo "USAGE: $USAGE"
            ;;
         *)
            fail "Unknown command '$COMMAND'."
            ;;
    esac

done
