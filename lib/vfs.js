'use strict';

var Q = require('q');
var fs = require('fs');
var ffs = require('final-fs');

exports.VFS = function($28, projectName, projectToken, localProjectPath){
    
    this.getLocalQueries = function(localProjectPath){
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
    
    this.getRemoteQueries = function($28, projectName, projectToken){
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
};
