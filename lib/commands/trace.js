'use strict';

var cli = require('commander');
var request = require('request');

var Config = require('../config').Config;

//Trace Command
var traceCmd = cli.command('trace <projectName> <path>');
traceCmd
    .description('Trace 28.io query.')
    .action(function(projectName, path){
        cli.matchedCommand = true;
        console.log(projectName);
        console.log(path);
        var url = Config.getProjectEndpoint(projectName);
        console.log(url);
        url += path + "&trace&_token=" + encodeURIComponent(Config.getProjectToken(projectName));
        request({
            uri: url,
            method: 'POST'
        }, function(error, response, body){
            if(error) {
                console.error(error);
                return;
            }
            console.log(response);
            //console.log(body);
        });
    });