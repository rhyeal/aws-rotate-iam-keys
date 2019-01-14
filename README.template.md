# aws-rotate-iam-keys

Rotate your IAM Keys to be in compliance with security best practices. AWS talks
about rotating your keys every 30, 45, or 90 days. But who has the time to make
their own script and remember to do that? I did. And security is easier when its
less than 3 lines that you need to copy + paste to be secure. Now it's easy to
rotate your IAM credentials nightly and wake up with more security than the day
before.

## Installation

AWS Rotate IAM Keys is supported by all major platforms.

### Ubuntu

```
sudo add-apt-repository ppa:rhyeal/aws-rotate-iam-keys
sudo apt-get update
sudo apt-get install aws-rotate-iam-keys
```

### MacOS

```
brew tap rhyeal/aws-rotate-iam-keys https://github.com/rhyeal/aws-rotate-iam-keys
brew install aws-rotate-iam-keys
```
Requires [Homebrew](https://brew.sh/) to install. I am hoping to be included in Homebrew Core soon!

***IMPORTANT:*** You must install your own cron job for automated key rotation.
[Instructions here](#macos-1) or scroll down to `Additional Cron Instructions` below.

### Other Linux

```
wget -q https://github.com/rhyeal/aws-rotate-iam-keys/blob/master/aws-rotate-iam-keys_${VERSION}.deb -o aws-rotate-iam-keys.deb
sudo dpkg -i aws-rotate-iam-keys.deb
sudo apt-get install -f
rm aws-rotate-iam-keys.deb # optional file clean up
```

### Windows

[Click here](https://aws-rotate-iam-keys.com/aws-rotate-iam-keys.ps1) to
download the executable PowerShell script.

Simply place this in any directory and then run it. It will install the
Scheduled Task to rotate your keys nightly upon first run and will rotate your
keys on each run thereafter.

## Features

AWS Rotate IAM Keys is simple and powerful. There aren't too many features other
than rotating keys for a single profile or multiple profiles. The power comes
from multiple cron jobs daily that can rotate multiple sets of keys
automatically.

## Caveats

Currently, AWS Rotate IAM Keys will only work with a single computer. Rotating
keys on a desktop and a laptop for the same IAM user will lead to invalid keys.

AWS Rotate IAM Keys takes an opinionated view that you should only have 1 active
key at a time. It might not work with IAM users that have 2 keys active at a
time.

## Usage

#### To rotate your default profile manually:

```
$ aws-rotate-iam-keys
Making new access key
Updating profile: default
Made new key AKIAIOSFODNN7EXAMPLE
Key rotated
```

#### To rotate a specific profile in your `~/.aws/credentials` file:

```
$ aws-rotate-iam-keys --profile myProfile
$ aws-rotate-iam-keys -p myProfile
```

#### To rotate multiple profiles *with the same key*:

```
$ aws-rotate-iam-keys --profiles myProfile,myOtherProfile
```

The result of the above script is that both `myProfile` and `myOtherProfile`
will have the **same access and secret keys** in your `~/.aws/credentials` file.

#### To rotate multiple profiles *with their own keys*:

```
$ aws-rotate-iam-keys --profile myProfile
$ aws-rotate-iam-keys --profile myOtherProfile
```

The result of the above script is that `myProfile` and `myOtherProfile` will
have **different** access and secret keys in your `~/.aws/credentials` file.

## Configuration

For some operating systems, you need to install your own cron schedule. This is
due to the fact that some operating systems do not allow installed programs
via the package managers selected to create their own cron schedules.

### MacOS

[Launchd](http://www.launchd.info/) is the MacOS replacement for cron. Unlike
cron, which on MacOS skips job invocations when the computer is asleep, launchd
will start the job the next time the computer wakes up.

The Homebrew package installs a launchd job which can be used to automatically
rotate your IAM keys daily. Unfortunately, Homebrew packages cannot
automatically start launchd jobs, so you must manually enable it:

```
brew services start aws-rotate-iam-keys
```

A default/global configuration file for the launchd job is installed to:

```
/usr/local/etc/aws-rotate-iam-keys
```

This default configuration rotates keys for your default AWS profile only.
To customise the configuration, for example to rotate multiple keys, create a
copy of this file named `.aws-rotate-iam-keys` in your home directory and edit
it, e.g.

```
cp /usr/local/etc/aws-rotate-iam-keys ~/.aws-rotate-iam-keys
nano ~/.aws-rotate-iam-keys
```

The `aws-rotate-iam-keys` command is invoked once daily for each line in the
configuration. Each line contains a single set of command line options. If you
need to invoke the command multiple times to rotate your keys, you must add
multiple lines to the configuration, e.g.

```
--profiles default,myProfile
--profile myOtherProfile
```

If you do customise the configuration, you can test that it works by restarting
the service:

```
brew services restart aws-rotate-iam-keys
```

That's it. Your keys should have been rotated, and will now be rotated every
day for you. You can confirm everything has worked by checking your IAM
credentials to see if the access keys have been rotated as expected. If it
hasn't worked, check the MacOS system log for error entries matching
`aws-rotate-iam-keys`.

### Windows

AWS Rotate IAM Keys is set up to automatically schedule a task for you upon
first run. If you want to edit the profiles that are being updated, you need to
modify the task using [Task
Scheduler](https://docs.microsoft.com/en-us/windows/desktop/taskschd/task-scheduler-start-page).
Look for a task named "AWS Rotate IAM Keys" and modify the `-profile` parameter
from `default` to a comma-separated list of your profile names.

If you move the .ps1 script from the initial location where you first ran it,
you will need to modify the path in the task to point to the correct script
location.

## On the Web!

Visit us on the web at
[aws-rotate-iam-keys.com](https://aws-rotate-iam-keys.com) for full installation
instructions in a snazzy single-page UI. It's basically this README with some
colors.

## Checksums

### Linux

```
echo ${LINUX_MD5} aws-rotate-iam-keys.${VERSION}.deb | md5sum --check -
```

### MacOS

Homebrew gets the release zip of the entire repo: `SHA256 2bbc39e9783907451d8ce1eaba93dc6775ad6797221122ec96ec671f23f6344f`

### Windows

PowerShell script file: `MD5 ${WIN_MD5}`
