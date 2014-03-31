'use strict';

var API = require('./28.js');
var Client = require('./client.js');
var cli = require('./cli.js');

cli
.parse(process.argv);
if (!cli.args.length || !cli.matchedCommand) {
    cli.help();
}

exports.API = API;
exports.Client = Client;