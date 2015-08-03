'use strict';

var fs  = require('fs');
var path = require('path');
var _ = require('lodash');
var Q = require('q');
var catSettings = require('cat-settings');

var $28API = require('./28.js').$28;
var $28;

var Config = (function(){

    // Settings
    var defaultSettings = {
        'access_token': '',
        'refresh_token': '',
        'project_tokens': {},
        'email': '',
        'protocol': 'https',
        'project_name': 'portal',
        'project_domain': '28.io',
        'ignore': [],
        'prefix': '/api'
    };

    var isIP = function(endpoint) {
        return /^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.test(endpoint);
    };

    function Config() {}

    Config.prototype.load = function(){
        this.settingFile = path.join(process.env.HOME || process.env.USERPROFILE || '', '.28.json');
        var localSettingFile = process.cwd() + '/.28.json';
        if(fs.existsSync(localSettingFile)) {
            this.settingFile = localSettingFile;
        }
        if(!fs.existsSync(this.settingFile)) {
            fs.writeFileSync(this.settingFile, JSON.stringify(defaultSettings, null, 4));
        }
        this.config = catSettings.loadSync(this.settingFile);
        _.defaults(this.config, defaultSettings);
        return this;
    };

    Config.prototype.save = function(session){
        if(!this.config){
            throw new Error('No config file loaded. Use load()');
        }
        if(session.email) {
            this.config.email = session.email;
        }
        this.config.expiration_date = session.expiration_date;
        this.config.access_token = session.access_token;
        this.config.refresh_token = session.refresh_token;
        this.config.project_tokens = session.project_tokens;
        this.config.saveSync(this.settingFile);
        return this;
    };

    Config.prototype.getProjectEndpoint = function(projectName){
        if(!this.config){
            throw new Error('No config file loaded. Use load()');
        }
        if(isIP(this.config.project_domain)) {
            return this.config.protocol + '://' + this.config.project_domain + '/' + projectName + '/v1/_queries';
        } else {
            return this.config.protocol + '://' + projectName + '.' + this.config.project_domain + '/v1/_queries';
        }
    };

    Config.prototype.getAPIEndpoint = function(){
        if(!this.config){
            throw new Error('No config file loaded. Use load()');
        }
        if(isIP(this.config.project_domain)) {
            return this.config.protocol + '://' + this.config.project_domain + '/' + this.config.project_name + this.config.prefix;
        } else {
            return this.config.protocol + '://' + this.config.project_name + '.' + this.config.project_domain + this.config.prefix;
        }
    };

    Config.prototype.getAPIClient = function(){
        if($28 === undefined) {
            $28 = new $28API(this.getAPIEndpoint());
        }
        return $28;
    };

    Config.prototype.getEmail = function(){
        return this.config.email;
    };

    Config.prototype.getDefaultProject = function(){
        return this.config.default_project;
    };

    Config.prototype.getRefreshToken = function(){
        return this.config.refresh_token;
    };

    Config.prototype.getAccessToken = function(){
        return this.config.access_token;
    };

    Config.prototype.getProjectToken = function(projectName){
        var token = this.config.project_tokens['project_'+projectName];
        if(!token) {
            throw new Error('Project not found: ' + projectName + '. Run "28 projects" to view the list of available projects.');
        }
        return token;
    };

    Config.prototype.getIgnoreList = function(){
        return this.config.ignore;
    };

    Config.prototype.filterQuery = function(path) {
        if(path.substring(path.length - 3) !== '.jq' && path.substring(path.length - 3) !== '.xq') {
            return false;
        } else {
            var matched = false;
            this.config.ignore.forEach(function(mask){
                if(path.match(mask) !== null) {
                    matched = true;
                    return false;
                }
            });
            if(matched === true) {
                return false;
            }
            return true;
        }
    };

    Config.prototype.filterQueries = function(aList){
        var that = this;
        var list = _.clone(aList);
        Object.keys(list).forEach(function(path){
            if(!that.filterQuery(path)) {
                delete list[path];
            }
        });
        return list;
    };

    Config.prototype.getProjectList = function(){
        return Object.keys(this.config.project_tokens).map(function(project){ return project.substring('project_'.length); });
    };

    Config.prototype.getProjects = function(){
        var that = this;
        var $28 = this.getAPIClient();
        return $28.api.Project.listProjects({
            token: that.getAccessToken()
        });
    };

    Config.prototype.handleAPIAuthError = function(error){
        if(error instanceof Error) {
            if(error.getCode() === 'ENOTFOUND') {
                console.error('Couldn\'t connect to API endpoint'.red);
            } else {
                throw error;
            }
        }
        console.error('Authentication failed. Server replied:'.red);
        console.error(error.response.body.red);
        process.exit(1);
    };

    Config.prototype.handleAPIError = function(error){
        if(error instanceof Error) {
            console.error(error.message.red);
            console.error((error.fileName + ':' + error.lineNumber).red);
            console.error(error.stack.toString().red);
        } else if(error && error.body) {
            console.error(error.body);
        } else if(error !== undefined) {
            console.error(error);
        } else {
            console.error('Command exited with errors.'.red);
        }
        process.exit(1);
    };

    Config.prototype.refreshTokens = function (projectName) {
        var $28 = this.getAPIClient();
        var that = this;
        var exp = new Date(this.config.expiration_date).getTime();
        var now = new Date().getTime();
        if(now + 60 * 60 < exp && projectName && this.config.project_tokens['project_'+projectName]) {
            return new Q();
        }
        return $28.refreshTokens(this.getEmail(), this.getRefreshToken()).then(function (response) {
            console.log('Refreshing Tokens...'.grey);
            var session = response.body;
            that.save(session);
            var rem = new Date(session.expiration_date);
            rem.setHours(rem.getHours() - 12);
            var now = new Date();
            if (Math.abs(now.getTime() - rem.getTime()) > 30 * 1000) {
                console.error('\nWarning: the local and remote clocks seems to be out of sync.'.yellow);
                console.error('Be careful if you plan on using synchronization features that rely on the files last modified date time.'.yellow);
                console.error(('Local time ' + now.toISOString()).yellow);
                console.error(('Remote time ' + rem.toISOString() + '\n').yellow);
            }
            console.log('API Tokens refreshed.'.grey);
        })
            .catch(function (error) {
                console.error('\nUse the login command again.'.red);
                that.handleAPIAuthError(error);
            });
    };

    return Config;
})();

exports.Config = new Config();
