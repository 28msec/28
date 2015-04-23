'use strict';

var fs = require('fs');
var URL = require('url');
var cli = require('commander');
var _ = require('lodash');
var Download = require('download');
var path = require('path');

var toPath = function(ns) {
    var url = URL.parse(ns);
    var segments = url.hostname.split('.').reverse();
    segments = segments.concat(url.path.split('/').slice(1));
    return segments.join('/') + '.jq';
};

//Install command
cli
.command('install')
.description('This command installs a JSONiq package, and any packages that it depends on..')
.action(function() {
    var manifest = JSON.parse(fs.readFileSync('28.json', 'utf-8'));
    var root = path.dirname(path.resolve('28.json')) + '/';
    _.forEach(manifest.dependencies, function(url, name){
        url = URL.parse(url);
        url.hash = url.hash.substring(1);
        url.path = _.endsWith(url.path, '.git') ? url.path.substring(0, url.path.length - 4) : url.path;
        var href = _.template('<%= protocol %>//<%= hostname %><%= path %>/archive/<%= hash %>.zip')(url);

        console.log('Installing ' + name + '...');
        var output = root + 'jsoniq_modules/';
        var base = output + name + '-' + url.hash;
        new Download({ mode: '755', extract: true })
            .get(href)
            .dest(output)
            .run(function(){
                var manifest = JSON.parse(fs.readFileSync(base + '/28.json', 'utf-8'));
                manifest.exports.forEach(function(ns){
                    var path = toPath(ns);
                    console.log(path);
                    fs.createReadStream(base + '/queries/modules/' + path)
                        .pipe(fs.createWriteStream('queries/modules/' + path));
                });
            });
    });
});