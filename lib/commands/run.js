'use strict';

var cli = require('commander');
var request = require('request');
var _ = require('lodash');
require('colors');

var Config = require('../config').Config;

//Trace Command
var runCmd = cli.command('run <projectName> <path>');
runCmd
    .description('Run 28.io query.')
    .action(function(projectName, path){
        projectName = projectName || Config.getDefaultProject();
        return Config.refreshTokens(projectName).then(function(){
            var url = Config.getProjectEndpoint(projectName) + '/_queries';
            path = path.indexOf('?') === -1 ? path + '/metadata/trace' : path.substring(0, path.indexOf('?')) + "/metadata/trace" + path.substring(path.indexOf('?'));
            path = path.indexOf('?') === -1 ? (path + '?') : path;
            path = path[0] === '/' ? path : ('/' + path);
            url += path + '&_token=' + encodeURIComponent(Config.getProjectToken(projectName));
            request({
                uri: url,
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
