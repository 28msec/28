'use strict';

var cli = require('commander');

var Config = require('../config').Config;
var $28 = Config.getAPIClient();

//List Datasources
var listDSCmd = cli.command('list-datasources <projectName>');
listDSCmd
.description('List Project Datasources')
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
        console.log('Listing datasources...'.grey);
        $28.listDatasources(projectName, projectToken)
        .then(function(result){
            var sources = result.body;
            if(sources.length === 0) {
                console.log('No datasources have been configured yet.');
            }
            sources.forEach(function(source){
                console.log('* ' + source.name + ' (' + source.category + (source.defaut ? ', default' : '') + ')');
            });
        })
        .catch(Config.handleAPIError);
    });
});

/*
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
        }).catch(Config.handleAPIError);
    });
});
*/