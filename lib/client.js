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
    
    var writeToRemoteFile = function(file){
    
    };
    
    var performAction = function(remoteFile, localFile, overwrite){
        var result = { action: true, remoteFile: remoteFile, localFile: localFile };
        var deferred = Q.defer();
        if(localFile.exists === true && overwrite !== that.OVERWRITE_ALWAYS) {
            if(overwrite === that.OVERWRITE_NEVER) {
                result.action = false;
                deferred.resolve(result);
            } else if(overwrite === that.OVERWRITE_ASK) {
                read(
                    {
                        prompt: 'Overwrite : <local>/' + localFile.path
                            + ' (' + localFile.lastModified + ') with <remote>/' 
                            + remoteFile.path
                            + ' (' + remoteFile.lastModified + ')? Y/[N]',
                        'default': 'N' 
                    }
                    ,
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
                    new Date(remoteFile.lastModified).getTime()
                    >
                    new Date(localFile.lastModified).getTime()
                );
                deferred.resolve(result);
            }
        } else {
            deferred.resolve(result);
        }
        return deferred.promise;
    };
    
    this.download = function(project, remote, local, overwrite, deleteOrphaned, simulate){
        var promises = [];

        Object.keys(remote).forEach(function(file){

            var remoteFile = {
                path: file,
                exists: true,
                lastModified: remote[file].lastModified
            };
            var localFile  = {
                path: file, 
                exists: local[file] !== undefined,
                lastModified: local[file] ? local[file].lastModified : undefined
            };

            promises.push(function() {
                var deferred = Q.defer();
                performAction(remoteFile, localFile, overwrite).then(function(result){
                    if(result.action) {
                        console.log('Download ' + result.remoteFile.path);
                        if(!simulate) {
                            writeToLocalFile(project, result.remoteFile.path)
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
            Object.keys(local).forEach(function(file){
                if(!remote[file]) {
                    promises.push(function(){
                        var deferred = Q.defer();
                        console.log('Delete ' + file);
                        if(!simulate) {
                            deleteLocalFile(file)
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
    }
};

module.exports = new Client();