28.io CLI [![Build Status](https://travis-ci.org/28msec/28.png?branch=master)](https://travis-ci.org/28msec/28) [![NPM version](https://badge.fury.io/js/28.png)](http://badge.fury.io/js/28)
============

Below you'll find tutorials that will teach you how to use 28.io, and reference documentation.

Sign up and create an account at https://28.io.
There are different ways for developing queries using 28.io:

* [JSONiq & 28.io tutorials](http://www.28.io/blog/tags/tutorial)
* [28.io Portal](https://portal.28.io)
* [28.io REST API](http://www.28.io/documentation/latest/api)
* Bindings for 28.io
    * [AngularJS](http://github.com/28msec/28.io-angularjs)
    * [C#](https://github.com/28msec/28.io-csharp)

## Installation

Install Node.js and NPM for your system (Mac, Windows or Linux). And install the command line tool using:

```
$ npm install 28 -g
```
## Usage

### Login

You can now authorize the client using your email and password. Your password is never stored on the system:

```
$ 28 login <your email>
```

### List Projects:

```
$ 28 projects
```
### Download Project

```
$28 download <project name> [-d, --delete-orphaned] [-o, --overwrite <yes, no, ask, if-newer>] [-s, --simulate]
```
Options:

* `-h, --help`              Output usage information.
* `-o, --overwrite <value>`  Overwrite remote files. Value can be yes, no, if-newer, or ask.
* `-s, --simulate`           Simulate for extra safety.
* `-d, --delete-orphaned`    Delete orphaned files.


### Upload Project

```
$28 upload <project name> [-d, --delete-orphaned] [-o, --overwrite <yes, no, ask, if-newer>] [-s, --simulate]
```

Options:

* `-h, --help`               output usage information.
* `-o, --overwrite <value>`  Overwrite remote files. Value can be yes, no, if-newer, or ask.
* `-s, --simulate`           Simulate for extra safety.
* `-d, --delete-orphaned`    Delete orphaned files.

### Truncate Project

```bash
$28 truncate <project name> [-s, --simulate]
```

Options:

* `-h, --help`               output usage information.
* `-s, --simulate`           Simulate for extra safety.

### Code checking

The xqlint commands checks your code for static errors and warning using [xqlint](http://github.com/wcandillon/xqlint).

```bash
$28 xqlint <path> [-s, --style-check <yes, no>]
```

## Synchronizing 

The upload and download commands can be used to synchronize local files with a 28.io project and vice versa.
Assume you started a new project called test on 28.io. You would like to download the project files:
```
$28 download test
```
If you make local changes to this project, you can upload them back to your 28.io project.
In order to make sure that everything is in order, you can use the *simulate* option that will display the actions to perform without doing them.
```
$28 upload test --overwrite if-newer --delete-orphaned --simulate
```
Once you are ready, you can run the same command without the *simulate* option.
You can use the *download* command to periodically get updates from your 28.io project:
```
$28 download test --overwrite if-newer --delete-orphaned
```

## Settings

By default, a setting file named *.28.json* is created in your home directory.
You can override these default settings by creating your own *.28.json* file in the current working directory.
This is how the default settings looks like:

```json
{
    "access_token": "",
    "refresh_token": "",
    "project_tokens": {},
    "email": "",
    "protocol": "https",
    "project_name": "portal",
    "project_domain": "28.io",
    "ignore": [
        "lib/io/28/api/.*"
    ]
}
```
* *access_token*, *refresh_token*, *project_tokens*, and *email* properties can be filled using the ``28 login`` command.
* *protocol* property can be *http* or *https*.
* *project_name* property is the name of the prefix of the 28.io API endpoint.
* *project_domain* property is the suffix of the 28.io API endpoint.
* *ignore* property contains a list of regular expressions that will filter out files from being uploaded and downloaded.

## ChangeLog

Version 0.2.4

* Add file extension for modules. (.jq, .xq, or .module)

Version 0.2.3

* Add new xqlint command

Version 0.2.2

* Update to 28.io version 3.1

Version 0.2.1

* New truncate command.
* Execute request asynchronously if an automatic overwrite option is set.

Version 0.2.0

* Bug fix for Windows clients.
* Improvements in the CLI error handling.

Version 0.1.9

* Bug fixes: [#1](https://github.com/28msec/28/issues/1), [#2](https://github.com/28msec/28/issues/2), [#3](https://github.com/28msec/28/issues/3).
