class AwsRotateIamKeys < Formula
  desc "Automatically set up a cron job to rotate your IAM keys"
  homepage "https://aws-rotate-iam-keys.com"
  url "https://github.com/rhyeal/aws-rotate-iam-keys/archive/v0.3.1.tar.gz"
  sha256 "969d530b29f8a6264de0df98a0276629f4cb4d843dfd5c05f7b81d7576156ec9"
  depends_on "awscli"
  depends_on "jq"

  def install
    bin.install "src/bin/aws-rotate-iam-keys"
  end

  test do
    system bin/"aws-rotate-iam-keys", "--version"
  end
end
