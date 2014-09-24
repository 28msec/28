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

    this.getLocalQuery = function(path){
        return fs.readFileSync(path, 'utf-8');
    };
    
    this.getLocalQueries = function(){
        ffs.mkdirRecursiveSync(localProjectPath + 'modules', 511);
        ffs.mkdirRecursiveSync(localProjectPath + 'public', 511);
        ffs.mkdirRecursiveSync(localProjectPath + 'private', 511);
        return Q.all([
            ffs.readdirRecursive(localProjectPath + 'modules', true, 'modules'),
            ffs.readdirRecursive(localProjectPath + 'public', true,  'public'),
            ffs.readdirRecursive(localProjectPath + 'private', true, 'private')
        ]).then(function(lists){
            var queries = {};
            lists.forEach(function(files){
                files.forEach(function(file){
                    queries[file] = {
                        lastModified: new Date(fs.statSync(localProjectPath + file).mtime).toISOString()
                    };
                });
            });
            return queries;
        });
    };
    
    this.getRemoteQueries = function(){
        return Q.all([
            //Modules need to be listed/uploaded first,
            //so compilation errors on main queries can make sense.
            $28.Modules(projectName).listModules({
                includeSystem: false,
                includeNs: false,
                includeSrc: false,
                token: projectToken
            }),
            $28.Queries(projectName).listQueries({
                visibility: '',
                token: projectToken
            })
        ]).then(function(lists){
            var queries = {};
            //Modules need to be listed/uploaded first,
            //so compilation errors on main queries can make sense.
            var moduleIndex = 0;
            var queryIndex = 1;
            var modules = lists[moduleIndex].body;
            Object.keys(modules).forEach(function(module){
                var path = 'modules' + module + '.' + modules[module].extension;
                queries[path] = {
                    lastModified: modules[module].lastModified
                };
            });
            lists[queryIndex].body.public.concat(
                lists[queryIndex].body.private
            ).forEach(function(query){
                var path = query.href.substring('/v1/_queries/'.length);
                queries[path] = {
                    lastModified: query.lastModified
                };
            });
            return queries;
        });
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
        ffs.unlink(localProjectPath + query).then(function(){
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
                .then(function(){
                    defered.resolve();
                })
                .catch(function(error){ defered.reject(error); });
            } else {
                $28.Queries(projectName).saveQuery({
                    queryPath: query,
                    queryBody: source,
                    compile: 'lax',
                    token: projectToken
                })
                .then(function(result){
                    defered.resolve(result.body.compilationError);
                })
                .catch(function(error){ defered.reject(error); });
            }
        }).otherwise(function(error){
            defered.reject(error);
        });
        return defered.promise;
    };
    
    this.writeLocalQuery = function(query){
        var callback = function(response){
            var source = response.body;
            var dir = localProjectPath + path.dirname(query);
            ffs.mkdirRecursiveSync(dir, 511);
            ffs.writeFileSync(localProjectPath + query, source, { encoding: 'utf-8' });
        };

        if(isModule(query)) {
            return $28.Modules(projectName)
            .getModule({ modulePath: modulePath(query), token: projectToken })
            .then(callback);
        } else {
            return $28.Queries(projectName)
            .getQuery({ queryPath: query, token: projectToken })
            .then(callback);
        }
    };
};
