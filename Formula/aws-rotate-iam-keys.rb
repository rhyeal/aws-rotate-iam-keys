class AwsRotateIamKeys < Formula
  desc "Automatically set up a cron job to rotate your IAM keys"
  homepage "https://aws-rotate-iam-keys.com"
  url "https://github.com/rhyeal/aws-rotate-iam-keys/archive/v0.2.5.tar.gz"
  sha256 "850e27061d45a86a74442d26a37037ca24daeca5e387a2335d7603551e3d2ca2"
  depends_on "awscli"
  depends_on "jq"

  def install
    bin.install "src/bin/aws-rotate-iam-keys"
  end

  test do
    system bin/"aws-rotate-iam-keys", "--version"
  end
end
