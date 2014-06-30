#!/usr/bin/env bats
    
@test "login with wrong password" {
    cd tests/projects
    cat config-tpl.json > .28.json
    run bash -c "echo foobar1 | ../../bin/28 login w+test@28.io"
    [ $status -eq 1 ]
}

@test "login with right password" {
    cd tests/projects
    run bash -c "echo foobar | ../../bin/28 login w+test@28.io"
    [ $status -eq 0 ]
}

@test "list projects" {
    cd tests/projects
    run ../../bin/28 projects
    [ $status -eq 0 ]
}