'use strict';

var config = {
    dist: 'dist',
    js: ['**/*.js', '!node_modules/**/*.js', '!dist/**/*.js'],
    json: ['**/*.json', '!node_modules/**/*.json'],
    ts: ['bin/**/*.ts']
    //ts: ['**/*.ts', '!node_modules/*/*.ts', '!typings/*/*.ts']
};

module.exports = config;