#!/bin/bash
# 카오스·심쿵 수정 순서 실행: 심쿵 13편 → (카오스 8편과 함께) 반영 → 나머지 105편 카오스+심쿵 → 반영. Grok 은 M4 Chrome(9230 터널).
cd "$(dirname "$0")/.." || exit 1
export GROK_CDP_PORT=9230
/usr/bin/python3 tools/grok_chaos_batch.py data/review/chaos/simkung_picks.json --tpl tools/prompts/simkung_grok.md > data/review/chaos/simkung.log 2>&1
~/.venvs/ja/bin/python tools/apply_boost.py data/review/chaos/*_grok_chaos.md data/review/chaos/*_grok_simkung.md > data/review/chaos/apply1.log 2>&1
/usr/bin/python3 tools/grok_chaos_batch.py data/review/chaos/boost_picks.json --tpl tools/prompts/boost_grok.md > data/review/chaos/boost.log 2>&1
~/.venvs/ja/bin/python tools/apply_boost.py data/review/chaos/*_grok_boost.md > data/review/chaos/apply2.log 2>&1
echo CHAIN_DONE
