var vows = require('vows');
//var assert = require('assert');

var cli = require('../lib/cli.js');

vows.describe('28/cli').addBatch({
    'Test Help': {
        'login without email': function () {
            try {
                cli.parse(['28', 'login']);
                throw new Error();
            } catch(error) {
            }
        }
    }
}).export(module);