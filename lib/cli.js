'use strict';

var cli = require('commander');
require('colors');

var pkg = require('../package.json');
var Config = require('./config').Config;

Config.load();

require('./commands/login');
require('./commands/sync');
require('./commands/truncate');
require('./commands/watch');
require('./commands/run');

cli.command('projects', 'Project management');
cli.command('datasources', 'Datasources management');

cli.version(pkg.version);
cli.parse(process.argv);

if (!cli.args.length) {
    cli.help();
}
