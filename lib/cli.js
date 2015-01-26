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
require('./commands/datasources');
require('./commands/watch');
require('./commands/trace');

cli.version(pkg.version);
module.exports = cli;
