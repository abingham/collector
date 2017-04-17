
<img width="707" alt="cyber-dojo-screen-shot" src="https://cloud.githubusercontent.com/assets/252118/25101292/9bdca322-23ab-11e7-9acb-0aa5f9c5e005.png">

* [Take me to cyber-dojo's home github repo](https://github.com/cyber-dojo/cyber-dojo).
* [Take me to http://cyber-dojo.org](http://cyber-dojo.org).

- - - -

# cyberdojo/collector docker image

A stand-alone cron micro-service for [cyber-dojo](http://cyber-dojo.org).
Every hour it garbage-collects docker volumes created by
[cyberdojo/runner](https://github.com/cyber-dojo/runner)
which have not been used for 24 hours.
