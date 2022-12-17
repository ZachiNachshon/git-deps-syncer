# typed: false
# frozen_string_literal: true

class GitDepsSyncer < Formula
  desc "Sync git repositories as external source dependencies"
  homepage "https://ZachiNachshon.github.io/git-deps-syncer/"
  version "0.7.0"
  url "https://github.com/ZachiNachshon/git-deps-syncer/releases/download/v0.7.0/git-deps-syncer.tar.gz"
  sha256 "34035686355af4d00dc6a9b87ac375c1ed0efd3fc5853e48a2c4d0d9634cf520"
  license "MIT"

  depends_on "git"
  depends_on "jq"
  depends_on "gh" => :optional

  def install
    # Add extracted files to the Homebrew install directory
    libexec.install Dir["*"]
    libexec.install Dir[".git-deps"]
    # Add a relative symlink from Homebrew libexec to bin folder
    bin.install_symlink libexec/"git-deps-syncer.sh" => "git-deps-syncer"
  end
  
  test do
    system "#{bin}/git-deps-syncer version"
  end
end
