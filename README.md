
If you're a developer wanting to build your own cyber-dojo server from source [start here](https://github.com/cyber-dojo/cyber-dojo/tree/master/dev).

# cyberdojo/collector docker image

A stand-alone cron micro-service for [cyber-dojo](http://cyber-dojo.org).
Every hour it garbage-collects docker volumes created by
[cyberdojo/runner](https://github.com/cyber-dojo/runner)
which have not been used for 24 hours.
