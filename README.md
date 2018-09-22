# aws-rotate-iam-keys
Rotate your IAM Keys to be in compliance with security best practices. AWS talks about rotating your keys every 30, 45, or 90 days. But who has the time to make their own script and remember to do that? I did. And security is easier when its less than 3 lines that you need to copy + paste to be secure. Now it's easy to rotate your IAM credentials nightly and wake up with more security than the day before.

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

### Other Linux

```

```

### Windows

## Features

## Documentation


## Additional Cron Instructions
For some operating systems, you need to install your own cron schedule. This is
due to the fact that some operating systems do not allow installed programs
via the package managers selected to create their own cron schedules.

### MacOS


### Windows

## On the Web!
Visit us on the web at [aws-rotate-iam-keys.com](https://aws-rotate-iam-keys.com) for full installation instructions
in a snazzy single-page UI. It's basically this README with some colors.
