 'use strict';

var fs  = require('fs');
var path = require('path');
var _ = require('underscore');
var catSettings = require('cat-settings');

var $28API = require('./28.js').$28;

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

exports.Config = {
    load: function(){
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
    },

    save: function(session){
        if(!this.config){
            throw new Error('No config file loaded. Use load()');
        }
        if(session.email) {
            this.config.email = session.email;
        }
        this.config.access_token = session.access_token;
        this.config.refresh_token = session.refresh_token;
        this.config.project_tokens = session.project_tokens;
        this.config.saveSync(this.settingFile);
    },

    getAPIEndpoint: function(){
        if(!this.config){
            throw new Error('No config file loaded. Use load()');
        }
        return this.config.protocol + '://' + this.config.project_name + '.' + this.config.project_domain + this.config.prefix;
    },
    
    getAPIClient: function(){
        return new $28API(this.getAPIEndpoint());
    },
    
    getEmail: function(){
        return this.config.email;
    },
    
    getRefreshToken: function(){
        return this.config.refresh_token;
    },
    
    getProjectList: function(){
        return Object.keys(this.config.project_tokens).map(function(project){ return project.substring('project_'.length); });
    },
    
    handleAPIError: function(error){
        if(error instanceof Error) {
            if(error.getCode() === 'ENOTFOUND') {
                console.error('Couldn\'t connect to API endpoint'.red);
            } else {
                throw error;
            }
        }
        console.error('Authentication failed. Server replied:'.red);
        console.error(error.response.body.red);
    },

    refreshTokens: function(){
        console.log('Refreshing Tokens...'.grey);
        var $28 = this.getAPIClient();
        var that = this;
        return $28.refreshTokens(this.getEmail(), this.getRefreshToken()).then(function(response){
            this.save(response.body);
            console.log('API Tokens refreshed.'.grey);
        })
        .catch(function(error){
            that.handleAPIError(error);
            console.error('\nUse the login command again.'.red);
        });
    }
};