# Fold template

## In NOTEBOOK.md

```markdown
## Fold <n> — <date> — <one-line headline>

**Executive summary**
- [FAV] <finding> (C201)
- [UNFAV] <finding> (C202) — <what it closes>
- [INSTR] <instrument/method result> (C200)

**New facts**
<k>. <statement> — certificates C…; caveats; disclosed deviations.

**Lanes**
| Lane | Model | Scope | State | Report |
|---|---|---|---|---|

**Executed orders — deviations from plan**
- <loss/restart/move/cap change/bench>: reason, effect on data.

**Roadmap / status to target**
- Certified: <list of paper claims with ✅/🔧/⏳>
- Next: <lane(s), model, ETA>
- User decisions pending: <list, recommended option first>
- Money: spent $…, credit $…, instances alive: 0
```

## Applying it

Use a small script so anchors cannot silently miss:

```python
import pathlib
p = pathlib.Path("NOTEBOOK.md"); s = p.read_text()
def rep(a, b):
    global s
    assert s.count(a) == 1, (s.count(a), a[:60]); s = s.replace(a, b)
rep("<!-- FOLDS-END -->", FOLD_TEXT + "\n<!-- FOLDS-END -->")
rep("**Status:** 85 claims", "**Status:** 88 claims")
p.write_text(s)
```

Then run all claims, and commit `fold <n>: <headline>`.

## In the message to the user

Use the same FAV/UNFAV/INSTR lines, a 3–5 line picture of the roadmap, the money, and the decisions they own. Report times in the user's timezone.
