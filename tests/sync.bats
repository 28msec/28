#!/usr/bin/env bats

@test "login" {
    cd tests/projects
    run bash -c "echo foobar | ../../bin/28 login w+test@28.io"
    [ $status -eq 0 ]
}

@test "truncate project" {
    cd tests/projects
    run ../../bin/28 truncate clienttest
    [ $status -eq 0 ]
}

@test "upload project" {
    cd tests/projects
    run ../../bin/28 upload clienttest
    [ $status -eq 0 ]
}

@test "download project" {
    cd tests/projects
    run ../../bin/28 upload clienttest -o all
    [ $status -eq 0 ]
}