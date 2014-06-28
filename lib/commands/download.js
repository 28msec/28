'use strict';

var cli = require('commander');

var Config = require('../config').Config;
var $28 = Config.getAPIClient();

var dlCmd = cli.command('download <project-name>');
dlCmd.option(
    '-o, --overwrite <value>',
    'Overwrite local files. Value can be yes, no, if-newer, or ask.',
    function(value){
        return $28.overwriteCoercion(value, dlCmd);
    }
)
.option('-s, --simulate', 'Simulate for extra safety.')
.option('-d, --delete-orphaned', 'Delete orphaned files.')
.description('Download 28.io project.')
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
        var isOriginRemote = true;
        $28.download(
            projectName, projectToken, localProjectPath,
            dlCmd.overwrite === undefined ? $28.OVERWRITE_ASK : dlCmd.overwrite,
            dlCmd.deleteOrphaned ? true : false,
            dlCmd.simulate ? true : false,
            Config.getIgnoreList(),
            isOriginRemote
        );
    });
});