# seafile-docker
A repo for building a personal sqlite3-backed Seafile instance

## Configuration
You'll want to change the environment variables under the "Options" section of the Dockerfile:

```
# Options
ENV SEAFILE_SERVER_NAME MySeafile
ENV SEAFILE_URI localhost
ENV SEAFILE_DATA_DIR /seafile/seafile-data
ENV SEAHUB_ADMIN_EMAIL foo@bar.com
ENV SEAHUB_ADMIN_PASS baz
```

## Installation
Build your image:

```
docker build -t foo/seafile
```

Run as a daemon:

```
docker run -p 8000:8000 -p 8082:8082 -p 10001:10001 -p 12001:12001 -d foo/seafile
```

## Logging
Seafile's startup scripts don't provide any logging, so to both keep the container
running as a daemon and provide a barebones look into if the Seafile processes are
actually running, I provided some basic output to the container's stdout.

```
Starting seafile server, please wait ...
Seafile server started

Done.

Starting seahub at port 8000 ...

Seahub is started

Done.

Running Seafile processes:
  PID COMMAND
   28 seafile-control
   30 ccnet-server
   32 seaf-server
  104 python2.7
  107 python2.7
  108 python2.7
  109 python2.7
```

That will be the extent of it unless the script detects a change in the running process
list. In that case, it will alert that a change was detected, and will show the
"Running Seafile processes" again.

## Development

If you want to know why I built this the way I did, and why I didn't just go with any of
the existing Seafile images up on Docker Hub, you can read about it here:

- http://conpat.io/dockerizing-seafile
