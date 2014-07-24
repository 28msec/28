'use strict';

var cli = require('commander');

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
    .option('-d, --delete-orphaned', 'Delete orphaned files.');
};

var action = function(cmd, method) {
    cmd.action(function(projectName){
        cli.matchedCommand = true;
        Config.refreshTokens().then(function(){
            var projectToken;
            try {
                projectToken = Config.getProjectToken(projectName);
            } catch(e) {
                console.error(('Project not found: ' + projectName).red);
                return;
            }
            var localProjectPath = process.cwd();
            method(
                projectName, projectToken, localProjectPath,
                cmd.overwrite === undefined ? $28.Options.OVERWRITE_ASK : cmd.overwrite,
                cmd.deleteOrphaned ? true : false,
                cmd.simulate ? true : false,
                Config.getIgnoreList()
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