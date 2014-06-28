'use strict';

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
    
    this.OVERWRITE_ALWAYS = 0;
    this.OVERWRITE_NEVER = 1;
    this.OVERWRITE_ASK = 2;
    this.OVERWRITE_IF_NEWER = 3;

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
            console.error('Invalid option value for overwrite.'.red);
            cmd.help();
        }
    };
    /*
    var filterList = function(list, ignore) {
        Object.keys(list).forEach(function(path){
            //Delete public or private files that don't have a .jq or .xq suffix
            if(
                (path.indexOf('public/') === 0 || path.indexOf('private/') === 0) &&
                path.substring(path.length - 3) !== '.jq' &&
                path.substring(path.length - 3) !== '.xq'
            ) {
                delete list[path];
            } else {
                var matched = false;
                ignore.forEach(function(mask){
                    if(path.match(mask) !== null) {
                        matched = true;
                        return false;
                    }
                });
                if(matched === true) {
                    delete list[path];
                }
            }
        });
        return list;
    };
    
    var sync = function(projectName, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, ignore, isOriginRemote){
        
    };
    
    this.upload = function(projectName, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, ignore, isOriginRemote){

    };

    this.truncate = function(projectName, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, ignore, isOriginRemote){

    };
*/
  //  this.download = function(projectName, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, ignore, isOriginRemote){
        
    //};
};