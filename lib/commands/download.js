'use strict';

var cli = require('commander');

var Config = require('../config').Config;
var Client = require('../client').Client;

var dlCmd = cli.command('download <project-name>');
dlCmd.option(
    '-o, --overwrite <value>',
    'Overwrite local files. Value can be yes, no, if-newer, or ask.',
    function(value){
        return Client.overwriteCoercion(value, dlCmd);
    }
)
.option('-s, --simulate', 'Simulate for extra safety.')
.option('-d, --delete-orphaned', 'Delete orphaned files.')
.description('Download 28.io project.')
.action(function(projectName){
    cli.matchedCommand = true;
    Config.refreshTokens().then(function(){
        console.log(projectName);
    });
});