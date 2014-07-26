#!/usr/bin/env bats

@test "login" {
    cd tests/projects
    run bash -c "echo foobar | ../../bin/28 login w+test@28.io"
    [ $status -eq 0 ]
}

@test "truncate project" {
    PROJECT_NAME="halfmoonbay"$RANDOM
    cd tests/projects
    run ../../bin/28 create-project $PROJECT_NAME
    run ../../bin/28 truncate $PROJECT_NAME
    run ../../bin/28 delete-project $PROJECT_NAME
    [ $status -eq 0 ]
}

@test "upload project" {
    PROJECT_NAME="halfmoonbay"$RANDOM
    cd tests/projects
    unzip -o queries.zip
    run ../../bin/28 create-project $PROJECT_NAME
    run ../../bin/28 upload $PROJECT_NAME
    run ../../bin/28 delete-project $PROJECT_NAME
    [ $status -eq 0 ]
}

@test "download project" {
    PROJECT_NAME="halfmoonbay"$RANDOM
    cd tests/projects
    run ../../bin/28 create-project $PROJECT_NAME
    run ../../bin/28 download $PROJECT_NAME
    run ../../bin/28 delete-project $PROJECT_NAME
    [ $status -eq 0 ]
}

@test "upload project with compilation error" {
    PROJECT_NAME="halfmoonbay"$RANDOM
    cd tests/test_project
    run ../../bin/28 create-project $PROJECT_NAME
    run ../../bin/28 truncate $PROJECT_NAME 
    run ../../bin/28 upload $PROJECT_NAME
    upload_status=$status
    run ../../bin/28 delete-project $PROJECT_NAME
    [ $status -eq 0 ]
    [ $upload_status -ne 0 ]
}