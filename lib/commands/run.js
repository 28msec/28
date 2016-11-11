'use strict';

var cli = require('commander');
var request = require('request');
require('colors');
var URL = require('url');

var Config = require('../config').Config;

//Trace Command
var runCmd = cli.command('run <projectName> <path>');
runCmd
    .description('Run 28.io query.')
    .action(function(projectName, path){
        projectName = projectName || Config.getDefaultProject();
        return Config.refreshTokens(projectName).then(function(){
            var u = URL.parse(path);
            if(u.protocol === null) {
                u = URL.parse(Config.getProjectEndpoint(projectName) + '/_queries' + (path[0] === '/' ? '' : '/') + path);
            }
            if(!u.path.endsWith('.jq') && !u.path.endsWith('.xq')) {
                //Assumes JSONiq then
                u.path += '.jq';
            }
            if(u.search === null) {
                u.search = '';
            } else {
                u.search += '&';
            }
            u.search += '_token=' + encodeURIComponent(Config.getProjectToken(projectName));
            var serializedURL = URL.format(u);
            request({
                uri: serializedURL,
                method: 'GET'
            }, function(error, response, body){
                if(error) {
                    console.error(error);
                    return;
                }
                console.log(body.green);
            });
        });
    });
