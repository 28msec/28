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
                    deferred.resolve(JSON.parse(body));
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
                var queries = JSON.parse(body).public;
                var results = [];
                queries.forEach(function(query){
                    results[query.href.substring('/v1/_queries/'.length)] = {
                        lastModified: new Date(query.lastModified).toISOString()
                    };
                });
                deferred.resolve(results);
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
                var queries = JSON.parse(body).private;
                var results = [];
                queries.forEach(function(query){
                    results[query.href.substring('/v1/_queries/'.length)] = {
                        lastModified: new Date(query.lastModified).toISOString()
                    };
                });
                deferred.resolve(results);
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
                    results['lib' + key] = {
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
    
    this.writeFile = function(path, source){
        var deferred = Q.defer();
        var url = (path.indexOf('public') === 0 || path.indexOf('private') === 0) ? '/_queries/' + path + '/metadata/source' : '/_modules/' + path.substring('/lib'.length);
        request({
            method: 'PUT',
            uri: domain + url,
            qs: { token: projectToken },
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
        var url = (path.indexOf('public') === 0 || path.indexOf('private') === 0) ? '/_queries/' + path + '/metadata/source' : '/_modules/' + path.substring('/lib'.length);
        request({
            method: 'DELETE',
            uri: domain + url,
            qs: { token: projectToken }
        }, function(error, response, body){
            if(response.statusCode >= 200 && response.statusCode <= 299) {
                deferred.resolve(body);
            } else {
                deferred.reject(body);  
            }
        });
        return deferred.promise;    
    }
    
    this.getFile = function(path){
        var deferred = Q.defer();
        var url = (path.indexOf('public') === 0 || path.indexOf('private') === 0) ? '/_queries/' + path + '/metadata/source' : '/_modules/' + path.substring('/lib'.length);
        request({
            method: 'GET',
            uri: domain + url,
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
        var deferred = Q.defer();
        var files = [];
        var promises = [];
        var promise;
        
        promise = this.listModules();
        promises.push(promise);
        
        promise = this.listPublicQueries();
        promises.push(promise);
        
        promise = this.listPrivateQueries();
        promises.push(promise);
        
        Q.all(promises)
        .then(function(list){
            deferred.resolve(list);
        });
        
        return deferred.promise;
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