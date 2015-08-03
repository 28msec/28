/// <reference path="../typings/tsd.d.ts" />
import cli = require("commander");

cli
    .command("list [project-name]")
    .description("List Datasources")
    .action(function(projectName){
         console.log(projectName);
    });

if (!cli.args.length) {
    cli.help();
}
