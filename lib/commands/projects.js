'use strict';

var cli = require('commander');

var Config = require('../config').Config;

//List Projects
cli
.command('projects')
.description('List of 28.io projects.')
.action(function(){
    cli.matchedCommand = true;
    Config.refreshTokens()
    .then(function(){
        console.log('Project List:');
        var projects = Config.getProjectList();
        projects.forEach(function(project){
            console.log('* ' + project);
        });
    });
});