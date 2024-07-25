oisd-install
============

Pull, validate, and install a host list from https://oisd.nl.

Examples
--------

Download the dnsmasq2 big host list to a temp file, validate it, move it into
place, and restart dnsmasq:

```
$ oisd-install -t big -s dnsmasq2 /etc/dnsmasq/oisd-hosts.conf -- svcadm -v restart dnsmasq
> downloading https://big.oisd.nl/dnsmasq2 to /tmp/oisd.54034.eCZA
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 4740k    0 4740k    0     0  3272k      0 --:--:--  0:00:01 --:--:-- 3271k
> validating /tmp/oisd.54034.eCZA with dnsmasq2 syntax... done
> moving /tmp/oisd.54034.eCZA -> /etc/dnsmasq/oisd-hosts.conf... done
> running: svcadm -v restart dnsmasq
Action restart set for svc:/application/dnsmasq:default.
> all done
```

This:

1. Pulled the host list to a temp file with `curl`.
2. Validated the temp file.
3. Atomically moved the file into place.
4. Ran the command given after `--`, in this case restarting the `dnsmasq`
   service.

If we immediately run the script again we get:

```
$ oisd-install -t big -s dnsmasq2 /etc/dnsmasq/oisd-hosts.conf -- svcadm -v restart dnsmasq
> downloading https://big.oisd.nl/dnsmasq2 to /tmp/oisd.54067.MJ5K
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 4740k    0 4740k    0     0  3267k      0 --:--:--  0:00:01 --:--:-- 3267k
> validating /tmp/oisd.54067.MJ5K with dnsmasq2 syntax... done
> no changes detected, exiting
```

This did step 1 and 2 above but stopped because no file changes were detected -
leaving the original file intact.

This script also allows you to set ownership and permissions on the file before
it is moved into place:

```
$ oisd-install -t big -s dnsmasq2 -o root -g wheel -m 644 ./list.conf
...
```


### Notes

1. This script has validators for the various types of host files by
   https://oisd.nl/setup.  See [./test](./test) for examples.
2. The temp file will only be moved into place if it is different than what is
   currently in-place.  This is a conscious decision so a user can look at the
   mtime of the file to see the last time it was updated by this script. I
   personally use this as a nagios check with `check_file_age` to verify the
   file has been touched in the last X days since I run `oisd-install` via
   cron and want to verify the file doesn't get stale.
3. The command given after `--` is optional and will only be run if the host
   list file was pulled, validated, and was successfully moved into place i.e.:
   it was different and updated.
4. This script will attempt to use `curl` to pull the file if it is found,
   falling back to `wget`, or finally just emitting an error and stopping if
   neither are available.

Usage
-----

```
$ oisd-install -h
Pull, validate, and install a host list from https://oisd.nl.

Usage:
     oisd-install -t type -s syntax /path/to/file.conf [-- cmd to run]

Examples:
    Pull the small host list in adblock plus syntax and save it:

        $ oisd-install -t small -s abp /etc/abp/list.conf

    Pull the big host list in unbound syntax and save it:

        $ oisd-install -t big -s unbound /etc/unbound/list.conf

    Pull the same as above but set the given metadata on the file:

        $ oisd-install -t big -s unbound -o root -g wheel -m 644 ./list.conf

    Pull the big host list in dnsmasq2 syntax, save it, and restart the
    dnsmasq service if the file was different:

        $ oisd-install -t big -s dnsmasq2 /var/list.conf -- svc restart dnsmasq

Options:
  -t <type>    The filetype to pull, choices are small, big, or nsfw.
  -s <syntax>  The file syntax to pull, choices are dnsmasq, unbound, rpz, etc.
  -m <mode>    The permissions to set on the file, passed directly to chmod.
  -o <owner>   The owner to set on the file, passed directly to chown.
  -g <group>   The group to set on the file, passed directly to chgrp.
  -h           Print this message and exit.

Arguments:
  arg 1        [Required] The path to install the host list once pulled.
               and validated, for example: /etc/dnsmasq/oisd-host-list.conf.
  extra        Any arguments will be processed as a command to run if
               the pull was successful and the new file is different than
               the previous file. The string -- must preceed the command.

```

Pull Requests
-------------

Any code submitted should pass the syntax check and tests:

    $ make check test
    awk 'length($0) > 80 { exit(1); }' oisd-install
    ./oisd-install -h | awk 'length($0) > 80 { exit(1); }'
    shellcheck oisd-install
    (cd test && make)
    ./check-valid-syntax
    checking abp... valid
    checking dnsmasq... valid
    checking dnsmasq2... valid
    checking domainswild... valid
    checking domainswild2... valid
    checking rpz... valid
    checking simplednsplusdblpi... valid
    checking unbound... valid

Bash style guide: https://github.com/bahamas10/bash-style-guide

License
-------

MIT License
