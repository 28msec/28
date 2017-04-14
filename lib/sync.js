'use strict';

require('colors');

var Q = require('q');
var read = require('read');
var http = require('http');
var https = require('https');
var VFS = require('./vfs').VFS;

var Client = (function(){

    var Options = {
        OVERWRITE_ALWAYS: 0,
        OVERWRITE_NEVER: 1,
        OVERWRITE_ASK: 2,
        OVERWRITE_IF_NEWER: 3
    };
    exports.Options = Options;

    var loc = function(isOriginRemote){
        return isOriginRemote ? 'remote' : 'local';
    };

    var logDiff = function(diff, simulate){
        var msg;
        if(diff.type === 'write') {
            if(diff.isOriginRemote) {
                msg = ('<< '.green) + ('↙ '.blue) + diff.query;
            } else {
                msg = ('>> '.green) + ('↗ '.blue) + diff.query;
            }
        } else {
            msg = ('✗'.red) + ' <' + loc(!diff.isOriginRemote) + '>/' + diff.query;
        }
        if(simulate === true) {
            msg += ' (simulate)';
        }
        if(diff.type === 'write') {
            console.log(msg);
        } else {
            console.log(msg.red);
        }
    };

    var addDiff = function(diff){
        return function(diffs){
            var defered = Q.defer();
            setTimeout(function() {
                diffs.push(diff);
                defered.resolve(diffs);
            }, 1);
            return defered.promise;
        };
    };


    function Client($28, projectEndpoint, projectToken, localProjectPath){
        this.vfs = new VFS($28, projectEndpoint, projectToken, localProjectPath);
    }

    Client.prototype.syncImpl = function(localQueries, remoteQueries, overwrite, deleteOrphaned, simulate, isOriginRemote){
        var that = this;
        var promises = [];
        var origin = isOriginRemote ? remoteQueries : localQueries;
        var target = isOriginRemote ? localQueries : remoteQueries;
        Object.keys(origin).forEach(function(query) {
            var targetQuery = target[query];
            var diff = {
                type: 'write',
                query: query,
                isOriginRemote: isOriginRemote
            };
            if(targetQuery) {
                var originLastModified = origin[query].lastModified;
                var targetLastModified = targetQuery.lastModified;
                if(overwrite === Options.OVERWRITE_ALWAYS) {
                    promises.push(addDiff(diff));
                } else if(overwrite === Options.OVERWRITE_IF_NEWER) {
                    if((new Date(originLastModified)).getTime() > (new Date(targetLastModified)).getTime()){
                        promises.push(addDiff(diff));
                    }
                } else if(overwrite === Options.OVERWRITE_ASK) {
                    promises.push(function (diffs) {
                        var defered = Q.defer();
                        read({
                            prompt: 'Overwrite: <' + loc(!isOriginRemote) + '>/' + query + ' (' + targetLastModified + ') with <' + loc(isOriginRemote) + '>/' + query + ' (' + originLastModified + ')? Y/[N]',
                            default: 'N'
                        }, function (er, value) {
                            if (er) {
                                defered.reject(er);
                            }
                            if (value !== undefined && value.toUpperCase() === 'Y') {
                                diffs.push(diff);
                            }
                            defered.resolve(diffs);
                        });
                        return defered.promise;
                    });
                } else if(overwrite === Options.OVERWRITE_NEVER) {
                    //Do nothing
                } else {
                    throw new Error('Invalid overwrite value: ' + overwrite);
                }
            } else {
                promises.push(addDiff(diff));
            }
        });
        if(deleteOrphaned === true) {
            Object.keys(target).forEach(function(query) {
                if(origin[query] === undefined) {
                    promises.push(addDiff({
                        type: 'delete',
                        query: query,
                        isOriginRemote: isOriginRemote
                    }));
                }
            });
        }
        promises.push(function(diffs){ return that.commit(simulate, diffs); });
        return promises.reduce(Q.when, new Q([]));
    };

    Client.prototype.writeLocalQuery = function(diff){
        return this.vfs.writeLocalQuery(diff.query).then(function(){ logDiff(diff); });
    };

    Client.prototype.writeRemoteQuery = function(diff){
        return this.vfs.writeRemoteQuery(diff.query)
            .then(function(compileError){
                logDiff(diff);
                if(compileError) {
                    compileError.query = diff.query;
                    throw compileError;
                }
            });
    };

    Client.prototype.deleteLocalQuery = function(diff){
        return this.vfs.deleteLocalQuery(diff.query).then(function(){ logDiff(diff); });
    };

    Client.prototype.deleteRemoteQuery = function(diff){
        return this.vfs.deleteRemoteQuery(diff.query).then(function(){ logDiff(diff); });
    };

    Client.prototype.commit = function(simulate, diffs){
        var that = this;
        var modulePromises = [];
        var queryPromises = [];
        diffs.forEach(function(diff){
            var container = diff.query.substring(0, 'modules'.length) === 'modules' ? modulePromises : queryPromises;
            if(simulate) {
                logDiff(diff, simulate);
            } else if(diff.type === 'write'){
                if(diff.isOriginRemote) {
                    container.push(function(){ return that.writeLocalQuery(diff); });
                } else {
                    container.push(function(){ return that.writeRemoteQuery(diff); });
                }
            } else {
                if(diff.isOriginRemote) {
                    container.push(function(){ return that.deleteLocalQuery(diff); });
                } else {
                    container.push(function(){ return that.deleteRemoteQuery(diff); });
                }
            }
        });

        var handler = function(results){
            var errors = [];
            results.forEach(function (result) {
                if (result.state !== 'fulfilled') {
                    errors.push(result.reason);
                }
            });
            if(errors.length > 0) {
                throw errors;
            }
            return results;
        };

        return [
            function(){
                var promises = [];
                modulePromises.forEach(function(promise){
                    promises.push(promise());
                });
                return Q.allSettled(promises).then(handler);
            },
            function(){
                var promises = [];
                queryPromises.forEach(function(promise){
                    promises.push(promise());
                });
                return Q.allSettled(promises).then(handler);
            }
        ].reduce(Q.when, new Q([]));
    };

    Client.prototype.sync = function(overwrite, deleteOrphaned, simulate, ignore, isOriginRemote, concurrency){
        if (concurrency === undefined) {
          http.globalAgent.maxSockets = 8;
          https.globalAgent.maxSockets = 8;
          console.log('Concurrency limit: 8.'.grey);
        }
        else {
          http.globalAgent.maxSockets = concurrency;
          https.globalAgent.maxSockets = concurrency;
          console.log('Concurrency limit: ' + concurrency + '.'.grey);
        }
        var that = this;
        return Q.all([
            this.vfs.getLocalQueries(),
            this.vfs.getRemoteQueries()
        ])
            .then(function(queries){
                var localQueries  = ignore(queries[0]);
                var remoteQueries = ignore(queries[1]);
                return that.syncImpl(localQueries, remoteQueries, overwrite, deleteOrphaned, simulate, isOriginRemote);
            });
    };

    Client.prototype.download = function(overwrite, deleteOrphaned, simulate, ignore, concurrency){
        return this.sync(overwrite, deleteOrphaned, simulate, ignore, true, concurrency);
    };

    Client.prototype.upload = function(overwrite, deleteOrphaned, simulate, ignore, concurrency){
        return this.sync(overwrite, deleteOrphaned, simulate, ignore, false, concurrency);
    };

    Client.prototype.truncate = function(simulate, ignore){
        var that = this;
        return this.vfs.getRemoteQueries().then(function(queries){
            var remoteQueries = ignore(queries);
            return that.syncImpl({}, remoteQueries, Options.OVERWRITE_ALWAYS, true, simulate, false);
        });
    };

    return Client;
})();

exports.Client = Client;
