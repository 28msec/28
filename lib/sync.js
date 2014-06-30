'use strict';

var Q = require('q');
//var read = require('read');
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
        msg = 'Write  <' + loc(diff.isOriginRemote) + '>/' + diff.query;
        msg += ' to <' + loc(!diff.isOriginRemote) + '>/' + diff.query;
    } else {
        msg = 'Delete <' + loc(!diff.isOriginRemote) + '>/' + diff.query;
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
        return vfs.writeRemoteQuery(diff.query).then(function(){ logDiff(diff); });
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
        return Q.all(promises);
    };

    var sync = function(localQueries, remoteQueries, overwrite, deleteOrphaned, simulate, isOriginRemote){
        var diffs = [];
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
                    diffs.push(diff);
                } else if(overwrite === Options.OVERWRITE_IF_NEWER){
                    if((new Date(originLastModified)).getTime() > (new Date(targetLastModified)).getTime()){
                        diffs.push(diff);
                    }
                } else if(overwrite === Options.OVERWRITE_ASK) {
                    throw new Error('Not Implemented yet');
                    /*
                    read({
                        prompt: 'Overwrite : <' + loc(!isOriginRemote) + '>/' + query + ' (' + targetLastModified + ') with <' + loc(isOriginRemote) + '>/' + query + ' (' + originLastModified + ')? Y/[N]',
                        default: 'N'
                    }, function(er, value){
                        if(value !== undefined && value.toUpperCase() === 'Y') {
                            diffs.push(diff);
                        }
                    });
                    */
                }
            } else {
                diffs.push(diff);
            }
        });
        if(deleteOrphaned === true) {
            Object.keys(target).forEach(function(query) {
                if(origin[query] === undefined) {
                    diffs.push({
                        type: 'delete',
                        query: query,
                        isOriginRemote: isOriginRemote
                    });
                }
            });
        }
        return commit(simulate, diffs);
    };
    
    this.sync = function(overwrite, deleteOrphaned, simulate, ignore, isOriginRemote){
        var defered = Q.defer();
        Q.all([
            vfs.getLocalQueries(),
            vfs.getRemoteQueries()
        ])
        .then(function(queries){
            var localQueries  = filterQueries(queries[0], ignore);
            var remoteQueries = filterQueries(queries[1], ignore);
            sync(localQueries, remoteQueries, overwrite, deleteOrphaned, simulate, isOriginRemote).then(function(){
                defered.resolve();
            }).catch(function(error) {
                defered.reject(error);
            });
        });
        return defered.promise;
    };

    var that = this;
    this.download = function(overwrite, deleteOrphaned, simulate, ignore){
        return that.sync(overwrite, deleteOrphaned, simulate, ignore, true);
    };
    
    this.upload = function(overwrite, deleteOrphaned, simulate, ignore){
        return that.sync(overwrite, deleteOrphaned, simulate, ignore, false);
    };
    
    this.truncate = function(simulate, ignore){
        var defered = Q.defer();
        vfs.getRemoteQueries().then(function(queries){
            var remoteQueries = filterQueries(queries, ignore);
            sync({}, remoteQueries, Options.OVERWRITE_ALWAYS, true, simulate, false).then(function(){
                defered.resolve();
            }).catch(function(error) {
                defered.reject(error);
            });
        });
        return defered.promise;
    };
};