syslogservice [![Build Status](https://api.travis-ci.org/Extrawurst/syslogservice.svg)](https://travis-ci.org/Extrawurst/syslogservice) [![version](https://img.shields.io/dub/v/syslogservice.svg)](https://code.dlang.org/packages/syslogservice) [![downloads](https://img.shields.io/dub/dt/syslogservice.svg)](https://code.dlang.org/packages/syslogservice)
=============

This is a webservice that gathers arbitrary requests in syslog format on disk (we use this primarily to feed splunk)

usage as application
=============

this is a dub compatible package.
run it with default settings like this:

```
dub --config="application"
```

which prints:
```
Running .\syslogservice.exe
Listening for HTTP requests on 0.0.0.0:8888
hostname: hostUnknown
quiet: true
logfolder: './'
logfilesuffix: ''
logFilesSplitByHour: false
```

now the service listens on port 8888 for stuff to write to log.
test it using curl:
```
curl --data "param1=value1&param2=value2" http://localhost:8888/event
curl --data "param1=value1&param2=value2" http://localhost:8888/foo/bar
```

which leads to a log line like this:
```
Mar 05 15:30:40 hostUnknown - event [param1="value1" param2="value2" ]
Mar 05 15:30:40 hostUnknown foo - bar [param1="value1" param2="value2" ]
```

cmd line
-------------

```
--folder=<value> 		log folder (default './'
--hostport=<value>		port (default '8888')
--hostname=<value>		hostname (default 'hostUnknown'
--quiet          		disable logging of each request to stdout (default 'true')
--filePerHour    		split log files per hour (default is split per day)
--file-suffix=<value>	added to every log filename (default is '')
```

usage as lib
=============

add the dependancy:
```
{
	...
	"dependencies": {
		"syslogservice": "~master"
	}
}
```

server
-------------

to host a syslogservice simply use this:
```
import syslog.service;

shared static this()
{
	auto logger = new SysLogService();
	logger.port = 8888;
	logger.start();
}
```

client
-------------

more importantly this is how you can write to such a service from you code:
```
import syslog.serviceclient;

SyslogServiceClient logger = new SyslogServiceClient("http://localhost:8888/");

logger.log!"event1"();
logger.log!"event2"(["param2":"value"]);
// or using the auto converter template:
logger.log!"event3"(
	"param2","someString",
	"param3",42,
	"param4",true);
```
