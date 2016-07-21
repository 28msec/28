'use strict';

var fs = require('fs');
var path = require('path');
var Q = require('q');
var ffs = require('final-fs');

var VFS = (function(){

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

    var encodeLocalPath = function(path) {
        var segments = path.split('/');
        var result = [];
        segments.forEach(function(segment){
            result.push(encodeURIComponent(segment));
        });
        return result.join('/');
    };

    var encodeRemotePath = function(path) {
        var segments = path.split('/');
        var result = [];
        segments.forEach(function(segment){
            result.push(decodeURIComponent(segment));
        });
        return result.join('/');
    };

    function VFS($28, projectEndpoint, projectToken, localProjectPath){
        this.$28 = $28;
        this.projectEndpoint = projectEndpoint;
        this.projectToken = projectToken;
        this.localProjectPath = localProjectPath ? normalizeLocalProjectPath(localProjectPath) : '';
    }

    VFS.prototype.getLocalQuery = function(path){
        return fs.readFileSync(path, 'utf-8');
    };

    VFS.prototype.getLocalQueries = function(){
        var that = this;
        ffs.mkdirRecursiveSync(this.localProjectPath + 'modules', 511);
        ffs.mkdirRecursiveSync(this.localProjectPath + 'public', 511);
        ffs.mkdirRecursiveSync(this.localProjectPath + 'private', 511);
        return Q.all([
            ffs.readdirRecursive(this.localProjectPath + 'modules', true, 'modules'),
            ffs.readdirRecursive(this.localProjectPath + 'public', true,  'public'),
            ffs.readdirRecursive(this.localProjectPath + 'private', true, 'private')
        ]).then(function(lists){
            var queries = {};
            lists.forEach(function(files){
                files.filter(function(file){
                    return file.substring(file.length - 2) === 'jq' || file.substring(file.length - 2) === 'xq';
                }).forEach(function(file){
                    queries[file] = {
                        lastModified: new Date(fs.statSync(that.localProjectPath + file).mtime).toISOString()
                    };
                });
            });
            return queries;
        });
    };

    VFS.prototype.getRemoteQueries = function(){
        return Q.all([
            //Modules need to be listed/uploaded first,
            //so compilation errors on main queries can make sense.
            this.$28.Modules(this.projectEndpoint).listModules({
                includeSystem: false,
                includeNs: false,
                includeSrc: false,
                token: this.projectToken
            }),
            this.$28.Queries(this.projectEndpoint).listQueries({
                visibility: '',
                token: this.projectToken
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
                queries[encodeRemotePath(path)] = {
                    lastModified: modules[module].lastModified
                };
            });
            lists[queryIndex].body.public.concat(
                lists[queryIndex].body.private
            ).forEach(function(query){
                    var path = query.href.substring('/v1/_queries/'.length);
                    queries[encodeRemotePath(path)] = {
                        lastModified: query.lastModified
                    };
                });
            return queries;
        });
    };

    VFS.prototype.deleteRemoteQuery = function(query){
        var promise;
        if(isModule(query)){
            promise = this.$28.Modules(this.projectEndpoint).removeModule({
                modulePath: encodeLocalPath(modulePath(query)),
                token: this.projectToken
            });
        } else {
            promise = this.$28.Queries(this.projectEndpoint).removeQuery({
                queryPath: encodeLocalPath(query),
                token: this.projectToken
            });
        }
        return promise;
    };

    VFS.prototype.deleteLocalQuery = function(query){
        var defered = Q.defer();
        ffs.unlink(this.localProjectPath + query).then(function(){
            defered.resolve();
        }).otherwise(function(error){
            defered.reject(error);
        });
        return defered.promise;
    };

    VFS.prototype.writeRemoteQuery = function(query, reportErrors){
        var that = this;
        var defered = Q.defer();
        ffs.readFile(this.localProjectPath + query, { encoding: 'utf-8' }).then(function(source){
            source = source.toString();
            if(isModule(query)){
                that.$28.Modules(that.projectEndpoint).saveModule({
                    modulePath: encodeLocalPath(modulePath(query)),
                    extension: moduleExtension(query),
                    moduleBody: source,
                    compile: 'none',
                    token: that.projectToken
                })
                    .then(function(result){
                        defered.resolve(reportErrors === true ? result.body.compilationError : undefined);
                    })
                    .catch(function(error){ defered.reject(error); });
            } else {
                that.$28.Queries(that.projectEndpoint).saveQuery({
                    queryPath: encodeLocalPath(query),
                    queryBody: source,
                    compile: 'lax',
                    token: that.projectToken
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

    VFS.prototype.writeLocalQuery = function(query){
        var that = this;
        var callback = function(response){
            var source = response.body;
            var dir = that.localProjectPath + path.dirname(query);
            ffs.mkdirRecursiveSync(dir, 511);
            ffs.writeFileSync(that.localProjectPath + query, source, { encoding: 'utf-8' });
        };

        if(isModule(query)) {
            return this.$28.Modules(this.projectEndpoint)
                .getModule({ modulePath: encodeLocalPath(modulePath(query)), token: this.projectToken })
                .then(callback);
        } else {
            return this.$28.Queries(this.projectEndpoint)
                .getQuery({ queryPath: encodeLocalPath(query), token: this.projectToken })
                .then(callback);
        }
    };

    return VFS;
})();

exports.VFS = VFS;
