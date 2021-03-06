#!/usr/bin/env bats

load '../test_helper/bats-support/load'
load '../test_helper/bats-assert/load'
load '../common'

##################################################################
#  WARNING: THIS TEST WILL DELETE ALL OF YOUR LINODES            #
#  WARNING: USE A SEPARATE TEST ACCOUNT WHEN RUNNING THESE TESTS #
##################################################################

@test "it should create linodes with a label" {
    run linode-cli linodes create \
        --type g6-standard-2 \
        --region us-east \
        --image $test_image \
        --label cli-1 \
        --root_pass $random_pass \
        --text \
        --delimiter "," \
        --no-headers \
        --format 'label,region,type,image' \
        --no-defaults

    assert_output --regexp "cli-1,us-east,g6-standard-2,$test_image"
}

@test "it should view the linode configuration" {
    linode_id="$(linode-cli --text --no-headers linodes list | awk '{ print $1 }' | xargs)"
    run linode-cli linodes view "$linode_id" \
        --text \
        --delimiter "," \
        --no-headers \
        --format 'id,label,region,type,image' \
        --no-defaults

    assert_output --regexp "$linode_id,cli-1,us-east,g6-standard-2,$test_image"
}

@test "it should create a linode with the minimum required props" {
    run linode-cli linodes create \
        --type g6-standard-2 \
        --region us-east \
        --root_pass $random_pass \
        --no-defaults \
        --text \
        --delimiter "," \
        --no-headers \
        --format 'id,region,type'

    assert_output --regexp "[0-9]+,us-east,g6-standard-2"
}

@test "it should fail to create a linode without a root_pass" {
    run linode-cli linodes create \
        --type g6-standard-2 \
        --region us-east \
        --image $test_image \
        --no-defaults \
        --text \
        --no-headers

    assert_failure
    assert_output --partial 'Request failed: 400'
    assert_output --partial 'root_pass	root_pass is required'
}

@test "it should list linodes" {
    run linode-cli linodes list \
        --no-headers \
        --format 'label' \
        --text

    assert_output --partial 'cli-1'
}

@test "it should add a tag a linode" {
    linode_id="$(linode-cli --text --no-headers linodes list | awk '{ print $1 }' | xargs)"
    set -- $linode_id
    LINODE=$1

    run linode-cli linodes update $LINODE \
        --tags=$uniqueTag \
        --format 'tags' \
        --text \
        --no-headers

    assert_success
    assert_output $uniqueTag
}

@test "it should remove all linodes" {
    run removeLinodes
    run removeUniqueTag
}
