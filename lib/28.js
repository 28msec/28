'use strict';

var fs = require('fs');
var ffs = require('final-fs');
//var read = require('read');
var path = require('path');

var Q = require('q');

exports.$28 = function(apiEndpoint) {
    var $28 = require('28.io-nodejs').$28(apiEndpoint);

    this.login = function(email, password){
        return $28.Auth.authenticate({
            email: email,
            password: password,
            grant_type: 'client_credentials'
        });
    };
    
    this.refreshTokens = function(email, token){
        return $28.Auth.authenticate({
            email: email,
            refresh_token: token,
            grant_type: 'refresh_token'
        });
    };
    
    this.OVERWRITE_ALWAYS = 0;
    this.OVERWRITE_NEVER = 1;
    this.OVERWRITE_ASK = 2;
    this.OVERWRITE_IF_NEWER = 3;

    this.overwriteCoercion = function(value, cmd){
        value = value.toLowerCase();
        if(value === 'yes' || value === 'all' || value === 'always') {
            return this.OVERWRITE_ALWAYS;
        }else if(value === 'no' || value === 'none' || value === 'never') {
            return this.OVERWRITE_NEVER;
        } else if(value === 'ask') {
            return this.OVERWRITE_ASK;
        } else if(value === 'if-newer') {
            return this.OVERWRITE_IF_NEWER;
        } else {
            console.error('Invalid option value for overwrite.'.red);
            cmd.help();
        }
    };

    var getLocalQueries = function(localProjectPath){
        ffs.mkdirRecursiveSync(localProjectPath + 'modules', 511);
        ffs.mkdirRecursiveSync(localProjectPath + 'public', 511);
        ffs.mkdirRecursiveSync(localProjectPath + 'private', 511);
        var defered = Q.defer();
        Q.all([
            ffs.readdirRecursive(localProjectPath + 'modules', true, 'modules'),
            ffs.readdirRecursive(localProjectPath + 'public', true, 'public'),
            ffs.readdirRecursive(localProjectPath + 'private', true, 'private')
        ]).then(function(lists){
            var queries = {};
            lists.forEach(function(files){
                files.forEach(function(file){
                    queries[file] = {
                        lastModified: new Date(fs.statSync(file).mtime).toISOString()
                    };
                });
            });
            defered.resolve(queries);
        }).catch(function(error){
            defered.reject(error);
        });
        return defered.promise;
    };
    
    var getRemoteQueries = function(projectName, projectToken){
        var defered = Q.defer();
        Q.all([
            $28.Queries(projectName).listQueries({
                visibility: '',
                token: projectToken
            }),
            $28.Modules(projectName).listModules({
                includeSystem: false,
                includeNs: false,
                includeSrc: false,
                token: projectToken
            })
        ]).then(function(lists){
            var queries = {};
            lists[0].body.public.concat(
                lists[0].body.private
            ).forEach(function(query){
                var path = query.href.substring('/v1/_queries/'.length);
                queries[path] = {
                    lastModified: query.lastModified
                };
            });
            var modules = lists[1].body;
            Object.keys(modules).forEach(function(module){
                var path = 'modules' + module + '.' + modules[module].extension;
                queries[path] = {
                    lastModified: modules[module].lastModified
                };
            });
            defered.resolve(queries);
        }).catch(function(error){
            defered.reject(error);
        });
        return defered.promise;
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
            console.log(msg.green);
        } else {
            console.log(msg.red);
        }
    };
    
    var isModule = function(path) {
        return path.substring(0, 'modules'.length) === 'modules';
    };
    
    var modulePath = function(path) {
        var modulePath = path.substring('modules/'.length);
        return modulePath.substring(0, modulePath.lastIndexOf('.'));
    };
    
    var moduleExtension = function(path){
        var modulePath = modulePath(path);
        return path.substring(0, modulePath.length);
    };
    
    var writeLocalQuery = function(projectName, projectToken, localProjectPath, diff){
        var defered = Q.defer();
        var callback = function(response){
            var source = response.body;
            var dir = path.dirname(diff.query);
            ffs.mkdirRecursiveSync(dir, 511);
            ffs.writeFile(diff.query, source, { encoding: 'utf-8' }).then(function(){
                logDiff(diff);
                defered.resolve();
            })
            .otherwise(function(error){ defered.reject(error); });
        };
        if(isModule(diff.query)) {
            $28.Modules(projectName).getModule({ modulePath: modulePath(diff.query), token: projectToken })
            .then(callback)
            .catch(function(error){ defered.reject(error); });
        } else {
            $28.Queries(projectName).getQuery({ queryPath: diff.query, token: projectToken })
            .then(callback)
            .catch(function(error){ defered.reject(error); });
        }
        return defered.promise;
    };

    var deleteLocalQuery = function(localProjectPath, diff){
        var defered = Q.defer();
        ffs.unlink(diff.query).then(function(){
            logDiff(diff);
            defered.resolve();
        }).otherwise(function(error){
            defered.reject(error);
        });
        return defered.promise;
    };

    var writeRemoteQuery = function(projectName, projectToken, localProjectPath, diff){
        var defered = Q.defer();
        var callback = function(){
            //TODO: show compile errors
            logDiff(diff);
            defered.resolve();
        };
        ffs.readFile(localProjectPath + diff, { encoding: 'utf-8' }).then(function(source){
            if(isModule(diff.query)){
                $28.Modules(projectName).saveModule({
                    modulePath: modulePath(diff.query),
                    extension: moduleExtension(diff.query),
                    moduleBody: source,
                    token: projectToken
                }).then(callback);
            } else {
                $28.Queries(projectName).saveQuery({
                    queryPath: diff.query,
                    queryBody: source,
                    token: projectToken
                }).then(callback);
            }
        }).otherwise(function(error){
            defered.reject(error);
        });
        return defered.promise;
    };

    var deleteRemoteQuery = function(projectName, projectToken, diff){
        var promise;
        if(isModule(diff.query)){
            promise = $28.Modules(projectName).removeModule({
                modulePath: modulePath(diff.query),
                token: projectToken
            });
        } else {
            promise = $28.Queries(projectName).removeQuery({
                queryPath: diff.query,
                token: projectToken
            });
        }
        return promise.then(function(){
            logDiff(diff);
        });
    };

    var commit = function(projectName, projectToken, localProjectPath, simulate, diffs){
        var promises = [];
        diffs.forEach(function(diff){
            if(simulate) {
                logDiff(diff, simulate);
            } else if(diff.type === 'write'){
                if(diff.isOriginRemote) {
                    promises.push(writeLocalQuery(projectName, projectToken, localProjectPath, diff));
                } else {
                    promises.push(writeRemoteQuery(projectName, projectToken, localProjectPath, diff));
                }
            } else {
                if(diff.isOriginRemote) {
                    promises.push(deleteLocalQuery(localProjectPath, diff));
                } else {
                    promises.push(deleteRemoteQuery(projectName, projectToken, diff));
                }
            }
        });
        return Q.all(promises);
    };

    this.sync = function(localQueries, remoteQueries, projectName, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, isOriginRemote){
        var that = this;
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
                if(overwrite === that.OVERWRITE_ALWAYS){
                    diffs.push(diff);
                } else if(overwrite === that.OVERWRITE_IF_NEWER){
                    if((new Date(originLastModified)).getTime() > (new Date(targetLastModified)).getTime()){
                        diffs.push(diff);
                    }
                } else if(overwrite === that.OVERWRITE_ASK) {
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
                if(!origin[query]) {
                    diffs.push({
                        type: 'delete',
                        query: query,
                        isOriginRemote: isOriginRemote
                    });
                }
            });
        }
        return commit(projectName, projectToken, localProjectPath, simulate, diffs);
    };
    
    var filterQueries = function(list, ignore) {
        Object.keys(list).forEach(function(path){
            //Delete public or private files that don't have a .jq or .xq suffix
            if(
                (path.indexOf('public/') === 0 || path.indexOf('private/') === 0) &&
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
    
    var normalizeLocalProjectPath = function(localProjectPath){
        return localProjectPath[localProjectPath.length - 1] === '/' ? localProjectPath : (localProjectPath + '/');
    };

    this.download = function(projectName, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, ignore){
        var defered = Q.defer();
        var that = this;
        localProjectPath = normalizeLocalProjectPath(localProjectPath);
        Q.all([
            getLocalQueries(localProjectPath),
            getRemoteQueries(projectName, projectToken)
        ])
        .then(function(queries){
            var localQueries  = filterQueries(queries[0], ignore);
            var remoteQueries = filterQueries(queries[1], ignore);
            that.sync(localQueries, remoteQueries, projectName, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, true).then(function(){
                defered.resolve();
            }).catch(function(error) {
                defered.reject(error);
            });
        });
        return defered.promise;
    };
    
    this.upload = function(projectName, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, ignore){
        var defered = Q.defer();
        var that = this;
        localProjectPath = normalizeLocalProjectPath(localProjectPath);
        Q.all([
            getLocalQueries(localProjectPath),
            getRemoteQueries(projectName, projectToken)
        ])
        .then(function(queries){
            var localQueries  = filterQueries(queries[0], ignore);
            var remoteQueries = filterQueries(queries[1], ignore);
            that.sync(localQueries, remoteQueries, projectName, projectToken, localProjectPath, overwrite, deleteOrphaned, simulate, false).then(function(){
                defered.resolve();
            }).catch(function(error) {
                defered.reject(error);
            });
        });
        return defered.promise;
    };

    this.truncate = function(projectName, projectToken, localProjectPath, simulate, ignore){
        var defered = Q.defer();
        var that = this;
        localProjectPath = normalizeLocalProjectPath(localProjectPath);
        getRemoteQueries(projectName, projectToken).then(function(queries){
            var remoteQueries = filterQueries(queries, ignore);
            that.sync({}, remoteQueries, projectName, projectToken, localProjectPath, that.OVERWRITE_ALWAYS, true, simulate, false).then(function(){
                defered.resolve();
            }).catch(function(error) {
                defered.reject(error);
            });
        });
        return defered.promise;
    };
};
