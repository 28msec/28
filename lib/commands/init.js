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
        Config.config.
        console.log(Config);
        console.log(config);
/*
        read({ prompt: 'Password: ', silent: true, replace: '*' }, function(er, password) {
            console.log('Authenticating...');
            $28.login(email, password)
                .then(function(response){
                    response.body.email = email;
                    Config.save(response.body);
                    console.log('API tokens have been saved.'.green);
                })
                .catch(Config.handleAPIError);
        });
        */
    });
