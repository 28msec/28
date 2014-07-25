'use strict';

var cli = require('commander');

var Config = require('../config').Config;
var $28 = Config.getAPIClient();

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

//Create Project
var createPrjCmd = cli.command('create-project <project-name>');
createPrjCmd.description('Create a new 28.io project.')
.action(function(projectName){
    cli.matchedCommand = true;
    console.log('Creating Project ' + projectName + '...'.grey);
    Config.refreshTokens()
    .then(function(){
        return $28.createProject(projectName, Config.getAccessToken());
    })
    .then(function(){
        console.log(('Created ' + projectName + '.').green);
    })
    .catch(Config.handleAPIError);
});

//Delete Project
var deletePrjCmd = cli.command('delete-project <project-name>');
deletePrjCmd.description('Delete a new 28.io project.')
.action(function(projectName){
    cli.matchedCommand = true;
    console.log('Deleting Project ' + projectName + '...'.grey);
    Config.refreshTokens()
    .then(function(){
        return $28.deleteProject(projectName, Config.getAccessToken());
    })
    .then(function(){
        console.log(('Deleted ' + projectName + '.').green);
    })
    .catch(Config.handleAPIError);
});