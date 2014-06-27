'use strict';

var fs  = require('fs');
var path = require('path');
var _ = require('underscore');
var catSettings = require('cat-settings');

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
        this.config.email = session.email;
        this.config.access_token = session.access_token;
        this.config.refresh_token = session.refresh_token;
        this.config.project_tokens = session.project_tokens;
        this.config.saveSync(this.settingFile);
    },

    getAPIEndpoint: function(){
        if(!this.config){
            throw new Error('No config file loaded. Use load()');
        }
        console.log(this.config.protocol + '://' + this.config.project_name + '.' + this.config.project_domain + this.config.prefix);
        return this.config.protocol + '://' + this.config.project_name + '.' + this.config.project_domain + this.config.prefix;
    }
};