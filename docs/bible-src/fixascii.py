import re, glob, sys
END = '│┐┘┤'
def fix_block(text):
    lines = text.split('\n')
    i = 0; changed = 0
    while i < len(lines):
        if lines[i].rstrip() and lines[i].rstrip()[-1] in END:
            j = i
            while j < len(lines) and lines[j].rstrip() and lines[j].rstrip()[-1] in END:
                j += 1
            run = list(range(i, j))
            if len(run) >= 2:
                cols = [len(lines[k].rstrip()) - 1 for k in run]
                # target: column of a top-right corner if present, else most common
                tops = [c for k, c in zip(run, cols) if lines[k].rstrip()[-1] == '┐']
                from collections import Counter
                target = tops[0] if tops else Counter(cols).most_common(1)[0][0]
                for k, c in zip(run, cols):
                    d = target - c
                    if d == 0 or abs(d) > 3: continue
                    s = lines[k].rstrip(); last = s[-1]; body = s[:-1]
                    fill = '─' if last in '┐┘' and body.endswith('─') else ' '
                    if d > 0:
                        body = body + fill * d
                    else:
                        tail = body[d:]
                        if set(tail) <= {fill}: body = body[:d]
                        else: continue
                    lines[k] = body + last; changed += 1
            i = j
        else:
            i += 1
    return '\n'.join(lines), changed
total = 0
for f in sorted(glob.glob('chapters/*.md')):
    s = open(f).read()
    def rep(m):
        global total
        new, c = fix_block(m.group(1)); total += c
        return "```ascii\n" + new + "```"
    s2 = re.sub(r"```ascii\n(.*?)```", rep, s, flags=re.S)
    if s2 != s: open(f, 'w').write(s2); print('fixed', f)
print('lines changed', total)
