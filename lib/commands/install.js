'use strict';

var cli = require('commander');
var Config = require('../config').Config;
var $28 = Config.getAPIClient();

//Install command
cli
.command('install')
.description('This command installs a JSONiq package, and any packages that it depends on..')
.action(function() {
    return $28.install();
});

//Install command
cli
.command('uninstall')
.description('This command uninstalls a JSONiq package, and any packages that it depends on..')
.action(function() {
    return $28.uninstall();
});