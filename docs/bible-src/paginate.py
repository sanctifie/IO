import json, re, sys
from pypdf import PdfReader
r = PdfReader(sys.argv[1])
def walk(o, acc):
    for x in o:
        if isinstance(x, list): walk(x, acc)
        else: acc.append((x.title.strip(), r.get_destination_page_number(x) + 1))
    return acc
outline = walk(r.outline, [])
strip = lambda s: re.sub(r'<[^>]+>', '', s).replace('&amp;', '&').replace('&#39;', "'").replace('&quot;', '"').strip()
toc = json.load(open('toc.json'))
pages, i = {}, 0
for t in toc:
    want = strip(t.get('h') or t['text'])
    for j in range(i, len(outline)):
        if re.sub(r'\s+', '', outline[j][0]) == re.sub(r'\s+', '', want):
            pages[t['id']] = outline[j][1]; i = j + 1; break
    else:
        print('NOT FOUND', want)
json.dump(pages, open('pages.json', 'w'))
print(len(pages), 'of', len(toc))
