// Requires
var Q = require('q');
var _ = require('underscore');
var fs  =  require('fs');
var path = require('path');
var cli = require('commander');
var read = require('read');

var pkg = require('../package.json');
var API = require('./28.js');

// Settings
var defaultSettings = {
    'access_token': '',
    'refresh_token': '',
    'project_tokens': {},
    'email': '',
    'protocol': 'https',
    'project_name': 'portal',
    'project_domain': '28.io'
};
var settingFile = __dirname + '/../settings.json';
if(!fs.existsSync(settingFile)) {
    fs.writeFileSync(settingFile, JSON.stringify(defaultSettings, null, 4));
}
var settings = require('cat-settings').loadSync(settingFile);
_.defaults(settings, defaultSettings);


var PROJECT_PROTOCOL = settings.protocol;
var PROJECT_NAME = settings.project_name;
var PROJECT_DOMAIN = settings.project_domain;
var apiSettings = {
      API_URL: PROJECT_PROTOCOL + '://' + PROJECT_NAME + '.' + PROJECT_DOMAIN,
      API_VERSION: 'v1',
      DOMAIN: PROJECT_DOMAIN,
      getProjectAPI: function(name) { return PROJECT_PROTOCOL + '://' + name + '.' + PROJECT_DOMAIN + '/' + this.API_VERSION; }
};

//Login Command
cli
.command('login [email]')
.description('Sign-in into 28.io.')
.action(function(email) {
    if(!email) {
        console.log("Need token to authenticate: 28 -h for more infos");
        return;
    }

    read({ prompt: 'Password: ', silent: true }, function(er, password) {
        console.log('Authenticating...');
        API.Auth(apiSettings.API_URL)
        .auth({ email: email, password: password, grant_type: 'client_credentials' })
        .then(function(body){
            settings.access_token = body.access_token;
            settings.refresh_token = body.refresh_token;
            settings.project_tokens = body.project_tokens;
            settings.email = email;
            settings.saveSync(settingFile);
            console.log("Success! API tokens have been saved.");
        })
        .catch(function(error){
            console.error('Authentication failed. Server replied:')
            console.error(error);
        });
    });
});


cli.version(pkg.version).parse(process.argv);
if (!cli.args.length) cli.help();