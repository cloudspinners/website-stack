load "${BATS_HELPER_DIR}/bats-support/load.bash"
load "${BATS_HELPER_DIR}/bats-assert/load.bash"


setup_file() {
    >&3 echo "setup for online testing"

    if [ -n "${TARGET_INSTANCE_CONFIGURATION_FILE}" ] ; then
        >&3 echo "Using instance configuration file ${TARGET_INSTANCE_CONFIGURATION_FILE}"
        export INSTANCE_CONFIGURATION_FILE=${TARGET_INSTANCE_CONFIGURATION_FILE}
    else
        >&3 echo "Using default instance configuration file"
        export INSTANCE_CONFIGURATION_FILE=./my-instance.yml
    fi

    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY

    mkdir -p ~/.aws
    if [ -e ~/.aws/credentials ] ; then
        >&3 echo "Backing up aws credentials file"
        export AWS_CREDENTIALS_BAK=$(mktemp -u -p ~/.aws bak.credentialsXXXXXX)
        cp ~/.aws/credentials ${AWS_CREDENTIALS_BAK}
    fi
    echo "
[spintools_aws]
aws_access_key_id=${AWS_SANDBOX_ACCESS_KEY_ID}
aws_secret_access_key=${AWS_SANDBOX_SECRET_ACCESS_KEY}
" > ~/.aws/credentials

    >&3 echo "spinning the online stack up for testing using ${INSTANCE_CONFIGURATION_FILE}"
    stack-spin -i ${INSTANCE_CONFIGURATION_FILE} up

    WEBSITE_NAME=$(yq .stack_instance.parameters.website_name ${INSTANCE_CONFIGURATION_FILE})
    INSTANCE_NAME=$(yq .stack_instance.parameters.instance_name ${INSTANCE_CONFIGURATION_FILE})
    export S3_BUCKET_NAME=$(yq -r .website_bucket_name.value _tmp/stack-output-values.json)
    export WEBSITE_HOSTNAME=$(yq -r .website_hostname.value _tmp/stack-output-values.json)

    >&3 echo "the stack should be ready for testing"
}


@test "The AWS credentials are provided in the expected environment variables" {
    refute [ -z "${AWS_SANDBOX_ACCESS_KEY_ID}" ]
    refute [ -z "${AWS_SANDBOX_SECRET_ACCESS_KEY}" ]
}


@test "The AWS access key id looks like an AWS access key id" {
    assert [ "${AWS_SANDBOX_ACCESS_KEY_ID:0:4}" == "AKIA" ]
}


@test "The aws cli can use the AWS API" {
    run aws --profile spintools_aws s3api list-buckets
    echo "command: $BATS_RUN_COMMAND"
    echo "output: $output"
    assert_success
}


@test "The s3 bucket exists" {
    refute [ -z "${S3_BUCKET_NAME}" ]
    run aws --output json --profile spintools_aws s3api get-bucket-location --bucket "${S3_BUCKET_NAME}"
    echo "command: $BATS_RUN_COMMAND"
    echo "output: $output"
    assert_success
}


@test "The hostname is found" {
    run host "${WEBSITE_HOSTNAME}"
    echo "command: $BATS_RUN_COMMAND"
    echo "output: $output"
    assert_success
}


@test "Can upload a page and then access it through the http endpoint and hostname" {
    S3_BUCKET_ENDPOINT=$(jq -r '.website_bucket_endpoint.value' ./_tmp/stack-output-values.json)

    run aws --profile spintools_aws s3 cp test/content/index.html "s3://${S3_BUCKET_NAME}/"
    echo "command: $BATS_RUN_COMMAND"
    echo "output: $output"
    assert_success

    run curl -s "http://${S3_BUCKET_ENDPOINT}/index.html"
    echo "command: $BATS_RUN_COMMAND"
    echo "output: $output"
    assert_output --partial "Hello there"

    SITE_HOSTNAME=$(jq -r '.website_hostname.value' ./_tmp/stack-output-values.json)
    run curl -s "http://${SITE_HOSTNAME}/index.html"
    echo "command: $BATS_RUN_COMMAND"
    echo "output: $output"
    assert_output --partial "Hello there"
}


teardown_file() {
    >&3 echo "spinning the online stack down"
    stack-spin -i ${INSTANCE_CONFIGURATION_FILE} down

    if [ ! -z ${AWS_CREDENTIALS_BAK} -a -e ${AWS_CREDENTIALS_BAK} ] ; then
        mv ${AWS_CREDENTIALS_BAK} ~/.aws/credentials
    fi
}

