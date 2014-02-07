28.io CLI Tool: Getting Started
============

Below you'll find tutorials that will teach you how to use 28.io, and reference documentation.

Sign up and create an account at https://28.io.
There are different ways for developing queries using 28.io:

* JSONiq & 28.io tutorials: http://www.28.io/blog/tags/tutorial
* Using the 28.io portal at https://portal.28.io
* Using the REST API: http://www.28.io/documentation/latest/api
* Using the C# Language binding (more to come): https://github.com/28msec/28.io-csharp

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
* *ignore* property contains a list of regular expressions that will filter out files from being uploaded and downloaded
