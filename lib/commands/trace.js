'use strict';

var cli = require('commander');
var request = require('request');
require('colors');

var Config = require('../config').Config;

//Trace Command
var traceCmd = cli.command('trace <projectName> <path>');
traceCmd
    .description('Trace 28.io query.')
    .action(function(projectName, path){
        cli.matchedCommand = true;
        var url = Config.getProjectEndpoint(projectName);
        path = path.indexOf('?') === -1 ? (path + '?') : path;
        url += path + '&trace&_token=' + encodeURIComponent(Config.getProjectToken(projectName));
        console.log(url);
        request({
            uri: url,
            method: 'POST'
        }, function(error, response, body){
            if(error) {
                console.error(error);
                return;
            }
            console.log(body.grey);
            var traceFile = response.headers['x-28msec-trace'];
            setTimeout(function(){
                request({
                    uri: traceFile,
                    method: 'GET'
                }, function(error, response, body){
                    if(body) {
                        console.log(body.green);
                    } else {
                        console.log('No trace.'.green);
                    }
                });
            }, 1000);
        });
    });