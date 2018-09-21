class AwsRotateIamKeys < Formula
  desc "Automatically set up a cron job to rotate your IAM keys"
  homepage "https://aws-rotate-iam-keys.com"
  url "https://github.com/rhyeal/aws-rotate-iam-keys/archive/v0.2.1.tar.gz"
  sha256 "50874810121eb85457a21f7785f47888f4a44975cd80392b312e7f675b40e1f3"
  depends_on "awscli"
  depends_on "jq"

  def install
    bin.install "src/bin/aws-rotate-iam-keys"
  end

  test do
    system bin/"aws-rotate-iam-keys", "--version"
  end
end
