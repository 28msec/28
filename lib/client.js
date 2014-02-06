'use strict';

var Q = require('q');
var read = require('read');
var fs  = require('fs');
var p = require('path');
var ffs = require('final-fs');

var Client = function() {
    
    this.OVERWRITE_ALWAYS   = 0;
    this.OVERWRITE_NEVER    = 1;
    this.OVERWRITE_ASK      = 2;
    this.OVERWRITE_IF_NEWER = 3;

    var that = this;
    
    var deleteLocalFile = function(file){
        var deferred = Q.defer();
        fs.unlink(file, function (err) {
            if (err) {
                deferred.reject(err);
            } else {
                deferred.resolve();
            }
        });
        return deferred.promise;
    };
    
    var deleteRemoteFile = function(project, file) {
        return project.removeFile(file);
    };
    
    var writeToLocalFile = function(project, file){
        var deferred = Q.defer();
        project.getFile(file).then(function(source){
            var dir = p.dirname(file);
            ffs.mkdirRecursiveSync(dir, 511);
            fs.writeFileSync(file, source, 'UTF-8', {'flags': 'w'});
            deferred.resolve();
        })
        .catch(function(error){
            deferred.reject(error);
        });
        return deferred.promise;
    };
    
    var writeToRemoteFile = function(project, file){
        var source = fs.readFileSync(file, 'UTF-8');
        return project.writeFile(file, source);
    };
    
    var performAction = function(fromFile, toFile, overwrite){
        var result = { action: true, fromFile: fromFile, toFile: toFile };
        var deferred = Q.defer();
        if(toFile.exists === true && overwrite !== that.OVERWRITE_ALWAYS) {
            if(overwrite === that.OVERWRITE_NEVER) {
                result.action = false;
                deferred.resolve(result);
            } else if(overwrite === that.OVERWRITE_ASK) {
                read(
                    {
                        prompt: 'Overwrite : <' + toFile.origin + '>/' + toFile.path +
                            ' (' + toFile.lastModified + ') with <' + fromFile.path + '>/' +
                            fromFile.path +
                            ' (' + fromFile.lastModified + ')? Y/[N]',
                        'default': 'N'
                    },
                    function(er, value) {
                        if(er) {
                            deferred.reject(er);
                        }
                        result.action = (value.toUpperCase() === 'Y');
                        deferred.resolve(result);
                    }
                );
            } else if(overwrite === that.OVERWRITE_IF_NEWER){
                result.action = (
                    new Date(fromFile.lastModified).getTime() >
                    new Date(toFile.lastModified).getTime()
                );
                deferred.resolve(result);
            }
        } else {
            deferred.resolve(result);
        }
        return deferred.promise;
    };
    
    var sync = function(project, from, to, overwrite, deleteOrphaned, simulate, fromOrigin, toOrigin){
        var promises = [];

        Object.keys(from).forEach(function(file){

            var fromFile = {
                path: file,
                exists: true,
                lastModified: from[file].lastModified,
                origin: fromOrigin
            };

            var toFile  = {
                path: file,
                exists: to[file] !== undefined,
                lastModified: to[file] ? to[file].lastModified : undefined,
                origin: toOrigin
            };

            promises.push(function() {
                var deferred = Q.defer();
                performAction(fromFile, toFile, overwrite).then(function(result){
                    if(result.action) {
                        console.log((fromOrigin === 'remote' ? 'Download ' : 'Upload ') + result.fromFile.path);
                        if(!simulate) {
                            (
                                fromOrigin === 'remote' ?
                                writeToLocalFile(project, result.fromFile.path) :
                                writeToRemoteFile(project, result.fromFile.path)
                            )
                            .then(function(){
                                deferred.resolve();
                            })
                            .catch(function(error){
                                deferred.reject(error);
                            });
                        }
                    } else {
                        deferred.resolve();
                    }
                })
                .catch(function(error){
                    console.error(error);
                });
                return deferred.promise;
            });
        });
        
        if(deleteOrphaned) {
            Object.keys(to).forEach(function(file){
                if(!from[file]) {
                    promises.push(function(){
                        var deferred = Q.defer();
                        console.log('Delete ' + '<' + toOrigin + '>/' + file);
                        if(!simulate) {
                            (
                                fromOrigin === 'remote' ?
                                deleteLocalFile(file) :
                                deleteRemoteFile(project, file)
                            )
                            .then(function(){
                                deferred.resolve();
                            })
                            .catch(function(error){
                                deferred.reject(error);
                            });
                        } else {
                            deferred.resolve();
                        }
                        return deferred.promise;
                    });
                }
            });
        }
        
        return promises.reduce(Q.when, Q());
    };

    this.upload = function(project, remote, local, overwrite, deleteOrphaned, simulate){
        return sync(project, local, remote, overwrite, deleteOrphaned, simulate, 'local', 'remote');
    };

    this.download = function(project, remote, local, overwrite, deleteOrphaned, simulate){
        return sync(project, remote, local, overwrite, deleteOrphaned, simulate, 'remote', 'local');
    };
};

module.exports = new Client();