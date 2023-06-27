class AwsRotateIamKeys < Formula
  desc "Automatically rotate your IAM keys daily"
  homepage "https://aws-rotate-iam-keys.com"
  url "https://github.com/rhyeal/aws-rotate-iam-keys.git", tag: "v0.9.8.5"
  depends_on "gnu-getopt"
  depends_on "jq"
  depends_on "awscli" => :recommended

  head do
    url "https://github.com/rhyeal/aws-rotate-iam-keys.git"
  end

  def install
    bin.install "src/bin/aws-rotate-iam-keys"
    (buildpath/"aws-rotate-iam-keys").write <<~EOS
      --profile default
    EOS
    etc.install "aws-rotate-iam-keys"
  end

  def caveats
    <<~EOS
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

  service do
    run ["bash", "-c", "if ! curl -s www.google.com; then sleep 60; fi; cp /dev/null /tmp/#{plist_name}.log; ( grep -E ^[[:space:]]*- ~/.aws-rotate-iam-keys || cat #{etc}/aws-rotate-iam-keys ) | while read line; do #{opt_bin}/aws-rotate-iam-keys $line; done"]
    run_type :cron
    run_at_load true
    cron "23 3 * * *"
    environment_variables PATH: std_service_path_env
    log_path "/tmp/#{plist_name}.log"
    error_log_path "/tmp/#{plist_name}.log"
  end

  test do
    system bin/"aws-rotate-iam-keys", "--version"
  end
end
