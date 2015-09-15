'use strict';

var cli = require('commander');
var read = require('read');

var Config = require('../config').Config;
var $28 = Config.getAPIClient();

//Login Command
cli
.command('login <email>')
.description('Sign-in into 28.io.')
.action(function(email) {

    if(!email) {
        console.log('Need email to authenticate: 28 -h for more infos');
        return;
    }

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
});

//Reset password Command
cli
.command('change-password <email>')
.description('Reset 28.io password.')
.action(function(email){
        if(!email) {
            console.log('Need email to reset password: 28 -h for more infos');
            return;
        }

        read({ prompt: 'New password: ', silent: true, replace: '*' }, function(er, password) {
            read({ prompt: 'New password (confirmation):', silent: true, replace: '*' }, function(er, passwordConfirmation){
                if(password !== passwordConfirmation) {
                    throw new Error('Passwords don\'t match');
                }
                $28.resetPassword(email, password, Config.getAccessToken())
                .then(function(){
                    console.log('Password changed'.green);
                })
                .catch(Config.handleAPIError);
            });
        });
});
