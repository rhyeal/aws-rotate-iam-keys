# aws-rotate-iam-keys

Rotate your IAM Keys to be in compliance with security best practices. AWS talks
about rotating your keys every 30, 45, or 90 days. But who has the time to make
their own script and remember to do that? I did. And security is easier when its
less than 3 lines that you need to copy + paste to be secure. Now it's easy to
rotate your IAM credentials nightly and wake up with more security than the day
before.

## Features

AWS Rotate IAM Keys is simple and powerful. There aren't too many features other
than rotating keys for a single profile or multiple profiles. The power comes
from scheduling daily jobs to rotate your access keys automatically.

## Caveats

AWS Rotate IAM Keys is designed to work with a single computer. Rotating keys
on a desktop and a laptop for the same IAM user will lead to invalid keys. To
use AWS Rotate IAM Keys with multiple computers you will need to find a way to
synchronize your aws credentials across multiple computers. We've had success
synchonzing credentials across multiple computers using both
[SpiderOak](https://spideroak.com) and [Sync.com](https://sync.com), but YMMV.

AWS Rotate IAM Keys also assumes you only have 1 access key at a time. This is
normal practice for IAM users. The maximum number of keys is 2, and you need to
be able to create a new key when rotating your access keys.

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

Note: this automatically installs/upgrades the `awscli` Homebrew package and its
dependent packages. You can skip this using `brew install aws-rotate-iam-keys --without-awscli`.

***IMPORTANT:*** You must enable the Homebrew service for automated key
rotation. See [Configuration](#configuration).

### Debian

Download the latest `.deb` package and install it, e.g.

```
wget -q https://github.com/rhyeal/aws-rotate-iam-keys/raw/master/aws-rotate-iam-keys.X.Y.Z.deb -O aws-rotate-iam-keys.deb
sudo dpkg -i aws-rotate-iam-keys.deb
sudo apt-get install -f
rm aws-rotate-iam-keys.deb # optional file clean up
```

### Other Linux

```
git clone https://github.com/rhyeal/aws-rotate-iam-keys.git
sudo cp aws-rotate-iam-keys/src/bin/aws-rotate-iam-keys /usr/bin/
rm -rf aws-rotate-iam-keys
```

***IMPORTANT:*** You must install your own cron job for automated key
rotation. See [Configuration](#configuration).

### Windows

[Click here](https://raw.githubusercontent.com/rhyeal/aws-rotate-iam-keys/master/Windows/aws-rotate-iam-keys.ps1)
to download the executable PowerShell script.

Simply place this in any directory and then run it. It will install the
Scheduled Task to rotate your keys nightly upon first run and will rotate your
keys on each run thereafter.

### AWS

The minimal needed permissions for the AWS user are:
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:ListAccessKeys",
        "iam:CreateAccessKey",
        "iam:DeleteAccessKey"
      ],
      "Resource": [
        "arn:aws:iam::*:user/${aws:username}"
      ]
    }
  ]
}
```

## Usage

#### To rotate your default profile manually:

```
$ aws-rotate-iam-keys
Rotating keys for profiles: default
Verifying configuration
Verifying credentials
Creating new access key
Created new key AKIAIOSFODNN7EXAMPLE
Updating profile: default
Deleting old access key
Deleted old key AKIARCPUMEZ3BEXAMPLE
Keys rotated
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

For some operating systems, you need to install your own scheduled job as not
all package managers allow programs to create their own scheduled jobs. Also,
the scheduled job installed on Ubuntu, Debian and Windows only rotates keys for
your default profile. If you need to rotate keys for other profiles you will
need to edit the job or add more jobs.

### Ubuntu/Debian

A default job was added to your crontab during installation. This job rotates
keys for your default profile. To rotate keys for other profiles you will need
to edit your crontab and modify the configuration. Open your crontab by typing:

```
EDITOR=nano crontab -e
```

Look for a line like:

```
33 4 * * * /usr/bin/aws-rotate-iam-keys --profile default >/dev/null #rotate AWS keys daily
```

Edit the profile for the job if necessary. Add further jobs if you need to
invoke `aws-rotate-iam-keys` multiple times to rotate multiple profiles.

Save your crontab with Ctrl + O and then press [Enter]. Exit and apply changes
with Ctrl + X. That's it!

### MacOS

[Launchd](http://www.launchd.info/) is the MacOS replacement for cron. Unlike
cron, which on MacOS skips job invocations when the computer is asleep, launchd
will start the job the next time the computer wakes up.

The Homebrew formula installs a launchd job which can be used to automatically
rotate your IAM keys daily. Unfortunately, Homebrew forumlae cannot
automatically start launchd jobs, so you must manually enable it:

```sh
brew services start aws-rotate-iam-keys
```

A default/global configuration file for the launchd job is installed to:

```sh
$(brew --prefix)/etc/aws-rotate-iam-keys
```

This default configuration rotates keys for your default AWS profile only.
To customise the configuration, for example to rotate multiple keys, create a
copy of this file named `.aws-rotate-iam-keys` in your home directory and edit
it, e.g.

```sh
cp $(brew --prefix)/etc/aws-rotate-iam-keys ~/.aws-rotate-iam-keys
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

```sh
brew services restart aws-rotate-iam-keys
```

That's it. Your keys should have been rotated, and will now be rotated every
day for you. You can use the AWS CLI to check that your access keys have been
rotated as expected, e.g.

```sh
aws iam list-access-keys --profile default
```

If it hasn't worked, check the MacOS system log for error entries matching
`aws-rotate-iam-keys`. If you can't find anything useful, the launchd job also
writes output to a file in the `/tmp` directory matching the job name, e.g.

```sh
cat /tmp/homebrew.mxcl.aws-rotate-iam-keys.log
```

### Other Linux

Add a cron job to run AWS Rotate IAM Keys nightly. Open your crontab by typing:

```
EDITOR=nano crontab -e
```

Copy and paste the following line into the end of the crontab file:

```cron
33 4 * * * /usr/bin/aws-rotate-iam-keys --profile default >/dev/null #rotate AWS keys daily
```

Edit the profile for the job if necessary. Add further jobs if you need to
invoke `aws-rotate-iam-keys` multiple times to rotate multiple profiles.

Note: your version of cron might skip job invocations when the computer is
asleep, so you may need to schedule the job to run at a time when your
computer is likely to be awake.

Save your crontab with Ctrl + O and then press [Enter]. Exit and apply changes
with Ctrl + X. That's it!

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

### Get In Touch

Did you open a PR or find a bug and more than a few days have passed? Hit me up on email at **awsRotateKeys@rhyeal.com** and I'll address the issue promptly!
