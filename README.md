
[Take me to the cyber-dojo home page](https://github.com/cyber-dojo/cyber-dojo).

- - - -

# cyberdojo/collector docker image

A stand-alone cron micro-service for [cyber-dojo](http://cyber-dojo.org).
Every hour it garbage-collects docker volumes created by
[cyberdojo/runner](https://github.com/cyber-dojo/runner)
which have not been used for 24 hours.
