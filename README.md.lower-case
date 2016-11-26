
# cyberdojo/collector docker image

Will be a micro-service for [cyber-dojo](http://cyber-dojo.org)
that garbage-collects docker volumes created by the
[cyberdojo/runner](https://github.com/cyber-dojo/runner) docker image
which have not been used for N days.

- - - -

The service will use some kind of cron to regularly repeat the collection sweep.
https://getcarina.com/docs/tutorials/schedule-tasks-cron/

- - - -

To list all volumes
```
$ docker volume ls --quiet --filter 'name=cyber_dojo_'
```
The pattern must not match the name of the katas-data-volume which is cyber-dojo-katas-DATA-CONTAINER.

- - - -

To check a volume, eg cyber_dojo_E58A625FB0_shark
```
$ docker run --rm -it -v cyber_dojo_E58A625FB0_shark:/sandbox cyberdojo/ruby sh -c "find /sandbox/** -mtime -7"
```
which will print the names of files changed in the last 7 days to stdout.
If nothing is printed, then the volume is collected using [docker volume rm cyber_dojo_E58A625FB0_shark]

- - - -

To test set the mtime using touch, eg to 2016 Nov 12th 13:14
```
$ docker run --rm -it -v cyber_dojo_E58A625FB0_shark:/sandbox cyberdojo/ruby sh -c "touch -d 201611121314 /sandbox/*"
```