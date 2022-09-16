#!/bin/bash

set -euo pipefail

ME=`basename $0`
MYFULL=`readlink -f $0`
MYDIR=`dirname $MYFULL`
USAGE="USAGE: $ME [update|dojo|dojodev|test|testdev]
    update          Make sure the latest published spin-tools-dojo image is available locally
    dojo            Update and start a spin-tools-dojo instance using the latest published image
    test            Run this project's offline tests in the latest published spin-tools-dojo image
    test-online     Run this project's online tests in the latest published spin-tools-dojo image
    dojodev         Start a spin-tools-dojo instance using the local image with the :localdev tag
                    (normally one you've built locally but not pushed yet)
    testdev         Run this project's tests in the local image with the :localdev tag
"

print_usage()
{
    >&2 echo "USAGE: $USAGE"
}

warn()
{
    >&2 echo "[$ME] WARN: $*"
}

fail()
{
    >&2 echo "[$ME] FAIL: $*"
    print_usage
    exit 1
}

info()
{
    echo "[$ME] INFO: $*"
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
    test|test-offline)
        docker pull kiefm/spin-tools-dojo:latest
        dojo "./gojo test"
        ;;
    test-online)
        docker pull kiefm/spin-tools-dojo:latest
        dojo "./gojo test-online"
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
    help)
        print_usage
        ;;
    *)
        fail "Unknown command ${arg}"
        ;;
    esac
done

