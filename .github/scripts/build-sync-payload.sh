#!/usr/bin/env bash
set -eo pipefail

# Usage: build-sync-payload.sh <event_name> <full_sync> <before> <after>
EVENT_NAME="$1"
FULL_SYNC="$2"
BEFORE="$3"
AFTER="$4"

git config core.quotePath false

if [[ "$EVENT_NAME" == "workflow_dispatch" && "$FULL_SYNC" == "true" ]]; then
  echo "▶ 전체 .md 파일 동기화 시작"
  changed=$(git ls-tree -r --name-only HEAD | grep -E '\.md$' || true)
else
  if [[ "$BEFORE" == "0000000000000000000000000000000000000000" ]]; then
    changed=$(git ls-tree -r --name-only "$AFTER" -- '*.md')
  else
    changed=$(git diff --name-only --diff-filter=AM "$BEFORE" "$AFTER" -- '*.md')
  fi
fi

if [ -z "$changed" ]; then
  echo "skip=true" >> "$GITHUB_OUTPUT"
  exit 0
fi

changed=$(echo "$changed" | grep -v -E '^\.(nosync|github)/')

if [ -z "$changed" ]; then
  echo "skip=true" >> "$GITHUB_OUTPUT"
  exit 0
fi

echo "$changed" | while IFS= read -r file; do
  [ -z "$file" ] && continue
  created_at=$(git log --diff-filter=A --follow --format="%aI" -- "$file" | tail -1)
  updated_at=$(git log -1 --format="%aI" -- "$file")
  jq -n --arg path "$file" \
        --rawfile content "$file" \
        --arg createdAt "$created_at" \
        --arg updatedAt "$updated_at" \
    '{ path: $path, content: $content, createdAt: $createdAt, updatedAt: $updatedAt }'
done | jq -s '{ files: . }' > /tmp/sync-payload.json
