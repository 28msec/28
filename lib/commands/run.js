'use strict';

var cli = require('commander');
var request = require('request');
require('colors');
var URL = require('url');

var Config = require('../config').Config;

//Run Command
var runCmd = cli.command('run <projectName> <path>');
runCmd
    .description('Run query.')
    .action(function(projectName, path){
        projectName = projectName || Config.getDefaultProject();
        return Config.refreshTokens(projectName).then(function(){
            var u = URL.parse(path);
            if(u.protocol === null) {
                u = URL.parse(Config.getProjectEndpoint(projectName) + '/_queries' + (path[0] === '/' ? '' : '/') + path);
            }
            var serializedURL = URL.format(u);
            console.log(`GET ${serializedURL}`.gray);
            request({
                uri: serializedURL,
                method: 'GET'
            }, function(error, response, body){
                if(error) {
                    console.error(error);
                } else {
                    console.log(body);
                }
            });
        });
    });


//Trace Command
var traceCmd = cli.command('trace <projectName> <path>');
traceCmd
    .description('Trace query.')
    .action(function(projectName, path){
        projectName = projectName || Config.getDefaultProject();
        return Config.refreshTokens(projectName).then(function(){
            var u = URL.parse(path);
            if(u.protocol === null) {
                u = URL.parse(Config.getProjectEndpoint(projectName) + '/_queries' + (path[0] === '/' ? '' : '/') + path);
            }
            if(!u.pathname.endsWith('.jq') && !u.pathname.endsWith('.xq')) {
                //Assumes JSONiq then
                u.pathname += '.jq';
            }
            u.pathname += '/metadata/trace';
            if(u.search === null) {
                u.search = '';
            } else {
                u.search += '&';
            }
            u.search += '_token=' + encodeURIComponent(Config.getProjectToken(projectName));
            var serializedURL = URL.format(u);
            console.log(`GET ${serializedURL}`.gray);
            request({
                uri: serializedURL,
                method: 'GET'
            }, function(error, response, body){
                if(error) {
                    console.error(error);
                } else {
                    console.log(body.green);
                }
            });
        });
    });
