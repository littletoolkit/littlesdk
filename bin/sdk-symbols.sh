#!/usr/bin/env bash
# File: sdk-symbols.sh
# Lists declared symbols as PATH;TYPE;NAME for diffing.

set -euo pipefail

BASE="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/.. &>/dev/null && pwd)"
SDK_PATH="$BASE"
# shellcheck source=/dev/null
source "$SDK_PATH/src/sh/lib.sh"

CTAGS=${CTAGS:-mise x -- ctags}

declare -A SEEN=()

main() {
	local files=()
	if [ "$#" -eq 0 ]; then
		mapfile -d '' -t files < <(find src -type f -name '*.*' -print0 | sort -z)
	else
		files=("$@")
	fi

	local file
	for file in "${files[@]}"; do
		process_file "$file"
	done

	local key
	for key in "${!SEEN[@]}"; do
		printf '%s\n' "$key"
	done | sort
}

process_file() {
	local file="$1"
	[[ -e "$file" ]] || return 0
	[[ -f "$file" ]] || return 0
	[[ "$file" == *.* ]] || return 0

	local rel
	rel="$(realpath --relative-to="$PWD" "$file")"

	while IFS= read -r line; do
		parse_tag_line "$rel" "$line"
	done < <(ctags_json "$file")

	while IFS= read -r line; do
		parse_import_export_line "$rel" "$line"
	done < <(import_export_lines "$file")
}

ctags_json() {
	$CTAGS --output-format=json --fields=+Kne --extras=+q "$1" 2>/dev/null || true
}

parse_tag_line() {
	local rel="$1"
	local line="$2"
	local kind name
	kind="$(json_field "$line" kind)"
	name="$(json_field "$line" name)"
	[[ -n "$kind" && -n "$name" ]] || return 0
	[[ "$kind" != local && "$kind" != parameter ]] || return 0
	[[ "$kind" != method || "$name" == *.* ]] || return 0
	add_row "$rel" "$kind" "$name"
}

parse_import_export_line() {
	local rel="$1"
	local line="$2"
	local kind name
	kind="${line%%;*}"
	name="${line#*;}"
	[[ "$name" != "$line" ]] || return 0
	add_row "$rel" "$kind" "$name"
}

import_export_lines() {
	local file="$1"
	case "$file" in
		*.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs) ;;
		*) return 0 ;;
	esac

	awk -f /dev/stdin "$file" <<'AWK'
function emit(kind, name) { if (name != "") print kind ";" name }
function trim(s) { sub(/^[[:space:]]+/, "", s); sub(/[[:space:]]+$/, "", s); return s }
{
	line = $0
	if (match(line, /^[[:space:]]*import[[:space:]]+(type[[:space:]]+)?([^;]+)[[:space:]]+from[[:space:]]+["'][^"']+["']/, m)) {
		clause = trim(m[2])
		if (match(clause, /^([A-Za-z_$][A-Za-z0-9_$]*)([[:space:]]*,[[:space:]]*\{.*\})?$/, d)) emit("import", d[1])
		if (match(clause, /^\*[[:space:]]+as[[:space:]]+([A-Za-z_$][A-Za-z0-9_$]*)$/, n)) emit("import", n[1])
		if (match(clause, /^\{(.*)\}$/, b)) {
			spec = b[1]
			n = split(spec, parts, /,/)
			for (i = 1; i <= n; i++) {
				part = trim(parts[i])
				if (match(part, /^([A-Za-z_$][A-Za-z0-9_$]*)([[:space:]]+as[[:space:]]+([A-Za-z_$][A-Za-z0-9_$]*))?$/, e)) emit("import", e[3] ? e[3] : e[1])
			}
		}
	}
	if (match(line, /^[[:space:]]*export[[:space:]]+(type[[:space:]]+)?\*[[:space:]]+as[[:space:]]+([A-Za-z_$][A-Za-z0-9_$]*)[[:space:]]+from[[:space:]]+["'][^"']+["']/, m)) emit("export", m[2])
	if (match(line, /^[[:space:]]*export[[:space:]]+(type[[:space:]]+)?\{(.*)\}([[:space:]]+from[[:space:]]+["'][^"']+["'])?/, m)) {
		spec = m[2]
		n = split(spec, parts, /,/)
		for (i = 1; i <= n; i++) {
			part = trim(parts[i])
			if (match(part, /^([A-Za-z_$][A-Za-z0-9_$]*)([[:space:]]+as[[:space:]]+([A-Za-z_$][A-Za-z0-9_$]*))?$/, e)) emit("export", e[3] ? e[3] : e[1])
		}
	}
}
AWK
}

json_field() {
	local json="$1"
	local key="$2"
	awk -v key="$key" 'match($0, "\"" key "\": \"([^\"]*)\"", m) { print m[1] }' <<<"$json"
}

add_row() {
	local rel="$1"
	local kind="$2"
	local name="$3"
	SEEN["$rel;$kind;$name"]=1
}

main "$@"

# EOF - vim: syn=bash
