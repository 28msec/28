#28.io CLI

[![Build Status](http://img.shields.io/travis/28msec/28/master.svg?style=flat)](https://travis-ci.org/28msec/28) [![NPM version](http://img.shields.io/npm/v/28.svg?style=flat)](http://badge.fury.io/js/28) [![Code Climate](http://img.shields.io/codeclimate/github/28msec/28.svg?style=flat)](https://codeclimate.com/github/28msec/28)

Sign up and create an account at http://hq.28.io/account/register.
A video tutorial that shows the 28 cli in action is available [here](https://youtu.be/NILlys4h7Fs?t=53s).
Getting started instructions are also available [here](https://github.com/28msec/28/blob/master/getting-started.md).

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

### Projects:

```
$ 28 projects list
```

```
$ 28 projects create <project name>
```

```
$ 28 project delete <project name>
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


### Watch Project

```bash
$28 watch <project name>
```

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

# Using the CLI on premise

In order to use the 28 CLI against an 28msec instance installed on premise, simply run the following command where `/path/to/cellstore/docker-config.json` is the path of the cellstore configuration file: 

```bash
$28 init </path/to/cellstore/docker-config.json>
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


### Configure auto-complete

Auto-complete is supported for Mac and Linux.
You need bash-completion installed.
####Mac OS X
On OS X you can run `brew install bash-completion` if you have homebrew installed.
Add bash-completion to your `.bash_profile`:

```bash
if [ -f `brew --prefix`/etc/bash_completion ]; then
    . `brew --prefix`/etc/bash_completion
fi
```

####Linux
On Ubuntu you can run `apt-get install bash-completion`.

To enable it in zsh, run:

```bash
echo '. <(28 --completion)' >> .zshrc
```

To enable it in bash, run:

```bash
28 --completion >> ~/28.completion.sh
echo 'source ~/28.completion.sh' >> ~/.bash_profile
```

