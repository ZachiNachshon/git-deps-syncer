# typed: false
# frozen_string_literal: true

class GitDepsSyncer < Formula
  desc "Sync git repositories as external source dependencies"
  homepage "https://ZachiNachshon.github.io/git-deps-syncer/"
  version "0.8.0"
  url "https://github.com/ZachiNachshon/git-deps-syncer/releases/download/v0.8.0/git-deps-syncer.tar.gz"
  sha256 "cf17bd24822963c7f9e86e1f255fce162c16ca755ab90c0c33709bb359f1457a"
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
