'use strict';

var fs = require('fs');
var path = require('path');
var Q = require('q');
var ffs = require('final-fs');

var isModule = function(path) {
    return path.substring(0, 'modules'.length) === 'modules';
};

var modulePath = function(path) {
    var modulePath = path.substring('modules/'.length);
    return modulePath.substring(0, modulePath.lastIndexOf('.'));
};

var moduleExtension = function(path){
    var m = modulePath(path);
    return path.substring(m.length + 'modules/'.length + 1);
};

var normalizeLocalProjectPath = function(localProjectPath){
    return localProjectPath[localProjectPath.length - 1] === '/' ? localProjectPath : (localProjectPath + '/');
};

exports.VFS = function($28, projectName, projectToken, localProjectPath){
    localProjectPath = localProjectPath ? normalizeLocalProjectPath(localProjectPath) : '';

    this.getLocalQueries = function(){
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
    
    this.getRemoteQueries = function(){
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
    
    this.deleteRemoteQuery = function(query){
        var promise;
        if(isModule(query)){
            promise = $28.Modules(projectName).removeModule({
                modulePath: modulePath(query),
                token: projectToken
            });
        } else {
            promise = $28.Queries(projectName).removeQuery({
                queryPath: query,
                token: projectToken
            });
        }
        return promise;
    };
    
    this.deleteLocalQuery = function(query){
        var defered = Q.defer();
        ffs.unlink(query).then(function(){
            defered.resolve();
        }).otherwise(function(error){
            defered.reject(error);
        });
        return defered.promise;
    };
    
    this.writeRemoteQuery = function(query){
        var defered = Q.defer();
        ffs.readFile(localProjectPath + query, { encoding: 'utf-8' }).then(function(source){
            source = source.toString();
            if(isModule(query)){
                $28.Modules(projectName).saveModule({
                    modulePath: modulePath(query),
                    extension: moduleExtension(query),
                    moduleBody: source,
                    compile: 'lax',
                    token: projectToken
                })
                .then(function(){ defered.resolve(); })
                .catch(function(error){ defered.reject(error); });
            } else {
                $28.Queries(projectName).saveQuery({
                    queryPath: query,
                    queryBody: source,
                    compile: 'lax',
                    token: projectToken
                })
                .then(function(){ defered.resolve(); })
                .catch(function(error){ defered.reject(error); });
            }
        }).otherwise(function(error){
            defered.reject(error);
        });
        return defered.promise;
    };
    
    this.writeLocalQuery = function(query){
        var defered = Q.defer();
        var callback = function(response){
            var source = response.body;
            var dir = path.dirname(query);
            ffs.mkdirRecursiveSync(dir, 511);
            ffs.writeFile(query, source, { encoding: 'utf-8' }).then(function(){
                defered.resolve();
            })
            .otherwise(function(error){ defered.reject(error); });
        };
        if(isModule(query)) {
            $28.Modules(projectName).getModule({ modulePath: modulePath(query), token: projectToken })
            .then(callback)
            .catch(function(error){ defered.reject(error); });
        } else {
            $28.Queries(projectName).getQuery({ queryPath: query, token: projectToken })
            .then(callback)
            .catch(function(error){ defered.reject(error); });
        }
        return defered.promise;
    };
};
