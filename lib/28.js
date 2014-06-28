'use strict';

exports.$28 = function(apiEndpoint) {
    var Q = require('Q');
    var $28 = require('28.io-nodejs').$28(apiEndpoint);

    this.login = function(email, password){
        return $28.Auth.authenticate({
            email: email,
            password: password,
            grant_type: 'client_credentials'
        });
    };
    
    this.refreshTokens = function(email, token){
        return $28.Auth.authenticate({
            email: email,
            refresh_token: token,
            grant_type: 'refresh_token'
        });
    };
};