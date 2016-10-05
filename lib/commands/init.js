'use strict';

var fs = require('fs');
var cli = require('commander');
var read = require('read');

var Config = require('../config').Config;
var $28 = Config.getAPIClient();

//Login Command
cli
    .command('init <config>')
    .description('Set the 28msec instance to target.')
    .action(function(config) {

        if(!config) {
            console.log('Need email to authenticate: 28 -h for more infos');
            return;
        }

        var projectConfig = JSON.parse(fs.readFileSync(config, 'utf-8'));

        Config.config.endpoint = projectConfig['28'].platformEndpoint;
        Config.config.projectEndpoint = projectConfig['28'].platformEndpoint.replace(/portal/, "<%= projectName %>");
        Config.save();
        console.log(`Signing-in as ${projectConfig['28'].email}...`);
        $28.login(projectConfig['28'].email, projectConfig['28'].password)
            .then(function(response){
                //console.log(response);
                //response.body.email = email;
                Config.save(response.body);
                console.log('API tokens have been saved.'.green);
            })
            .catch(error => {
                console.log(error);
            })
            .catch(Config.handleAPIError);
    });