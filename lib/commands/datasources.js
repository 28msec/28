'use strict';

var cli = require('commander');

var Config = require('../config').Config;
var $28 = Config.getAPIClient();
var _ = require('lodash');

//List Datasources
var listDSCmd = cli.command('datasources <projectName>');
listDSCmd
 .alias('ds')
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
        var colors = {
            'MongoDB': 'green',
            'JDBC': 'blue'
        };
        $28.listDatasources(projectName, projectToken)
        .then(function(result){
            var sources = result.body;
            if(sources.length === 0) {
                console.log('No datasources have been configured yet.');
            }
            _.chain(sources).sortBy(['category', 'default', 'name']).groupBy('category').forEach(function(list, category){
                var color = colors[category];
                var bgColor = 'bg' + color[0].toUpperCase() + color.substring(1);
                console.log(('  ' + category + '  ')[bgColor].white);
                list.forEach(function(source){
                    console.log(('* ' + source.name + (source.default ? ' (default)' : ''))[color]);
                });
            });
        })
        .catch(Config.handleAPIError);
    });
});