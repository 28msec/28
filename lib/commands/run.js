'use strict';

var cli = require('commander');
var request = require('request');
require('colors');

var Config = require('../config').Config;

//Trace Command
var runCmd = cli.command('run <projectName> <path>');
runCmd
    .description('Run 28.io query.')
    .action(function(projectName, path){
        var url = Config.getProjectEndpoint(projectName);
        path = path.indexOf('?') === -1 ? (path + '?') : path;
        path = path[0] === '/' ? path : ('/' + path);
        url += path + '&trace&_token=' + encodeURIComponent(Config.getProjectToken(projectName));
        request({
            uri: url,
            method: 'POST'
        }, function(error, response, body){
            if(error) {
                console.error(error);
                return;
            }
            console.log(body);
            var traceFile = response.headers['x-28msec-trace'];
            setTimeout(function(){
                request({
                    uri: traceFile,
                    method: 'GET'
                }, function(error, response, body){
                    if(body) {
                        console.log(body.green);
                    }
                });
            }, 1000);
        });
    });