#!/usr/bin/env bash
# wait_all.sh — the ONE detached waiter for every pending job of a lane.
# Start it once with run_in_background; it exits only on an event the lane must act on:
#   0 done     every tag in every hosts/jobfile has "END <tag> exit 0" (or is listed in moved.txt / dropped.txt)
#              and no rented instance is alive
#  11 anomaly  Traceback, END exit != 0, low acceptance, or a stale log (> STALE_MIN minutes unchanged)
#  12 kill     a kill-check script reports a failure
#  13 wake     a scheduled wake (wake.txt: "<ISO time> <reason>") is due
#  14 lost     a host unreachable in its last 3 pulls, or an instance gone with unfinished tags
#  15 floor    credit below FLOOR — every rented instance is destroyed BEFORE exiting
# Acknowledged events go in ack.txt (one line per event key) so they never fire twice.
#
# Configure via env or edit below. Provider calls go through PROVIDER_CMD, which must read its secret
# from a vault on stdin (never inline it), e.g.:
#   PROVIDER_CMD='vault exec provider_api_key -- sh -c "TOKEN=\$(cat) exec provider-cli \"\$@\"" _'
set -u
B=${B:-results/run}                 # lane state dir: hosts.txt, ack.txt, moved.txt, dropped.txt, wake.txt
HOSTS=$B/hosts.txt                  # lines: <name> <instance-id|local> <jobfile> <logdir>
STALE_MIN=${STALE_MIN:-90}
FLOOR=${FLOOR:-9.00}
CYCLE=${CYCLE:-300}
MIN_ACC=${MIN_ACC:-0.5}
KILL_CHECK=${KILL_CHECK:-}          # optional: script printing "<file>: ... -> FAIL" lines
PROVIDER_CMD=${PROVIDER_CMD:-}      # empty = no rented hosts
LOG=$B/waiter.log
touch "$B/ack.txt" "$B/moved.txt" "$B/dropped.txt"
say() { echo "$*" | tee -a "$LOG"; }
acked() { grep -qxF "$1" "$B/ack.txt"; }
say "$(date -u +%FT%TZ) waiter start (pid $$)"

credit() { [ -n "$PROVIDER_CMD" ] && eval "$PROVIDER_CMD credit" 2>/dev/null; }
alive_ids() { [ -n "$PROVIDER_CMD" ] && eval "$PROVIDER_CMD list-ids" 2>/dev/null; }

while :; do
  c=$(credit || true)
  if [ -n "$c" ] && python3 -c "import sys; sys.exit(0 if $c < $FLOOR else 1)"; then
    say "$(date -u +%FT%TZ) FLOOR (credit $c < $FLOOR): destroying all"
    for id in $(alive_ids); do eval "$PROVIDER_CMD pull $id" >/dev/null 2>&1; eval "$PROVIDER_CMD destroy $id" >/dev/null 2>&1 \
      && say "  $id pulled+destroyed" || say "  $id DESTROY FAILED"; done
    exit 15
  fi

  anom=; lost=; done_all=1; now=$(date +%s)
  while read -r name id jf ld; do
    [ -z "$name" ] || [ "${name#\#}" != "$name" ] && continue
    for t in $(awk '{print $1}' "$jf"); do
      grep -qE "^$t( |$)" "$B/moved.txt" "$B/dropped.txt" && continue
      grep -q " END $t exit 0" "$ld/queue.log" 2>/dev/null && continue
      done_all=0
      e=$(grep " END $t exit" "$ld/queue.log" 2>/dev/null | awk '$NF != "0"')
      [ -n "$e" ] && ! acked "$t END" && anom+="$name $t nonzero END"$'\n'
      f=$ld/$t.log
      if [ -f "$f" ]; then
        grep -q Traceback "$f" && ! acked "$t TB" && anom+="$name $t Traceback"$'\n'
        age=$(( (now - $(stat -c %Y "$f")) / 60 ))
        grep -q " START $t" "$ld/queue.log" 2>/dev/null && [ $age -gt "$STALE_MIN" ] && ! acked "$t STALE" \
          && anom+="$name $t STALE ${age}min"$'\n'
        acc=$(grep -o 'acc [0-9.]*' "$f" | tail -1 | awk '{print $2}')
        [ -n "$acc" ] && python3 -c "import sys; sys.exit(0 if $acc < $MIN_ACC else 1)" && ! acked "$t ACC" \
          && anom+="$name $t acceptance $acc"$'\n'
      fi
    done
    [ "$id" != local ] && [ -f "$B/pull.log" ] && \
      [ "$(grep "^$name " "$B/pull.log" | tail -3 | grep -c UNREACHABLE)" = 3 ] && ! acked "$name LOST" \
      && lost+="$name ($id) unreachable in last 3 pulls"$'\n'
  done < "$HOSTS"

  [ -n "$anom" ] && { say "$(date -u +%FT%TZ) ANOMALY (credit ${c:-n/a})"; say "$anom"; exit 11; }
  [ -n "$lost" ] && { say "$(date -u +%FT%TZ) LOST"; say "$lost"; exit 14; }
  if [ -n "$KILL_CHECK" ]; then
    k=$($KILL_CHECK 2>/dev/null | grep -- '-> FAIL' | while read -r l; do acked "${l%%:*} KILL" || echo "$l"; done)
    [ -n "$k" ] && { say "$(date -u +%FT%TZ) KILL"; say "$k"; exit 12; }
  fi
  if [ -s "$B/wake.txt" ]; then
    read -r wt wr < "$B/wake.txt"
    [ "$now" -ge "$(date -d "$wt" +%s)" ] && { say "$(date -u +%FT%TZ) WAKE $wr"; : > "$B/wake.txt"; exit 13; }
  fi
  if [ $done_all = 1 ] && [ -z "$(alive_ids || true)" ]; then
    say "$(date -u +%FT%TZ) DONE (credit ${c:-n/a})"; exit 0
  fi
  sleep "$CYCLE"
done
