'use strict';

var vows = require('vows');
var assert = require('assert');
var EventEmitter = require('events').EventEmitter;
var _ = require('lodash');
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
            },
            'Upload (1)': {
                topic: function(session){
                    var promise = new EventEmitter();
                    var projectName = 'vows-project';
                    var projectToken = session.project_tokens['project_' + projectName];
                    if(!projectToken) {
                        throw new Error('project not found ' + projectName);
                    }
                    var projectPath = 'tests/test_project';
                    var overwrite = 0, deleteOrphaned = true, simulate = false;
                    $28
                    .upload(projectName, projectToken, projectPath, overwrite, deleteOrphaned, simulate, function(list){ return list; })
                    .then(function(success){
                        promise.emit('success', success);
                    })
                    .catch(function(error){
                        promise.emit('error', error);
                    });
                    return promise;
                },
                'Upload shouldn\'t succeed': function(error, success){
                    assert.equal(success, undefined);
                    assert.equal(_.isObject(error), true);
                }
            },
            'Upload (2)': {
                topic: function(session){
                    var promise = new EventEmitter();
                    var projectName = 'vows-project';
                    var projectToken = session.project_tokens['project_' + projectName];
                    if(!projectToken) {
                        throw new Error('project not found ' + projectName);
                    }
                    var projectPath = 'tests/test_project2';
                    var overwrite = 0, deleteOrphaned = true, simulate = false;
                    $28
                        .upload('http://vows-project.28.io/v1', projectToken, projectPath, overwrite, deleteOrphaned, simulate, function(list){ return list; })
                        .then(function(success){
                            promise.emit('success', success);
                        })
                        .catch(function(error){
                            promise.emit('error', error);
                        });
                    return promise;
                },
                'Upload should succeed': function(error, success){
                    assert.equal(error, undefined);
                    assert.equal(success !== undefined, true);
                }
            }
        }
    }
}).export(module);