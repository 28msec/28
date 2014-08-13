'use strict';

require('colors');

var Q = require('q');
var read = require('read');
var VFS = require('./vfs').VFS;

var filterQueries = function(list, ignore) {
    Object.keys(list).forEach(function(path){
        //Filter files that don't have a .jq or .xq suffix
        if(
            path.substring(path.length - 3) !== '.jq' &&
            path.substring(path.length - 3) !== '.xq'
        ) {
            delete list[path];
        } else {
            var matched = false;
            ignore.forEach(function(mask){
                if(path.match(mask) !== null) {
                    matched = true;
                    return false;
                }
            });
            if(matched === true) {
                delete list[path];
            }
        }
    });
    return list;
};

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

var  Options = {
    OVERWRITE_ALWAYS: 0,
    OVERWRITE_NEVER: 1,
    OVERWRITE_ASK: 2,
    OVERWRITE_IF_NEWER: 3
};
exports.Options = Options;

exports.Client = function($28, projectName, projectToken, localProjectPath){
    var vfs = new VFS($28, projectName, projectToken, localProjectPath);

    var writeLocalQuery = function(diff){
        return vfs.writeLocalQuery(diff.query).then(function(){ logDiff(diff); });
    };
    
    var writeRemoteQuery = function(diff){
        return vfs.writeRemoteQuery(diff.query)
        .then(function(compileError){
            logDiff(diff);
            if(compileError) {
                throw compileError;
            }
        });
    };
    
    var deleteLocalQuery = function(diff){
        return vfs.deleteLocalQuery(diff.query).then(function(){ logDiff(diff); });
    };

    var deleteRemoteQuery = function(diff){
        return vfs.deleteRemoteQuery(diff.query).then(function(){ logDiff(diff); });
    };
    
    var commit = function(simulate, diffs){
        var promises = [];
        diffs.forEach(function(diff){
            if(simulate) {
                logDiff(diff, simulate);
            } else if(diff.type === 'write'){
                if(diff.isOriginRemote) {
                    promises.push(writeLocalQuery(diff));
                } else {
                    promises.push(writeRemoteQuery(diff));
                }
            } else {
                if(diff.isOriginRemote) {
                    promises.push(deleteLocalQuery(diff));
                } else {
                    promises.push(deleteRemoteQuery(diff));
                }
            }
        });
        return Q.allSettled(promises).then(function(results){
            var errors = [];
            results.forEach(function (result) {
                if (result.state !== 'fulfilled') {
                    errors.push(result.reason);
                }
            });
            if(errors.length > 0) {
                var output = '';
                errors.forEach(function(error){
                    output += JSON.stringify(error, null, 2);
                });
                throw output;
            }
            return results;
        });
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

    var sync = function(localQueries, remoteQueries, overwrite, deleteOrphaned, simulate, isOriginRemote){
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
                if(overwrite === Options.OVERWRITE_ALWAYS){
                    promises.push(addDiff(diff));
                } else if(overwrite === Options.OVERWRITE_IF_NEWER){
                    if((new Date(originLastModified)).getTime() > (new Date(targetLastModified)).getTime()){
                        promises.push(addDiff(diff));
                    }
                } else if(overwrite === Options.OVERWRITE_ASK) {
                    promises.push(function(diffs){
                        var defered = Q.defer();
                        read({
                            prompt: 'Overwrite: <' + loc(!isOriginRemote) + '>/' + query + ' (' + targetLastModified + ') with <' + loc(isOriginRemote) + '>/' + query + ' (' + originLastModified + ')? Y/[N]',
                            default: 'N'
                        }, function(er, value){
                            if(er) {
                                defered.reject(er);
                            }
                            if(value !== undefined && value.toUpperCase() === 'Y') {
                                diffs.push(diff);
                            }
                            defered.resolve(diffs);
                        });
                        return defered.promise;
                    });
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
        promises.push(function(diffs){ return commit(simulate, diffs); });
        return promises.reduce(Q.when, new Q([]));
    };
    
    this.sync = function(overwrite, deleteOrphaned, simulate, ignore, isOriginRemote){
        return Q.all([
            vfs.getLocalQueries(),
            vfs.getRemoteQueries()
        ])
        .then(function(queries){
            var localQueries  = filterQueries(queries[0], ignore);
            var remoteQueries = filterQueries(queries[1], ignore);
            return sync(localQueries, remoteQueries, overwrite, deleteOrphaned, simulate, isOriginRemote);
        });
    };

    var that = this;
    this.download = function(overwrite, deleteOrphaned, simulate, ignore){
        return that.sync(overwrite, deleteOrphaned, simulate, ignore, true);
    };
    
    this.upload = function(overwrite, deleteOrphaned, simulate, ignore){
        return that.sync(overwrite, deleteOrphaned, simulate, ignore, false);
    };
    
    this.truncate = function(simulate, ignore){
        return vfs.getRemoteQueries().then(function(queries){
            var remoteQueries = filterQueries(queries, ignore);
            return sync({}, remoteQueries, Options.OVERWRITE_ALWAYS, true, simulate, false);
        });
    };
};
