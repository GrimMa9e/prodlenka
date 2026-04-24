#!/usr/bin/env sh
set -eu

OPENAPI_URL="${1:-${OPENAPI_URL}}"
OUT_FILE="${2:-./output/openapi/latest-openapi.json}"

mkdir -p "$(dirname "$OUT_FILE")"

curl -fsSL "$OPENAPI_URL" | python3 -m json.tool > "$OUT_FILE"

if ! grep -q '"openapi"\|"swagger"' "$OUT_FILE"; then
  echo "Downloaded file does not look like an OpenAPI/Swagger document: $OUT_FILE" >&2
  exit 1
fi

echo "OpenAPI spec downloaded and validated: $OUT_FILE"
echo "Source URL: $OPENAPI_URL"
