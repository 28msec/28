'use strict';

var Q = require('q');
var cli = require('commander');
require('colors');

var pkg = require('../package.json');
var Config = require('./config').Config;

Config.load();

require('./commands/login');
require('./commands/projects');

cli.version(pkg.version);
module.exports = cli;
