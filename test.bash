#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Kota Matsunaga
# SPDX-License-Identifier: BSD-3-Clause

set -euo pipefail

ng () {
  echo "NG at line $1: $2" >&2
  res=1
}

res=0

# 1. Default normalization (fullwidth alnum -> halfwidth, punctuation -> 、/。, whitespace cleanup)
out=$(printf "  ＲＯＳ２の期限は １１月２６日,２３：５５です.  \n" | ./seikei)
exp="ROS2の期限は 11月26日、23:55です。"
[ "$out" = "$exp" ] || ng "$LINENO" "expected '$exp', got '$out'"

# 2. --no-hankaku keeps fullwidth ASCII
out=$(printf "ＡＢＣ１２３,\n" | ./seikei --no-hankaku)
exp="ＡＢＣ１２３、"
[ "$out" = "$exp" ] || ng "$LINENO" "expected '$exp', got '$out'"

# 3. --no-punct keeps original punctuation
out=$(printf "テスト, 確認.  ＡＢＣ\n" | ./seikei --no-punct)
exp="テスト, 確認. ABC"
[ "$out" = "$exp" ] || ng "$LINENO" "expected '$exp', got '$out'"

# 4. --no-space preserves leading/trailing/multiple spaces
out=$(printf "  a   b  \n" | ./seikei --no-space)
exp="  a   b  "
[ "$out" = "$exp" ] || ng "$LINENO" "expected '$exp', got '$out'"

# 5. Unknown option fails with non-zero exit code and stderr message
set +e
err=$(echo "test" | ./seikei --unknown-opt 2>&1 >/dev/null)
code=$?
set -e
[ "$code" -ne 0 ] || ng "$LINENO" "expected non-zero exit code, got $code"
[ -n "$err" ] || ng "$LINENO" "expected error message on stderr"

exit "$res"
