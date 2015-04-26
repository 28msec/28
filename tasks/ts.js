'use strict';

var Config = require('./config');
var gulp = require('gulp');
var $ = require('gulp-load-plugins')();
var merge = require('merge2');

var Config = require('./config');

gulp.task('typescript:compile', function() {
    var tsResult = gulp.src(Config.ts)
        .pipe($.typescript({
            declarationFiles: true,
            noExternalResolve: true
        }));

    return merge([
        tsResult.dts.pipe(gulp.dest(Config.dist)),
        tsResult.js.pipe(gulp.dest(Config.dist))
    ]);
});