'use strict';

var cli = require('commander');
var http = require('http');

var Config = require('../config').Config;
var $28 = Config.getAPIClient();


var options = function(cmd){
    cmd.option(
        '-o, --overwrite <value>',
        'Overwrite files. Value can be yes, no, if-newer, or ask.',
        function(value){
            return $28.overwriteCoercion(value, cmd);
        }
    )
    .option('-s, --simulate', 'Simulate for extra safety.')
    .option('-d, --delete-orphaned', 'Delete orphaned files.')
    .option('-c, --concurrency <int>', 'Concurrency level.',
            function(value){
                return $28.concurrencyCoercion(value, cmd);
            }
      );
};

var action = function(cmd, method) {
    cmd.action(function(projectName){
        projectName = projectName || Config.getDefaultProject();
        Config.refreshTokens(projectName).then(function(){
            var projectToken;
            try {
                projectToken = Config.getProjectToken(projectName);
            } catch(e) {
                console.error(('Project not found: ' + projectName).red);
                return;
            }
            var localProjectPath = process.cwd();
            if (cmd.concurrency === undefined)
            {
              http.globalAgent.maxSockets = 8;
              console.log('Concurrency limit: 8.'.grey);
            }
            else
            {
              http.globalAgent.maxSockets = cmd.concurrency;
              console.log('Concurrency limit: ' + cmd.concurrency + '.'.grey);
            }
            method.apply($28, [
                Config.getProjectEndpoint(projectName), projectToken, localProjectPath,
                cmd.overwrite === undefined ? $28.Options.OVERWRITE_ASK : cmd.overwrite,
                cmd.deleteOrphaned ? true : false,
                cmd.simulate ? true : false,
                function(queries){
                    return Config.filterQueries(queries);
                }]
            ).then(function(){
                console.log('All done.'.grey);
            }).catch(Config.handleAPIError);
        });
    });
};

var dlCmd = cli.command('download <project-name>');
options(dlCmd);
dlCmd.description('Download 28.io project.');
action(dlCmd, $28.download);

var upCmd = cli.command('upload <project-name>');
options(upCmd);
upCmd.description('Upload 28.io project.');
action(upCmd, $28.upload);
