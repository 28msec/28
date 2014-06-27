'use strict';

var Q = require('q');
var ffs = require('final-fs');
var read = require('read');
var cli = require('commander');
require('colors');

var XQLint = require('xqlint').XQLint;

var pkg = require('../package.json');
var Config = require('./config').Config;
var $28 = require('./28.js').$28;

cli.matchedCommand = false;
Config.load();
var $28 = new $28(Config.getAPIEndpoint());

//Login Command
cli
.command('login <email>')
.description('Sign-in into 28.io.')
.action(function(email) {
    cli.matchedCommand = true;

    if(!email) {
        console.log('Need email to authenticate: 28 -h for more infos');
        return;
    }

    read({ prompt: 'Password: ', silent: true, replace: '*' }, function(er, password) {
        console.log('Authenticating...');
        $28.login(email, password)
        .then(function(response){
            Config.save(response.body);
            console.log('API tokens have been saved.'.green);
        })
        .catch(function(error){
            if(error instanceof Error) {
                if(error.getCode() === 'ENOTFOUND') {
                    console.error('Couldn\'t connect to API endpoint'.red);
                } else {
                    throw error;
                }
            }
            console.error('Authentication failed. Server replied:'.red);
            console.error(error.response.body.red);
        });
    });
});

cli.version(pkg.version);
module.exports = cli;
