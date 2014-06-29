'use strict';

var cli = require('commander');
require('colors');

var pkg = require('../package.json');
var Config = require('./config').Config;

Config.load();

require('./commands/login');
require('./commands/projects');
require('./commands/sync');
require('./commands/truncate');

cli.version(pkg.version);
module.exports = cli;
