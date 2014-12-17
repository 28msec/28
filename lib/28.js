'use strict';

var syncLib = require('./sync');
var Options = syncLib.Options;
var Client = syncLib.Client;

var $28 = (function(){
    function $28(apiEndpoint){
        this.api = require('28.io-nodejs').$28(apiEndpoint);
        this.Options = Options;
    }

    $28.prototype.sync = function(type, projectName, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, ignore) {
        var client = new Client(this.api, projectName, projectToken, localProjectPath);
        var method = type === 'download' ? client.download : client.upload;
        return method.apply(client, [overwrite, deleteOrphaned, simulate, ignore]);
    };

    $28.prototype.download = function(projectName, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, ignore) {
        return this.sync('download', projectName, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, ignore);
    };

    $28.prototype.upload = function(projectName, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, ignore) {
        return this.sync('upload', projectName, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, ignore);
    };

    $28.prototype.truncate = function(projectName, projectToken, simulate, ignore) {
        var client = new Client(this.api, projectName, projectToken);
        return client.truncate(simulate, ignore);
    };

    $28.prototype.refreshTokens = function(email, token){
        return this.api.Auth.authenticate({
            email: email,
            refresh_token: token,
            grant_type: 'refresh_token'
        });
    };

    $28.prototype.login = function(email, password) {
        return this.api.Auth.authenticate({
            email: email,
            password: password,
            grant_type: 'client_credentials'
        });
    };

    $28.prototype.createProject = function(projectName, token) {
        return this.api.Project.createProject({
            projectName: projectName,
            package: 'free',
            token: token
        });
    };

    $28.prototype.deleteProject = function(projectName, token){
        return this.api.Project.deleteProject({
            name: projectName,
            token: token
        });
    };

    $28.prototype.listDatasources = function(projectName, token){
        return this.api.Datasources(projectName).listDatasources({ token: token});
    };

    $28.prototype.createDatasource = function(projectName, category, name, token, difault, credentials){
        return this.api.Datasources(projectName).createDatasource({
            category: category,
            name: name,
            token: token,
            default: difault,
            credentials: credentials
        });
    };

    $28.prototype.removeDatasource = function(projectName, category, datasource, projectToken){
        return this.api.Datasources(projectName).removeDatasource({
            category: category,
            datasource: datasource,
            token: projectToken
        });
    };

    $28.prototype.getDefaultMongoDBCredentials = function(projectName, token){
        return this.api.Project.getDefaultMongoDBCredentials({
            name: projectName,
            token: token
        });
    };

    $28.prototype.updateDefaultMongoDBCredentials = function(
        projectName, token, dbType, connString, db, username, password, preDigested
    ){
        return this.api.Project.updateDefaultMongoDBCredentials({
            name: projectName,
            token: token,
            dbType: dbType,
            connString: connString,
            db: db,
            user: username,
            pass: password,
            preDigested: preDigested
        });
    };

    $28.prototype.overwriteCoercion = function(value, cmd){
        value = value.toLowerCase();
        if(value === 'yes' || value === 'all' || value === 'always') {
            return Options.OVERWRITE_ALWAYS;
        } else if(value === 'no' || value === 'none' || value === 'never') {
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

    return $28;
})();

exports.$28 = $28;
exports.VFS = require('./vfs');
