#!/usr/bin/env bash

# live_subdoms-fixed.sh

# Usage: ./live_subdoms-fixed.sh target.com

#

# Creates numbered files in result/:

# fileN1.txt (assetfinder)

# fileN2.txt (alterx)

# fileN3.txt (subfinder)

# total_subdomN.txt (deduped)

# total_live_subdomN.txt (httpx pipeline result)

#

# This version avoids line-continuation problems and won't print tool output to terminal.

set -u

OUTDIR="result"

if [ "$#" -ne 1 ]; then
echo "Usage: $0 target.com"
exit 1
fi
TARGET="$1"

mkdir -p "$OUTDIR" || { echo "Failed to create $OUTDIR"; exit 1; }

# Find next run number

max=0
shopt -s nullglob
for f in "$OUTDIR"/total_subdom*.txt; do
base=$(basename "$f")
if [[ $base =~ ^total_subdom([0-9]+).txt$ ]]; then
n=${BASH_REMATCH[1]}
if (( n > max )); then
max=$n
fi
fi
done
shopt -u nullglob
N=$((max + 1))

F1="$OUTDIR/file${N}1.txt"
F2="$OUTDIR/file${N}2.txt"
F3="$OUTDIR/file${N}3.txt"
TOTAL="$OUTDIR/total_subdom${N}.txt"
LIVE="$OUTDIR/total_live_subdom${N}.txt"

echo "[*] Running scan #$N for $TARGET"

# Run assetfinder (stderr discarded, stdout -> file)

if command -v assetfinder >/dev/null 2>&1; then
echo "$TARGET" | assetfinder > "$F1" 2>/dev/null || :
else
: > "$F1"
fi

# Run alterx

if command -v alterx >/dev/null 2>&1; then
echo "$TARGET" | alterx > "$F2" 2>/dev/null || :
else
: > "$F2"
fi

# Run subfinder

if command -v subfinder >/dev/null 2>&1; then
echo "$TARGET" | subfinder > "$F3" 2>/dev/null || :
else
: > "$F3"
fi

# Merge + dedupe (single-line pipeline to avoid continuation quirks)

cat "$F1" "$F2" "$F3" 2>/dev/null | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | grep -v '^$' | sort -u > "$TOTAL" || :

# Decide httpx input: prefer total_target.txt in current dir, otherwise use generated TOTAL

if [ -f "total_target.txt" ]; then
HTTPX_INPUT="total_target.txt"
else
HTTPX_INPUT="$TOTAL"
fi

# Run httpx pipeline and produce hostnames only

if command -v httpx >/dev/null 2>&1; then
httpx -l "$HTTPX_INPUT" -silent 2>/dev/null | sed -E 's~https?://~~' | sed 's:/.*$::' | sort -u > "$LIVE" || :
else
: > "$LIVE"
fi

# Remove any unexpected *.err.log files inside OUTDIR (just in case)

find "$OUTDIR" -maxdepth 1 -type f -name "*.err.log" -delete

echo "[+] Done. Files created:"
printf '%s\n' "$(basename "$F1")" "$(basename "$F2")" "$(basename "$F3")" "$(basename "$TOTAL")" "$(basename "$LIVE")"

