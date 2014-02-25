'use strict';

var Q = require('q');
var request = require('request');

var Auth = function(domain) {
    this.auth = function(params){
        var deferred = Q.defer();
        request({
            method: 'POST',
            uri: domain + '/auth',
            qs: params
        }, function (error, response, body) {
            if(error) {
                deferred.reject(error);
            } else {
                if(response.statusCode >= 200 && response.statusCode <= 299) {
                    try {
                        deferred.resolve(JSON.parse(body));
                    } catch (error) {
                        deferred.reject(body);
                    }
                } else {
                    deferred.reject(body);
                }
            }
        });
        return deferred.promise;
    };
};

var Project = function(domain, projectToken) {
    
    this.listPublicQueries = function(){
        var deferred = Q.defer();
        request({
            method: 'GET',
            uri: domain + '/_queries/public',
            qs: { token: projectToken }
        }, function(error, response, body){
            if(response.statusCode >= 200 && response.statusCode <= 299) {
                try {
                    var queries = JSON.parse(body).public;
                    var results = [];
                    queries.forEach(function(query){
                        results[query.href.substring('/v1/_queries/'.length)] = {
                            lastModified: new Date(query.lastModified).toISOString()
                        };
                    });
                    deferred.resolve(results);
                } catch(error) {
                    deferred.reject(body);
                }
            } else {
                deferred.reject(body);
            }
        });
        return deferred.promise;
    };
    
    this.listPrivateQueries = function(){
        var deferred = Q.defer();
        request({
            method: 'GET',
            uri: domain + '/_queries/private',
            qs: { token: projectToken }
        }, function(error, response, body){
            if(response.statusCode >= 200 && response.statusCode <= 299) {
                try {
                    var queries = JSON.parse(body).private;
                    var results = [];
                    queries.forEach(function(query){
                        results[query.href.substring('/v1/_queries/'.length)] = {
                            lastModified: new Date(query.lastModified).toISOString()
                        };
                    });
                    deferred.resolve(results);
                } catch(error) {
                    deferred.reject(body);
                }
            } else {
                deferred.reject(body);
            }
        });
        return deferred.promise;
    };

    this.listModules = function(){
        var deferred = Q.defer();
        request({
            method: 'GET',
            uri: domain + '/_modules',
            qs: { token: projectToken }
        }, function(error, response, body){
            if(response.statusCode >= 200 && response.statusCode <= 299) {
                var modules = JSON.parse(body);
                var results = [];
                var keys = Object.keys(modules);
                keys.forEach(function(key){
                    results['modules' + key + '.' + modules[key].ext] = {
                        lastModified: new Date(modules[key].lastModified).toISOString()
                    };
                });
                deferred.resolve(results);
            } else {
                deferred.reject(body);
            }
        });
        return deferred.promise;
    };
    
    var getURL = function(path){
        var result = {
                            
        };
        if(path.indexOf('public') === 0 || path.indexOf('private') === 0) {
            result.href = '/_queries/' + path + '/metadata/source';
        } else if(path.indexOf('modules') === 0) {
            var idx = path.lastIndexOf('.');
            var href = path.substring(0, idx);
            var extension = path.substring(idx + 1);
            result.href = '/_' + href;
            result.extension = extension;
            console.log(result);
        } else {
            console.error('Unknown entity: ' + path);
        }
        return result;
    };
                            
    this.writeFile = function(path, source){
        var deferred = Q.defer();
        var url = getURL(path);
        request({
            method: 'PUT',
            uri: domain + url.href,
            qs: { token: projectToken, ext: url.extension },
            headers: {
                'Content-Type': 'text/plain; utf-8'
            },
            body: source
        }, function(error, response, body){
            if(response.statusCode >= 200 && response.statusCode <= 299) {
                deferred.resolve(body);
            } else {
                deferred.reject(body);
            }
        });
        return deferred.promise;
    };

    this.removeFile = function(path){
        var deferred = Q.defer();
        var url = getURL(path);
        request({
            method: 'DELETE',
            uri: domain + url.href,
            qs: { token: projectToken }
        }, function(error, response, body){
            if(response.statusCode >= 200 && response.statusCode <= 299) {
                deferred.resolve(body);
            } else {
                deferred.reject(body);
            }
        });
        return deferred.promise;
    };
    
    this.getFile = function(path){
        var deferred = Q.defer();
        var url = getURL(path);
        request({
            method: 'GET',
            uri: domain + url.href,
            qs: { token: projectToken }
        }, function(error, response, body){
            if(response.statusCode >= 200 && response.statusCode <= 299) {
                deferred.resolve(body);
            } else {
                deferred.reject(body);
            }
        });
        return deferred.promise;
    };
    
    this.listFiles = function(){
        var promises = [];
        var promise;
        
        promise = this.listModules();
        promises.push(promise);
        
        promise = this.listPublicQueries();
        promises.push(promise);
        
        promise = this.listPrivateQueries();
        promises.push(promise);
        
        return Q.all(promises);
    };
};

var API = {
    Auth: function(domain){
        return new Auth(domain);
    },
    Project: function(domain, token) {
        return new Project(domain, token);
    }
};

module.exports = API;
