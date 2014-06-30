'use strict';

var vows = require('vows');
var assert = require('assert');

var cli = require('../lib/cli.js');

vows.describe('28/cli').addBatch({
    'Test Help': {
        'login without email': function () {
            cli.parse(['28', 'login']);
            assert.equal(cli.args.length, 0);
        },
        'login with email': function () {
            cli.parse(['28', 'login', 'w+test@28.io']);
            assert.equal(cli.args.length, 1);
            assert.equal(cli.args[0], 'w+test@28.io');
        }
    }
}).export(module);