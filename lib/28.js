var $q = require('q');
var $http = require('request');

var Auth = function(domain) {

    this.auth = function(params){
        var deferred = $q.defer();
        $http({
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

var API = {
    Auth: function(domain){
        return new Auth(domain);
    }
};
module.exports = API;