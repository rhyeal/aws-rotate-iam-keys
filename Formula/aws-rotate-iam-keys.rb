class AwsRotateIamKeys < Formula
  desc "Automatically set up a cron job to rotate your IAM keys"
  homepage "https://aws-rotate-iam-keys.com"
  url "https://github.com/rhyeal/aws-rotate-iam-keys/archive/v0.6.0.tar.gz"
  sha256 "d702b7c5f43f1935d8a824adfbc36329f4aa95892e6eda1b102e38ac772970be"
  depends_on "awscli"
  depends_on "jq"

  def install
    bin.install "src/bin/aws-rotate-iam-keys"
  end

  test do
    system bin/"aws-rotate-iam-keys", "--version"
  end
end
