#!/bin/bash

set -euo pipefail

ME=`basename $0`
MYFULL=`readlink -f $0`
MYDIR=`dirname $MYFULL`
USAGE="USAGE: $ME [update|dojo|dojodev|test|testdev|release]"

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


if [ -n "${SPIN_TOOLS_VERSION:-}" ] ; then
    fail "Don't run this script inside a running spin docker image, run ./gojo instead"
fi


if [ "$#" -eq 0 ] ; then
    fail "No command given"
fi

for arg in "$@"
do
    case "$arg" in
    update)
        docker pull kiefm/spin-tools-dojo:latest
        ;;
    dojo)
        docker pull kiefm/spin-tools-dojo:latest
        dojo
        ;;
    dojodev)
        dojo -image kiefm/spin-tools-dojo:localdev
        ;;
    test)
        docker pull kiefm/spin-tools-dojo:latest
        dojo "./gojo test"
        ;;
    testdev)
        dojo -image kiefm/spin-tools-dojo:localdev "./gojo test"
        ;;
    version)
        if [ -f CHANGELOG.md ] ; then
            head -1 CHANGELOG.md | grep -o -e "[0-9]*\.[0-9]*\.[0-9]*"
        else
            fail "Can't get version, missing CHANGELOG.md"
        fi
        ;;
    release)
        do_release
        ;;
    help)
        print_usage
        ;;
    *)
        fail "Unknown command ${arg}"
        ;;
    esac
done

