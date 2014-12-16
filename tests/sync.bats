#!/usr/bin/env bats

setup() {
    PROJECT_NAME="halfmoonbay"$RANDOM
    run ../../bin/28 create-project $PROJECT_NAME
}

teardown() {
    run ../../bin/28 delete-project $PROJECT_NAME
}

@test "login" {
    cd tests/projects
    run bash -c "echo foobar | ../../bin/28 login w+test@28.io"
    echo $output
    [ $status -eq 0 ]
}

@test "upload project" {
    cd tests/projects
    unzip -o queries.zip
    run ../../bin/28 upload $PROJECT_NAME
    [ $status -eq 0 ]
}

@test "download project" {
    cd tests/projects
    run ../../bin/28 download $PROJECT_NAME
    [ $status -eq 0 ]
}


@test "truncate project" {
    cd tests/projects
    run ../../bin/28 upload $PROJECT_NAME
    [ $status -eq 0 ]
}

@test "upload project with complex query name" {
    cd tests/test_project3
    run ../../bin/28 upload $PROJECT_NAME
    [ "$status" -eq 0 ]
}

@test "upload project with compilation error" {
    cd tests/test_project
    run ../../bin/28 upload $PROJECT_NAME
    [ "$status" -eq 0 ]
}