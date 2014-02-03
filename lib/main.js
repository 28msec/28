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
    'protocol': 'http',
    'project_name': 'api',
    'project_domain': 'local.xbrl.io:8080'
};
var settingFile = __dirname + '/../.settings.json';
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

var updateSettings = function(settings, session){
    settings.access_token = session.access_token;
    settings.refresh_token = session.refresh_token;
    settings.project_tokens = session.project_tokens;
    settings.saveSync(settingFile);
};

//Refresh Tokens
var refreshTokens = function(){
    var deferred = Q.defer();
    console.log('Refreshing API tokens...');
    
    API.Auth(apiSettings.API_URL)
    .auth({ grant_type: 'refresh_token', refresh_token: settings.refresh_token })
    .then(function(body){
        deferred.resolve(body);
    })
    .catch(function(error){  
        deferred.reject(error);
    });
    
    return deferred.promise;
};

var cmd;

//Login Command
cmd = cli
.command('login <email>')
.description('Sign-in into 28.io.')
.action(function(email) {
    if(!email) {
        console.log("Need email to authenticate: 28 -h for more infos");
        return;
    }

    read({ prompt: 'Password: ', silent: true }, function(er, password) {
        console.log('Authenticating...');
        API.Auth(apiSettings.API_URL)
        .auth({ email: email, password: password, grant_type: 'client_credentials' })
        .then(function(session){
            settings.email = email;
            updateSettings(settings, session);
            console.log("Success! API tokens have been saved.");
        })
        .catch(function(error){
            console.error('Authentication failed. Server replied:')
            console.error(error);      
        });
    });
});

//List Projects
cmd = cli
.command('list projects')
.description('List of 28.io projects.')
.action(function(){
    refreshTokens()
    .then(function(body){
        var keys = Object.keys(body.project_tokens);
        console.log('Project List:');
        keys.forEach(function(key){
            console.log('* ' + key.substring('project_'.length));
        });
    })
    .catch(function(error){  
        console.log("Failed to authenticate. Please run: 28 login <your email>");
        console.error('Server replied with:');
        console.error(error);
    });
});

//Download Command
cmd = cli
.command('download <project-name>')
.option(
    '-o, --overwrite [value]',
    'Overwrite local files. Value can be yes, no, or ask.',
    function(value){
        if(value === 'yes') {
            return true;
        } else if(value === 'ask') {
            return null;
        } else {
            return false;
        }
                   
    }
)
.option('-s, --simulate', 'Simulate for extra safety.')
.option('-d, --deleted-orphanated-files', 'Delete orphanated files.')
.description('Download 28.io project.')
.action(function(projectName){
    //console.log(cmd.overwrite);
    //console.log(cmd.simulate);
    //console.log(cmd.deleteOrphanatedFiles);
    refreshTokens()
    .then(function(){
        var projectToken = settings.project_tokens['project_'+projectName];
        if(projectToken) {
            //console.log(projectToken);
            //console.log(apiSettings.getProjectAPI(projectName));
            //var p = API.Project(apiSettings.getProjectAPI(projectName), projectToken);
            //console.log(p);
            try {
                API.Project(apiSettings.getProjectAPI(projectName), projectToken)
                .listFiles()
                .then(function(list){
                    console.log(list);
                });
            } catch(e) {
                console.log(e);   
            }
            /*
            .listFiles()
            .then(function(list){
                console.log('list');
            })
            .catch(function(error){
                console.error('Server replied with:');
                console.error(error);
            });
            */
        } else {
            console.error('Project ' + projectToken + ' wasn\'t found.');
            console.error('Run \'28 list projects\' for more information.');
        }
    });
});

//Upload Command

cli
.version(pkg.version)
.parse(process.argv);
if (!cli.args.length) cli.help();