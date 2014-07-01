'use strict';

var vows = require('vows');
var assert = require('assert');
var EventEmitter = require('events').EventEmitter;

var $28 = new (require('../lib/28.js').$28)('https://portal.28.io/api');

var email = 'w+test@28.io';

vows.describe('API Tests').addBatch({
    'Test Login': {
        'login with wrong password': {
            topic: function(){
                var promise = new EventEmitter();
                $28.login(email, 'foobar1')
                .then(function(result){
                    promise.emit('success', result);
                }, function(result){
                    promise.emit('error', result.body);
                });
                return promise;
            },
            'Should have a wrong password error': function(error, success){
                assert.equal(success, undefined, 'Shouldn\'t be a success.');
                assert.equal(error.code, 'errors:wrong-password', 'Wrong password');
            }
        },
        'login with correct password': {
            topic: function(){
                var promise = new EventEmitter();
                $28.login(email, 'foobar')
                .then(function(result){
                    promise.emit('success', result.body);
                }, function(result){
                    promise.emit('error', result.body);
                });
                return promise;
            },
            'Should have access tokens': function(error, session){
                assert.equal(error, undefined, 'Shouldn\'t be an error.');
                assert.equal(session.access_token !== undefined, true, 'Should have access token');
            },
            'Refresh tokens': {
                topic: function(session){
                    var promise = new EventEmitter();
                    $28.refreshTokens(email, session.refresh_token)
                    .then(function(result){
                        promise.emit('success', result.body);
                    }, function(result){
                        promise.emit('error', result.body);
                    });
                    return promise;
                },
                'Should get new session': function(error, session){
                    assert.equal(error, undefined, 'Shouldn\'t be an error.');
                    assert.equal(session.access_token !== undefined, true, 'Should have access token');
                }
            },
            'Invalid Refresh tokens': {
                topic: function(session){
                    var promise = new EventEmitter();
                    $28.refreshTokens(email, '123')
                    .then(function(result){
                        promise.emit('success', result.body);
                    }, function(result){
                        promise.emit('error', result.body);
                    });
                    return promise;
                },
                'Shouldn\'t get new session': function(error, session){
                    assert.equal(session, undefined, 'Shouldn\'t be a success.');
                    assert.equal(error.code, 'errors:invalid-token', 'Invalid tokens');
                }
            }
        }
    }
}).export(module);