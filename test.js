#!/usr/bin/env node
'use strict';

var cli = require('commander');
var _ = require('lodash');
var fs = require('fs');
var Q = require('q');

require('colors');

var pkg = require('../package.json');
var Config = require('../lib/config').Config;

Config.load();
var $28 = Config.getAPIClient();

cli
    .command('list [project-name]')
    .description('List Rewrite Rules')
    .action(function(projectName){
        projectName = projectName || Config.getDefaultProject();
        Config.refreshTokens(projectName).then(function(){
            $28.getCustomRewriteRules(projectName, Config.getAccessToken())
                .then(function(result) {
                    console.log(result.body);
                })
                .catch(Config.handleAPIError);
        });
    });

cli
    .command('set [project-name]')
    .description('Configure the project Datasources')
    .option('-c, --config <file>', 'Configuration file')
    .action(function(projectName, options){
        projectName = projectName || Config.getDefaultProject();
        var rewrites = JSON.parse(fs.readFileSync(options.config, 'utf-8'));
        Config.refreshTokens(projectName).then(function() {
            $28.setCustomRewriteRules(projectName, Config.getAccessToken(), rewrites).then(function(){
                console.log('done');
            }).catch(Config.handleAPIError);
        });
    });

cli.version(pkg.version);
cli.parse(process.argv);

if (!cli.args.length) {
    cli.help();
}
