#!/bin/bash

set -e

USERNAME="tb-killa"
TOPIC="featured"
TOKEN="${GITHUB_TOKEN}"

# Fetch repositories with the topic
output=$(curl -s -H "Authorization: token $TOKEN" \
  "https://api.github.com/users/$USERNAME/repos?per_page=100")
status=$?
if [ $status -ne 0 ]; then
  echo "curl failed with exit code $status"
  exit $status
fi

repos=$(echo "$output" | jq -r '.[] | select(.topics | index("'"$TOPIC"'")) | "- [\(.name)](\(.html_url)) - \(.description)"')
status=$?
if [ $status -ne 0 ]; then
  echo "jq processing failed with exit code $status"
  exit $status
fi

new_section="## 🚀 Featured Repositories\n\n${repos}\n"

awk -v n="$new_section" '
  BEGIN {found=0}
  /<!-- featured-start -->/ {print; print n; found=1; next}
  /<!-- featured-end -->/ {found=0}
  !found
' README.md > README.tmp && mv README.tmp README.md
