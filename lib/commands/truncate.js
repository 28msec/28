'use strict';

var cli = require('commander');

var Config = require('../config').Config;
var $28 = Config.getAPIClient();

//Truncate Command
var truncateCmd = cli.command('truncate <project-name>');
truncateCmd.option('-s, --simulate', 'Simulate for extra safety.')
.description('Upload 28.io project.')
.action(function(projectName){
    cli.matchedCommand = true;
    Config.refreshTokens().then(function(){
        var projectToken;
        try {
            projectToken = Config.getProjectToken(projectName);
        } catch(e) {
            console.error(('Project not found: ' + projectName).red);
            return;
        }
        $28.truncate(
            projectName, projectToken,
            truncateCmd.simulate ? true : false,
            Config.getIgnoreList()
        ).then(function(){
            console.log('All done.'.grey);
        }).catch(function(error){
            console.error(error);
        });
    });
});