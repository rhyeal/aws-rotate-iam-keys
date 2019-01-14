class AwsRotateIamKeys < Formula
  desc "Automatically set up a cron job to rotate your IAM keys"
  homepage "https://aws-rotate-iam-keys.com"
  url "https://github.com/rhyeal/aws-rotate-iam-keys/archive/v0.8.1.tar.gz"
  sha256 "bff7a999f402db12114fae91d46455e5f36b9559fd4a07caad09c5f42a99b8d6"
  depends_on "awscli"
  depends_on "gnu-getopt"
  depends_on "jq"

  def install
    bin.install "src/bin/aws-rotate-iam-keys"
  end

  test do
    system bin/"aws-rotate-iam-keys", "--version"
  end
end
