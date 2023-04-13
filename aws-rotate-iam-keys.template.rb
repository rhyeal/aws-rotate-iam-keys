=begin
${TEMPLATE_DISCLAIMER}
Hint: Look in the project root folder for the template file
=end

class AwsRotateIamKeys < Formula
  desc "Automatically rotate your IAM keys daily"
  homepage "https://aws-rotate-iam-keys.com"
  url "${HOMEBREW_URL}"
  sha256 "${HOMEBREW_SHA}"
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

  def log_path
    var/"log/#{plist_name}.log"
  end
  service do
    run ["bash", "-c", "if ! curl -s www.google.com; then sleep 60; fi; cp /dev/null #{f.log_path} ; ( grep -E ^[[:space:]]*- ~/.aws-rotate-iam-keys || cat #{etc}/aws-rotate-iam-keys ) | while read line; do #{opt_bin}/aws-rotate-iam-keys $line; done"]
    run_type :cron
    run_at_load false
    cron "23 3 * * *"
    environment_variables PATH: std_service_path_env
    log_path f.log_path
    error_log_path f.log_path
  end

  test do
    system bin/"aws-rotate-iam-keys", "--version"
  end
end
