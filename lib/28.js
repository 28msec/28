'use strict';

//var Q = require('q');
var ClientLib = require('./client');
var Options = ClientLib.Options;
var Client = ClientLib.Client;

exports.$28 = function(apiEndpoint) {
    var $28 = require('28.io-nodejs').$28(apiEndpoint);

    this.login = function(email, password){
        return $28.Auth.authenticate({
            email: email,
            password: password,
            grant_type: 'client_credentials'
        });
    };
    
    this.refreshTokens = function(email, token){
        return $28.Auth.authenticate({
            email: email,
            refresh_token: token,
            grant_type: 'refresh_token'
        });
    };

    this.OVERWRITE_ALWAYS = Options.OVERWRITE_ALWAYS;
    this.OVERWRITE_NEVER = Options.OVERWRITE_NEVER;
    this.OVERWRITE_ASK = Options.OVERWRITE_ASK;
    this.OVERWRITE_IF_NEWER = Options.OVERWRITE_IF_NEWER;

    this.overwriteCoercion = function(value, cmd){
        value = value.toLowerCase();
        if(value === 'yes' || value === 'all' || value === 'always') {
            return this.OVERWRITE_ALWAYS;
        }else if(value === 'no' || value === 'none' || value === 'never') {
            return this.OVERWRITE_NEVER;
        } else if(value === 'ask') {
            return this.OVERWRITE_ASK;
        } else if(value === 'if-newer') {
            return this.OVERWRITE_IF_NEWER;
        } else {
            console.error('Invalid option value for the overwrite option.'.red);
            cmd.help();
        }
    };
    
    var sync = function(type, projectName, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, ignore){
        var client = new Client($28, projectName, projectToken, localProjectPath);
        var method = type === 'download' ? client.download : client.upload;
        return method(overwrite, deleteOrphaned, simulate, ignore);
    };

    this.download = function(projectName, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, ignore){
        return sync('download', projectName, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, ignore);
    };
    
    this.upload = function(projectName, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, ignore){
        return sync('upload', projectName, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, ignore);
    };

    this.truncate = function(projectName, projectToken, simulate, ignore){
        var client = new Client($28, projectName, projectToken);
        return client.truncate(simulate, ignore);
    };
};
