'use strict';

// Requires
var Q = require('q');
var _ = require('underscore');
var fs  = require('fs');
var ffs = require('final-fs');
var path = require('path');
var cli = require('commander');
var read = require('read');

var pkg = require('../package.json');
var API = require('./28.js');
var Client = require('./client.js');

//Object Concatenation
function objectConcat(o1, o2) {
 for (var key in o2) {
  o1[key] = o2[key];
 }
 return o1;
}

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
var settingFile = __dirname + '/../.settings.json';
var localSettingFile = process.cwd() + '/.settings.json';
if(fs.existsSync(localSettingFile)) {
    settingFile = localSettingFile;
}
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

//Login Command
var loginCmd = cli
.command('login <email>')
.description('Sign-in into 28.io.')
.action(function(email) {
    if(!email) {
        console.log("Need email to authenticate: 28 -h for more infos");
        return;
    }

    read({ prompt: 'Password: ', silent: true, replace: '*' }, function(er, password) {
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
var projectsCmd = cli
.command('projects')
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
var dlCmd = cli.command('download <project-name>');
dlCmd.option(
    '-o, --overwrite <value>',
    'Overwrite local files. Value can be yes, no, if-newer, or ask.',
    function(value){
        if(value === 'yes') {
            return Client.OVERWRITE_ALWAYS;
        }else if(value === 'no') {
            return Client.OVERWRITE_NEVER;
        } else if(value === 'ask') {
            return Client.OVERWRITE_ASK;
        } else if(value === 'if-newer') {
            return Client.OVERWRITE_IF_NEWER;
        } else {
            //TODO: error
            return undefined;
        }           
    }
)
.option('-s, --simulate', 'Simulate for extra safety.')
.option('-d, --delete-orphaned', 'Delete orphaned files.')
.description('Download 28.io project.')
.action(function(projectName){
    refreshTokens()
    .then(function(){
        var projectToken = settings.project_tokens['project_'+projectName];
        if(projectToken) {
            ffs.mkdirRecursiveSync('lib', 511);
            ffs.mkdirRecursiveSync('public', 511);
            ffs.mkdirRecursiveSync('private', 511);
            var project = API.Project(apiSettings.getProjectAPI(projectName), projectToken);
            Q.all([
                project.listFiles()
                ,
                ffs.readdirRecursive('lib', true, 'lib')
                ,
                ffs.readdirRecursive('public', true, 'public')
                ,
                ffs.readdirRecursive('private', true, 'private')
            ])
            .then(function(lists){
                var remote = objectConcat(objectConcat(lists[0][0], lists[0][1]), lists[0][2]);
                var local = [];
                lists[1].forEach(function(path){
                    local[path] = {
                        lastModified: new Date(fs.statSync(path).mtime).toISOString()
                    };
                });
                lists[2].forEach(function(path){
                    local[path] = {
                        lastModified: new Date(fs.statSync(path).mtime).toISOString()
                    };
                });
                lists[3].forEach(function(path){
                    local[path] = {
                        lastModified: new Date(fs.statSync(path).mtime).toISOString()
                    };
                });
                Client.download(
                    project, remote, local,
                    dlCmd.overwrite === undefined ? Client.OVERWRITE_ASK : dlCmd.overwrite, 
                    dlCmd.deleteOrphaned ? true : false, 
                    dlCmd.simulate ? true : false
                )
                .then(function(){console.log('Done.');})
                .catch(function(error){
                    console.error(error);
                });
            })
            .catch(function(error){
                console.error('Server replied with:');
                console.error(error);
            });
        } else {
            console.error('Project ' + projectToken + ' wasn\'t found.');
            console.error('Run \'28 list projects\' for more information.');
        }
    }).catch(function(error){
        console.error(error);               
    });
});

//Upload Command
var upCmd = cli.command('upload <project-name>');
upCmd.option(
    '-o, --overwrite <value>',
    'Overwrite remote files. Value can be yes, no, if-newer, or ask.',
    function(value){
        if(value === 'yes') {
            return Client.OVERWRITE_ALWAYS;
        }else if(value === 'no') {
            return Client.OVERWRITE_NEVER;
        } else if(value === 'ask') {
            return Client.OVERWRITE_ASK;
        } else if(value === 'if-newer') {
            return Client.OVERWRITE_IF_NEWER;
        } else {
            //TODO: error
            return undefined;
        }           
    }
)
.option('-s, --simulate', 'Simulate for extra safety.')
.option('-d, --delete-orphaned', 'Delete orphaned files.')
.description('Download 28.io project.')
.action(function(projectName){
    refreshTokens()
    .then(function(){
        var projectToken = settings.project_tokens['project_'+projectName];
        if(projectToken) {
            ffs.mkdirRecursiveSync('lib', 511);
            ffs.mkdirRecursiveSync('public', 511);
            ffs.mkdirRecursiveSync('private', 511);
            var project = API.Project(apiSettings.getProjectAPI(projectName), projectToken);
            Q.all([
                project.listFiles()
                ,
                ffs.readdirRecursive('lib', true, 'lib')
                ,
                ffs.readdirRecursive('public', true, 'public')
                ,
                ffs.readdirRecursive('private', true, 'private')
            ])
            .then(function(lists){
                var remote = objectConcat(objectConcat(lists[0][0], lists[0][1]), lists[0][2]);
                var local = [];
                lists[1].forEach(function(path){
                    local[path] = {
                        lastModified: new Date(fs.statSync(path).mtime).toISOString()
                    };
                });
                lists[2].forEach(function(path){
                    local[path] = {
                        lastModified: new Date(fs.statSync(path).mtime).toISOString()
                    };
                });
                lists[3].forEach(function(path){
                    local[path] = {
                        lastModified: new Date(fs.statSync(path).mtime).toISOString()
                    };
                });
                Client.upload(
                    project, remote, local,
                    upCmd.overwrite === undefined ? Client.OVERWRITE_ASK : upCmd.overwrite, 
                    upCmd.deleteOrphaned ? true : false, 
                    upCmd.simulate ? true : false
                )
                .then(function(){console.log('Done.');})
                .catch(function(error){
                    console.error(error);
                });
            })
            .catch(function(error){
                console.error('Server replied with:');
                console.error(error);
            });
        } else {
            console.error('Project ' + projectToken + ' wasn\'t found.');
            console.error('Run \'28 list projects\' for more information.');
        }
    }).catch(function(error){
        console.error(error);               
    });
});

cli
.version(pkg.version)
.parse(process.argv);
if (!cli.args.length) cli.help();
