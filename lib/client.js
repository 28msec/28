//'use strict';

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
    
    this.download = function(project, remote, local, overwrite, deleteOrphaned, simulate){
        var promises = [];
        Object.keys(remote).forEach(function(file){
            //Check if local file exists
            //If local[file] is a directory, let the system error be thrown
            var performAction = true;
            if(local[file]) {
                if(overwrite === that.OVERWRITE_ALWAYS) {
                    performAction = true;
                } else if(overwrite === that.OVERWRITE_NEVER) {
                    performAction = false;
                } else if(overwrite === that.OVERWRITE_ASK) {
                    read({
                        prompt: 'Overwrite : <local>/' + file + '(' + local[file].lastModified + ') with <remote>/' + file + '(' + local[file].lastModified + ')? Y/[N]',
                        'default': 'N' 
                    }
                    ,
                    function(er, value) {
                        performAction = value === 'Y';    
                    });
                } else if(overwrite === that.OVERWRITE_IF_NEWER){
                    performAction = new Date(remote[file].lastModified).getTime() < new Date(local[file].lastModified).getTime();
                }
            }

            if(performAction) {
                console.log('Download ' + file);
                if(!simulate) {
                    var deferred = Q.defer();
                    project.getFile(file).then(function(source){
                        var dir = p.dirname(file);
                        ffs.mkdirRecursiveSync(dir, 0777);
                        fs.writeFileSync(file, source, 'UTF-8', {'flags': 'w'});
                        deferred.resolve();
                    })
                    .catch(function(error){
                        deferred.reject(error);
                    });
                    promises.push(deferred.promise);
                }
            }
            
        });
        if(deleteOrphaned) {
            local.forEach(function(file){
                //Check if remote file exists
                //If not, delete
            });
        }
        return Q.all(promises);
    }
};

module.exports = new Client();