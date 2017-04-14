'use strict';

var syncLib = require('./sync');
var Options = syncLib.Options;
var Client = syncLib.Client;

var $28 = (function() {

    function $28(apiEndpoint){
        this.api = require('28.io-nodejs').$28(apiEndpoint);
        this.Options = Options;
    }

    $28.prototype.sync = function(type, projectEndpoint, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, ignore) {
        var client = new Client(this.api, projectEndpoint, projectToken, localProjectPath);
        var method = type === 'download' ? client.download : client.upload;
        return method.apply(client, [overwrite, deleteOrphaned, simulate, ignore]);
    };

    $28.prototype.download = function(projectEndpoint, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, ignore) {
        return this.sync('download', projectEndpoint, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, ignore);
    };

    $28.prototype.upload = function(projectEndpoint, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, ignore) {
        return this.sync('upload', projectEndpoint, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, ignore);
    };

    $28.prototype.import = function(projectEndpoint, projectToken, archive, contentType, root){
        return this.api.Batch(projectEndpoint).importProject({
            archive: archive,
            contentType: contentType,
            token: projectToken,
            overwrite: 'yes',
            'delete-orphaned': true,
            root: root
        });
    };

    $28.prototype.truncate = function(projectEndpoint, projectToken, simulate, ignore) {
        var client = new Client(this.api, projectEndpoint, projectToken);
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

    $28.prototype.resetPassword = function(email, password, token) {
        return this.api.Account.updateAccount({
            email: email,
            password: password,
            token: token
        });
    };

    $28.prototype.existsProject = function(name) {
        return this.api.Project.checkProject({
            projectName: name
        });
    };

    $28.prototype.upgradeProject = function(name, token) {
        return this.api.Project.upgradeProject({
            projectName: name,
            token: token
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
            projectName: projectName,
            token: token
        });
    };

    $28.prototype.getQueryTrace = function(projectEndpoint, token, path) {
        return this.api.Queries(projectEndpoint).getQueryTrace({ token: token, queryPath: path });
    };

    $28.prototype.getCustomRewriteRules = function(projectName, token){
        return this.api.Project.getCustomRewriteRules({ projectName: projectName, token: token });
    };

    $28.prototype.setCustomRewriteRules = function(projectName, token, customRewrites) {
        return this.api.Project.setCustomRewriteRules({ projectName: projectName, token: token, customRewrites: customRewrites });
    };

    $28.prototype.listDatasources = function(projectEndpoint, token){
        return this.api.Datasources(projectEndpoint).listDatasources({ token: token });
    };

    $28.prototype.createDatasource = function(projectEndpoint, category, name, token, difault, credentials){
        return this.api.Datasources(projectEndpoint).createDatasource({
            category: category,
            name: name,
            token: token,
            default: difault,
            credentials: credentials
        });
    };

    $28.prototype.updateDatasource = function(projectEndpoint, name, category, newname, token, difault, credentials){
        return this.api.Datasources(projectEndpoint).updateDatasource({
            category: category,
            datasource: name,
            name: newname,
            token: token,
            default: difault,
            credentials: credentials
        });
    };

    $28.prototype.removeDatasource = function(projectEndpoint, category, datasource, projectToken){
        return this.api.Datasources(projectEndpoint).removeDatasource({
            category: category,
            datasource: datasource,
            token: projectToken
        });
    };

    $28.prototype.getDefaultMongoDBCredentials = function(projectName, token){
        return this.api.Project.getDefaultMongoDBCredentials({
            projectName: projectName,
            token: token
        });
    };

    $28.prototype.updateDefaultMongoDBCredentials = function(
        projectName, token, dbType, connString, db, username, password, preDigested
    ){
        return this.api.Project.updateDefaultMongoDBCredentials({
            projectName: projectName,
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

    $28.prototype.concurrencyCoercion = function(value, cmd){
        var intValue = Math.floor(Number(value));
        if (String(intValue) === value && intValue > 0) {
            return intValue; }
        else {
            console.error('Invalid option value for the concurrency option.'.red);
            cmd.help();
        }
    };


    return $28;
})();

exports.$28 = $28;
exports.VFS = require('./vfs').VFS;
