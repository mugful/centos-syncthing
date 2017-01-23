centos-syncthing
================

A Syncthing image built on top of CentOS 7.

Build
-----

    git clone https://github.com/dockingbay/centos-syncthing
    cd centos-syncthing
    docker build --force-rm -t dockingbay/centos-syncthing:latest .

Run - general info and first steps
----------------------------------

The container can either be run with an existing syncthing config, or
it can generate its own config on the first startup. The generated
config is pretty much "locked down" by default -- GUI TLS enforced,
GUI admin account set up, both global and local discovery
disabled. You can tweak these settings after logging into the GUI.

Regardless of how you run the container, make sure that you open
appropriate ports on the host firewall. That's `8384` for GUI, `21027`
for local discovery, and `22000` for data transfers (you may not need
all, depending on how you plan to use syncthing).

If you need to run with local discovery, you should run in
`--net=host` mode to allow discovery UDP broadcasts propagate through
your LAN (i haven't figured out how to make discovery work without
`--net=host`). A quick and dirty test run on your laptop can be done
like this:

    docker run \
        --name syncthing \
        --net=host \
        -e SYNCTHING_UID=1000 \
        -e SYNCTHING_ADMIN_PASSWORD=test \
        dockingbay/centos-syncthing:latest

And then you can navigate to port `8384` and play with syncthing
(enable discovery, add devices etc.). Log in with `admin/test`
credentials. Setting up authentication in a more advanced way is
described further on.

If you want to run syncthing on a remote machine outside your LAN, to
serve as data backup, you most probably don't want local discovery
enabled. In this scenario you can publish GUI and data ports the usual
way:

    docker run \
        --name syncthing \
        -p 8384:8384 \
        -p 22000:22000 \
        -e SYNCTHING_UID=1000 \
        -e SYNCTHING_ADMIN_PASSWORD=test \
        dockingbay/centos-syncthing:latest


Run - volumes and persistence
-----------------------------

Most probably you'll want to mount config and data storage into the
container as volumes, to decouple their existence from the existence
of the container.

Furthermore, when mounting volumes it is necessary to ensure that the
`syncthing` user in the container has the same user ID as the owner of
the files on the host machine. User ID of the `syncthing` user in the
container can be set via `SYNCTHING_UID` environment variable.

To mount config and data directories and ensure matching UIDs, you
could add something like this to your `docker run` command:

    -e SYNCTHING_UID=$(id -u myuser) \
    -v /home/myuser/.config/syncthing:/home/syncthing/.config/syncthing:z \
    -v /home/myuser/my_shared_data:/home/syncthing/sync:z \

Run - config generation options
-------------------------------

When running the container in such a way that file
`/home/syncthing/.config/syncthing/config.xml` doesn't exist yet, the
container will attempt to autogenerate the configuration.

Customize GUI admin user credentials with `SYNCTHING_ADMIN_USER` and
`SYNCTHING_ADMIN_PASSWORD` env variables. In production environments
you'll probably not want to pass the password directly like this on
the command line, so you can set `SYNCTHING_ADMIN_PASSWORD_BCRYPT`
variable instead, which expects already hashed password in bcrypt
format. You can obtain such hash beforehand e.g. like this:

    python -c "import bcrypt; print(bcrypt.hashpw('mypassword', bcrypt.gensalt(log_rounds=10)))"

By default the GUI is only permitted to talk over TLS connections. You
can put your custom TLS key+cert pair for GUI into
`/home/syncthing/.config/syncthing` directory (e.g. via a volume
mount). The file names must be `https-key.pem` and `https-cert.pem`,
respectively.

Allowing non-TLS connections to the GUI is not recommended, but if you
wish to do so anyway, you can do so via env variable assignment
`SYNCTHING_ADMIN_TLS=false`.

The rest of the syncthing settings is currently not customizable via
env variables, you'll need to log into the GUI and change
things. You'll probably want to do this just once and then re-use the
same config directory throughout updates of the syncthing container
image.
