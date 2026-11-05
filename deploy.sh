#!/usr/bin/env bash
# One-time deploy of the personal page to https://leoq77777.github.io
# Run from your own Mac terminal:  bash ~/projects/leoq77777.github.io/deploy.sh
set -euo pipefail

GH_USER="leoq77777"
REPO="${GH_USER}.github.io"
BG_URL="https://commons.wikimedia.org/wiki/Special:FilePath/Henri_Fantin-Latour_-_Still_Life_with_Roses_and_Fruit_MET_DT8649.jpg?width=2000"

cd "$(dirname "$0")"

# 1. Background painting (public domain, The Met)
mkdir -p assets
if [ ! -s assets/bg.jpg ]; then
  echo "Downloading background painting..."
  curl -fL -A "personal-site-setup/1.0" -o assets/bg.jpg "$BG_URL" \
    || { echo "Download failed; using the hosted image instead."; \
         sed -i '' "s#url(\"assets/bg.jpg\")#url(\"${BG_URL}\")#" style.css; rm -f assets/bg.jpg; }
fi

# 2. Git repo
[ -d .git ] || git init -b main
git add -A
git commit -m "Personal page v1" || echo "Nothing new to commit."

# 3. GitHub repo + push
if ! git remote get-url origin >/dev/null 2>&1; then
  if command -v gh >/dev/null 2>&1; then
    gh repo create "${GH_USER}/${REPO}" --public --source=. --remote=origin --push
    echo "Done → https://${REPO}  (first build takes ~1 minute)"
    exit 0
  fi
  git remote add origin "https://github.com/${GH_USER}/${REPO}.git"
  echo
  echo "No gh CLI found. Create an EMPTY public repo named '${REPO}' at:"
  echo "    https://github.com/new"
  read -r -p "Press Enter once it exists... "
fi

git push -u origin main
echo "Done → https://${REPO}  (first build takes ~1 minute)"
