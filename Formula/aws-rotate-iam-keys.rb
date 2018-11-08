class AwsRotateIamKeys < Formula
  desc "Automatically set up a cron job to rotate your IAM keys"
  homepage "https://aws-rotate-iam-keys.com"
  url "https://github.com/rhyeal/aws-rotate-iam-keys/archive/v0.8.0.tar.gz"
  sha256 "1e235141d78013f4c7b3e8d6ff34b4c7b5cc3d302d750705f04d494e1e63e4c5"
  depends_on "awscli"
  depends_on "jq"

  def install
    bin.install "src/bin/aws-rotate-iam-keys"
  end

  test do
    system bin/"aws-rotate-iam-keys", "--version"
  end
end 
