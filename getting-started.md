#Getting Started

A video tutorial is available [here](https://youtu.be/NILlys4h7Fs?t=53s).

To get started, create an account at http://hq.28.io/account/register.
The first step is to login:
```bash
$28 login jason@28.io
```

## Project Management

Once you are logged in, you can list and create projects:
```bash
$28 projects create my-project
my-project create.
$28 projects list
* my-project
```

The next step typically would be to attach datasources to your project.
While datasources can be configured on http://hq.28.io, they can also be configured using 28.
Here's an example of data source configuration file:
```json
[{
    "category": "MongoDB",
    "name": "qa",
    "default": false,
    "credentials": {
        "conn-string": "dogen.mongohq.com:10025",
        "db": "qa",
        "user": "demo",
        "pass": "xxxxxxx"
    }
}, {
    "category": "JDBC",
    "name": "users",
    "default": false,
    "credentials": {
        "url": "jdbc:postgresql://aws-us-east-1-portal.1.dblayer.com:10639/compose?sslmode=require",
        "db": "compose",
        "user": "admin",
        "password": "xxxx"
    }
}]
```

To attach the configuration to your project:
```bash
$28 datasources set my-project -c config.json
```

##Query Editing
To edit JSONiq and XQuery files we recommend to use the [Atom JSONiq package](https://atom.io/packages/language-jsoniq).
The `28 watch` command will deploy the local queries to 28.io and listen for changes in the local queries. If a query changes, it gets deployed automatically.


```bash
$ 28 watch my-project
>> ↗ modules/io/28/modules/collections.jq
>> ↗ private/import.jq
>> ↗ public/average_reputation.jq
>> ↗ public/top_contributors.jq
>> ↗ public/contribution_streak.jq
>> ↗ private/test.jq
>> ↗ private/import2.jq
>> ↗ private/test2.jq
Watching /home/wcandillon/projects/demo/queries...
```

To run a query use `28 run`. It also supports `fn:trace()`:
```bash
$28 run myproject public/average_reputation.jq
```
