'use strict';

var gulp = require('gulp');
var Config = require('./tasks/config');

require('./tasks/lint');
require('./tasks/ts');

gulp.task('watch', function(){
    gulp.watch(Config.js, ['lint:jslint']);
    gulp.watch(Config.json, ['lint:jsonlint']);
    gulp.watch(Config.ts, ['lint:tslint', 'typescript:compile']);
});