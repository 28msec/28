'use strict';

var cli = require('commander');

var Config = require('../config').Config;
var $28 = Config.getAPIClient();

var upCmd = cli.command('upload <project-name>');
upCmd.option(
    '-o, --overwrite <value>',
    'Overwrite remove files. Value can be yes, no, if-newer, or ask.',
    function(value){
        return $28.overwriteCoercion(value, upCmd);
    }
)
.option('-s, --simulate', 'Simulate for extra safety.')
.option('-d, --delete-orphaned', 'Delete orphaned files.')
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
        var localProjectPath = process.cwd();
        $28.download(
            projectName, projectToken, localProjectPath,
            upCmd.overwrite === undefined ? $28.OVERWRITE_ASK : upCmd.overwrite,
            upCmd.deleteOrphaned ? true : false,
            upCmd.simulate ? true : false,
            Config.getIgnoreList()
        ).then(function(){
            console.log('All done.'.grey);
        }).catch(function(error){
            console.error(error);
        });
    });
});