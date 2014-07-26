'use strict';

module.exports = function(grunt) {
  
    require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);
 
    grunt.initConfig({
        jshint: {
            options: {
                jshintrc: '.jshintrc'
            },
            all: [
                'Gruntfile.js',
                'lib/**/*.js',
                'test/**/*.js'
            ]
        },
        vows: {
            all: {
                options: {
                    verbose: true,
                    colors: true,
                    coverage: 'json'
                },
                src: ['tests/*.js']
            }
        },
        jsonlint: {
            all: {
                src: [
                    'package.json'
                ]
            }
        },
        shell: {
            bats: {
                options: {
                },
                command: [
                    'node_modules/bats/libexec/bats tests/sync.bats',
                    'node_modules/bats/libexec/bats tests/login.bats',
                    'node_modules/bats/libexec/bats tests/projects.bats'
                ].join('&&')
            }
        }
    });
    
    grunt.registerTask('default', ['jsonlint', 'jshint', 'vows', 'shell']);
};
