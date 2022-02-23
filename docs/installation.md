<h1 id="installation" align="center">Installation<br><br></h1>

- [Pre-Built Release](#pre-built-release)

<br>

<h2 id="pre-built-release">Pre-Built Release</h2>

Download and install `git-deps-syncer` binary (copy & paste into a terminal):

```bash
bash <<'EOF'

# Change Version accordingly
VERSION=0.1.0

# Create a temporary folder
repo_temp_path=$(mktemp -d ${TMPDIR:-/tmp}/git-deps-syncer-repo.XXXXXX)
cwd=$(pwd)
cd ${repo_temp_path}

# Download & extract
echo -e "\nDownloading git-deps-syncer to temp directory...\n"
curl -SL "https://github.com/ZachiNachshon/git-deps-syncer/releases/download/v${VERSION}/git-deps-syncer.sh"

# Create a dest directory and move the binary
echo -e "\nMoving binary to ~/.local/bin"
mkdir -p ${HOME}/.local/bin; mv git-deps-syncer.sh ${HOME}/.local/bin

# Add this line to your *rc file (zshrc, bashrc etc..) to make `git-deps-syncer` available on new sessions
echo "Exporting ~/.local/bin (make sure to have it available on PATH)"
export PATH="${PATH}:${HOME}/.local/bin"

cd ${cwd}

# Cleanup
if [[ ! -z ${repo_temp_path} && -d ${repo_temp_path} && ${repo_temp_path} == *"git-deps-syncer-repo"* ]]; then
	echo "Deleting temp directory"
	rm -rf ${repo_temp_path}
fi

echo -e "\nDone (type 'git-deps-syncer' for help)\n"

EOF
```

<br>

