'use strict';

var cli = require('commander');

var Config = require('../config').Config;
var $28 = Config.getAPIClient();
var _ = require('lodash');

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
            _.sortBy(sources, ['category', 'default', 'name']).forEach(function(source){
                console.log('* ' + source.name + ' (' + source.category + (source.defaut ? ', default' : '') + ')');
            });
        })
        .catch(Config.handleAPIError);
    });
});