'use strict';

var cli = require('commander');
var watch = require('watch');
var Q = require('q');

var VFS = require('../vfs').VFS;

var Config = require('../config').Config;
var client = Config.getAPIClient();
var $28 = require('28.io-nodejs').$28(Config.getAPIEndpoint());

//Truncate Command
var watchCmd = cli.command('watch <project-name>');
watchCmd
.description('Upload 28.io project.')
.action(function(projectName){
    cli.matchedCommand = true;
    return Config.refreshTokens().then(function(){
        var projectToken;
        try {
            projectToken = Config.getProjectToken(projectName);
        } catch(e) {
            console.error(('Project not found: ' + projectName).red);
            return;
        }
        var options = {};
        var localProjectPath = process.cwd();
        var vfs = new VFS($28, projectName, projectToken, localProjectPath);
        var deferred = Q.defer();
        watch.createMonitor(localProjectPath, options, function(monitor) {
            monitor.on('created', function (f) {
                deferred.notify({
                    name: 'upload',
                    localProjectPath: localProjectPath,
                    vfs: vfs,
                    file: f
                });
            });

            monitor.on('changed', function (f) {
                deferred.notify({
                    name: 'upload',
                    localProjectPath: localProjectPath,
                    vfs: vfs,
                    file: f
                });
            });

            monitor.on('removed', function (f) {
                deferred.notify({
                    name: 'remove',
                    localProjectPath: localProjectPath,
                    vfs: vfs,
                    file: f
                });
            });
            client.upload(
                projectName, projectToken, localProjectPath, client.Options.OVERWRITE_ALWAYS, true, false, Config.getIgnoreList()
            ).finally(function(){
                console.log(('Watching ' + localProjectPath + '...').grey);
            });
        });
        return deferred.promise;
    })
    .progress(function(event){
        var query;
        var file = event.file;
        var ext = file.substring(file.length - 3);
        if(ext !== '.xq' && ext !== '.jq') {
            return;
        }
        if(event.name === 'upload') {
            query = file.substring(event.localProjectPath.length + 1);
            console.log(('Uploading ' + query).grey);
            event.vfs.writeRemoteQuery(query, true).then(function(result){
                if(result && result.message) {
                    console.error(result.message.red);
                }
                console.log((query + ' uploaded').green);
            }).catch(function(error){
                console.error(error);
            });
        } else if(event.name === 'remove') {
            query = file.substring(event.localProjectPath.length);
            console.log(('Removing ' + query).grey);
            event.vfs.deleteRemoteQuery(query).then(function(){
                console.log((query + ' removed').green);
            }).catch(function(error){
                console.error(error);
            });
        }
    })
    .catch(function(error){
        console.log(error);
    })
    .then(function(done){
        console.log(done);
    });
});