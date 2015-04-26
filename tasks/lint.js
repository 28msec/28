'use strict';

var gulp = require('gulp');
var $ = require('gulp-load-plugins')();
var map = require('map-stream');
var stylish = require('jshint-stylish');

var Config = require('./config');

gulp.task('lint:jslint', function(){
    return gulp.src(Config.js)
        .pipe($.jshint())
        .pipe($.jshint.reporter())
        .pipe($.jshint.reporter(stylish))
        .pipe($.jshint.reporter('fail'));
});

gulp.task('lint:jsonlint', function(){
    return gulp.src(Config.json)
        .pipe($.jsonlint())
        .pipe($.jsonlint.reporter())
        .pipe(map(function(file, cb) {
            if (!file.jsonlint.success) {
                process.exit(1);
            }
            cb(null, file);
        }));
});

gulp.task('lint:tslint', function(){
    return gulp.src(Config.ts)
        .pipe($.tslint(require('../tslint.json')))
        .pipe($.tslint.report('verbose'));
});

gulp.task('lint', ['lint:tslint', 'lint:jslint', 'lint:jsonlint']);