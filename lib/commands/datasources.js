'use strict';

var cli = require('commander');

var Config = require('../config').Config;
var $28 = Config.getAPIClient();
var _ = require('lodash');
var fs = require('fs');
var Q = require('q');

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
            MongoDB: 'green',
            JDBC: 'blue',
            Cloudant: 'magenta',
            CloudSearch: 'yellow',
            S3: 'cyan',
            SPARQL: 'orange'
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

//Create Datasources
var createDS = cli.command('set-datasources <projectName>')
createDS
.alias('set-ds')
.description('Set datasources')
.option('-c, --config <file>', 'Configuration file')
.action(function(projectName, options){
    cli.matchedCommand = true;
    var sources = JSON.parse(fs.readFileSync(options.config, 'utf-8'));
    Config.refreshTokens().then(function() {
        var projectToken;
        try {
            projectToken = Config.getProjectToken(projectName);
        } catch (e) {
            console.error(('Project not found: ' + projectName).red);
        }
        console.log('Listing datasources...'.grey);
        return $28.listDatasources(projectName, projectToken).then(function(data){
            var toRemove = [];
            data.body.forEach(function(source) {
                toRemove.push(
                    $28.removeDatasource(projectName, source.category, source.name, projectToken)
                );
            });
            console.log('Updating datasources...'.grey);
            return Q.allSettled(toRemove).then(function() {
                var toCreate = [];
                sources.forEach(function(source) {
                    toCreate.push(
                        $28.createDatasource(
                            projectName, source.category, source.name,
                            projectToken, source.default === true, source.credentials
                        )
                    );
                });
                return Q.allSettled(toCreate);
            });
        }).then(function(){
            console.log('Done.'.grey);
        })
    })
    .catch(Config.handleAPIError);
});