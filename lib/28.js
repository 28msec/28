(function(){
    'use strict';

    var syncLib = require('./sync');
    var Options = syncLib.Options;
    var Client = syncLib.Client;
    
    var api;
    var sync = function(type, projectName, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, ignore){
        var client = new Client(api, projectName, projectToken, localProjectPath);
        var method = type === 'download' ? client.download : client.upload;
        return method(overwrite, deleteOrphaned, simulate, ignore);
    };
    
    var $28 = function(apiEndpoint) {
        api = require('28.io-nodejs').$28(apiEndpoint);
        this.Options = Options;
    };
    
    $28.prototype.download = function(projectName, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, ignore){
        return sync('download', projectName, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, ignore);
    };
        
    $28.prototype.upload = function(projectName, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, ignore){
        return sync('upload', projectName, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, ignore);
    };
    
    $28.prototype.truncate = function(projectName, projectToken, simulate, ignore){
        var client = new Client(api, projectName, projectToken);
        return client.truncate(simulate, ignore);
    };
    
    $28.prototype.refreshTokens = function(email, token){
        return api.Auth.authenticate({
            email: email,
            refresh_token: token,
            grant_type: 'refresh_token'
        });
    };
    
    $28.prototype.login = function(email, password){
        return api.Auth.authenticate({
            email: email,
            password: password,
            grant_type: 'client_credentials'
        });
    };
    
    $28.prototype.overwriteCoercion = function(value, cmd){
        value = value.toLowerCase();
        if(value === 'yes' || value === 'all' || value === 'always') {
            return Options.OVERWRITE_ALWAYS;
        }else if(value === 'no' || value === 'none' || value === 'never') {
            return Options.OVERWRITE_NEVER;
        } else if(value === 'ask') {
            return Options.OVERWRITE_ASK;
        } else if(value === 'if-newer') {
            return Options.OVERWRITE_IF_NEWER;
        } else {
            console.error('Invalid option value for the overwrite option.'.red);
            cmd.help();
        }
    };
    
    exports.$28 = $28;
})();