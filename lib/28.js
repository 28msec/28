'use strict';

exports.$28 = function(apiEndpoint){
    var syncLib = require('./sync');
    var Options = syncLib.Options;
    var Client = syncLib.Client;

    this.api = require('28.io-nodejs').$28(apiEndpoint);
    this.Options = Options;
    var that = this;

    this.sync = function(type, projectName, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, ignore) {
        var client = new Client(that.api, projectName, projectToken, localProjectPath);
        var method = type === 'download' ? client.download : client.upload;
        return method(overwrite, deleteOrphaned, simulate, ignore);
    };

    this.download = function(projectName, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, ignore) {
        return that.sync('download', projectName, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, ignore);
    };

    this.upload = function(projectName, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, ignore) {
        return that.sync('upload', projectName, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, ignore);
    };

    this.truncate = function(projectName, projectToken, simulate, ignore) {
        var client = new Client(that.api, projectName, projectToken);
        return client.truncate(simulate, ignore);
    };

    this.refreshTokens = function(email, token){
        return that.api.Auth.authenticate({
            email: email,
            refresh_token: token,
            grant_type: 'refresh_token'
        });
    };

    this.login = function(email, password) {
        return that.api.Auth.authenticate({
            email: email,
            password: password,
            grant_type: 'client_credentials'
        });
    };

    this.createProject = function(projectName, token) {
        return that.api.Project.createProject({
            projectName: projectName,
            package: 'free',
            token: token
        });
    };

    this.deleteProject = function(projectName, token){
        return that.api.Project.deleteProject({
            name: projectName,
            token: token
        });
    };

    this.listDatasources = function(projectName, token){
        return that.api.Datasources(projectName).listDatasources({ token: token});
    };

    this.createDatasource = function(projectName, category, name, token, difault, credentials){
        return that.api.Datasources(projectName).createDatasource({
            category: category,
            name: name,
            token: token,
            default: difault,
            credentials: credentials
        });
    };

    this.removeDatasource = function(projectName, category, datasource, projectToken){
        return that.api.Datasources(projectName).removeDatasource({
            category: category,
            datasource: datasource,
            token: projectToken
        });
    };

    this.getDefaultMongoDBCredentials = function(projectName, token){
        return that.api.Project.getDefaultMongoDBCredentials({
            name: projectName,
            token: token
        });
    };

    this.updateDefaultMongoDBCredentials = function(
        projectName, token, dbType, connString, db, username, password, preDigested
        ){
        return that.api.Project.updateDefaultMongoDBCredentials({
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

    this.overwriteCoercion = function(value, cmd){
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
};
