# typed: false
# frozen_string_literal: true

class GitDepsSyncer < Formula
  desc "Sync git repositories as external source dependencies"
  homepage "https://ZachiNachshon.github.io/git-deps-syncer/"
  version "0.6.0"
  url "https://github.com/ZachiNachshon/git-deps-syncer/releases/download/v0.6.0/git-deps-syncer.tar.gz"
  sha256 "f4b5839ba9b048219951b2a3d97549bfb1cc238fe7a4905f6d40854a13403e5b"
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
