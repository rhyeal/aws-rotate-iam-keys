class AwsRotateIamKeys < Formula
  desc "Automatically rotate your IAM keys daily"
  homepage "https://aws-rotate-iam-keys.com"
  url "https://github.com/rhyeal/aws-rotate-iam-keys/archive/v0.9.2.tar.gz"
  sha256 "9101bff2a889e5c883fda99b12588dd50bee9d42faf77f6d6e5d94ab35abb9e1"
  depends_on "awscli" => :recommended
  depends_on "gnu-getopt"
  depends_on "jq"

  head do
    Dir.chdir(File.expand_path(File.join(File.dirname(__FILE__), '../'))) do
      url %x{git config --local --get remote.origin.url | tr -d '\n'}, using: :git
    end
  end

  devel do
    Dir.chdir(File.expand_path(File.join(File.dirname(__FILE__), '../'))) do
      url %x{git config --local --get remote.origin.url | tr -d '\n'}, using: :git, branch: "develop"
      version %x{git describe develop --always | tr -d '\n'}
    end
  end

  def install
    bin.install "src/bin/aws-rotate-iam-keys"
    (buildpath/"aws-rotate-iam-keys").write <<~EOS
      --profile default
    EOS
    etc.install "aws-rotate-iam-keys"
  end

  def caveats
    s = <<~EOS
      We've installed a default/global configuration file to:
          #{etc}/aws-rotate-iam-keys

      The default configuration rotates keys for your default AWS profile only.

      To customise the configuration, for example to rotate multiple profiles,
      create a copy of this file named ".aws-rotate-iam-keys" in your home
      directory and edit it, e.g.

          cp #{etc}/aws-rotate-iam-keys ~/.aws-rotate-iam-keys
          nano ~/.aws-rotate-iam-keys

      When run as a service, the aws-rotate-iam-keys command is invoked once
      daily for each line in the configuration. Each line contains a single set
      of command line options. If you need to invoke the command multiple times
      to rotate your keys, you must add multiple lines to the configuration, e.g.

          --profiles default,myProfile
          --profile myOtherProfile
    EOS
  end

  plist_options :startup => false

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>EnvironmentVariables</key>
      <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
      </dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>/bin/bash</string>
        <string>-c</string>
        <string>if ! curl -s www.google.com > /dev/null; then sleep 60; fi; cp /dev/null /tmp/#{plist_name}.log ; ( egrep '^[[:space:]]*-' ~/.aws-rotate-iam-keys 2>/dev/null || cat #{etc}/aws-rotate-iam-keys ) | while read line; do aws-rotate-iam-keys $line; done</string>
      </array>
      <key>StandardOutPath</key>
      <string>/tmp/#{plist_name}.log</string>
      <key>StandardErrorPath</key>
      <string>/tmp/#{plist_name}.log</string>
      <key>RunAtLoad</key>
      <true/>
      <key>StartCalendarInterval</key>
      <dict>
        <key>Hour</key>
        <integer>3</integer>
        <key>Minute</key>
        <integer>23</integer>
      </dict>
    </dict>
    </plist>
  EOS
  end

  test do
    system bin/"aws-rotate-iam-keys", "--version"
  end
end
