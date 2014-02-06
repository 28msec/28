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
                'lib/**/*.js'
            ]
        }
    });
    
    grunt.registerTask('default', ['jshint']);
};
