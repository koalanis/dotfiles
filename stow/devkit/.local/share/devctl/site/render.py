#!/usr/bin/env python3
"""Render the devctl project site from projects.json.

Reads metadata only. Nothing here talks to git, gh, glab or nb: whatever
`devctl meta` put in the JSON is the whole truth of the site.
"""

import argparse
import html
import json
import pathlib
import shutil
import urllib.parse


def esc(value):
    return html.escape(str(value if value is not None else ""), quote=True)


def file_url(path):
    return "file://" + urllib.parse.quote(str(path))


def short_date(value):
    return str(value or "")[:10]


def badge(text, cls=""):
    return f'<span class="badge {cls}">{esc(text)}</span>'


def project_badges(project):
    out = []
    host = project.get("host") or "local"
    out.append(badge(host, f"host-{host}"))
    if project.get("language"):
        out.append(badge(project["language"]))
    if project.get("visibility") == "private":
        out.append(badge("private", "private"))
    if project.get("status"):
        out.append(badge(project["status"]))
    for tag in project.get("tags") or []:
        out.append(badge("#" + str(tag)))
    notes = (project.get("notes") or {}).get("count") or 0
    if notes:
        out.append(badge(f"{notes} note{'s' if notes != 1 else ''}", "notes"))
    if project.get("updated"):
        out.append(badge(short_date(project["updated"])))
    local = project.get("local") or {}
    if local.get("dirty"):
        out.append(badge(f"{local['dirty']} dirty", "dirty"))
    if local.get("ahead"):
        out.append(badge(f"{local['ahead']} unpushed", "dirty"))
    return out


def page(title, body, depth=0, subtitle=""):
    root = "../" * depth
    head_sub = f"<p>{esc(subtitle)}</p>" if subtitle else ""
    return f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{esc(title)}</title>
<link rel="stylesheet" href="{root}assets/style.css">
</head>
<body>
<main>
<header class="masthead">
<h1>{esc(title)}</h1>
{head_sub}
</header>
{body}
</main>
</body>
</html>
"""


def index_page(meta, projects):
    hosts = sorted({p.get("host") or "local" for p in projects})
    chips = "".join(
        f'<button class="chip" data-host="{esc(h)}" aria-pressed="false">{esc(h)}</button>'
        for h in hosts
    )
    chips += '<button class="chip" data-notes="1" aria-pressed="false">has notes</button>'

    cards = []
    for p in projects:
        haystack = " ".join(
            str(x)
            for x in [
                p.get("name"),
                p.get("title"),
                p.get("description"),
                p.get("blurb"),
                p.get("language"),
                p.get("path"),
                " ".join(str(t) for t in (p.get("tags") or [])),
            ]
            if x
        ).lower()
        blurb = p.get("blurb") or p.get("description") or ""
        notes = (p.get("notes") or {}).get("count") or 0
        cards.append(
            f"""<a class="card" href="projects/{esc(p['slug'])}.html"
   data-host="{esc(p.get('host') or 'local')}" data-notes="{notes}"
   data-search="{esc(haystack)}">
<h2>{esc(p.get('title') or p['name'])}</h2>
<p>{esc(blurb) or '<span class="empty">no description</span>'}</p>
<div class="meta-row">{''.join(project_badges(p))}</div>
</a>"""
        )

    counts = (
        f"{len(projects)} projects · "
        f"{sum(1 for p in projects if (p.get('notes') or {}).get('count'))} with notes · "
        f"generated {esc(short_date(meta.get('generated_at')))}"
    )

    body = f"""<div class="toolbar">
<input type="search" id="q" placeholder="filter projects" autocomplete="off">
{chips}
</div>
<div class="grid" id="grid">
{''.join(cards)}
</div>
<p class="empty" id="none" hidden>nothing matches.</p>
<footer>{counts} · <a href="projects.json">projects.json</a></footer>
<script>
const q = document.getElementById('q');
const cards = [...document.querySelectorAll('.card')];
const chips = [...document.querySelectorAll('.chip')];
function apply() {{
  const term = q.value.trim().toLowerCase();
  const hosts = chips.filter(c => c.dataset.host && c.getAttribute('aria-pressed') === 'true')
                     .map(c => c.dataset.host);
  const notesOnly = chips.some(c => c.dataset.notes && c.getAttribute('aria-pressed') === 'true');
  let shown = 0;
  for (const card of cards) {{
    const ok = (!term || card.dataset.search.includes(term))
      && (!hosts.length || hosts.includes(card.dataset.host))
      && (!notesOnly || Number(card.dataset.notes) > 0);
    card.hidden = !ok;
    if (ok) shown++;
  }}
  document.getElementById('none').hidden = shown > 0;
}}
q.addEventListener('input', apply);
chips.forEach(c => c.addEventListener('click', () => {{
  c.setAttribute('aria-pressed', c.getAttribute('aria-pressed') === 'true' ? 'false' : 'true');
  apply();
}}));
</script>"""

    return page(meta.get("title") or "projects", body, depth=0,
                subtitle=meta.get("subtitle") or "")


def project_page(meta, p):
    facts = []

    def fact(label, value_html):
        if value_html:
            facts.append(f"<dt>{esc(label)}</dt><dd>{value_html}</dd>")

    if p.get("url"):
        fact(p.get("host") or "remote", f'<a href="{esc(p["url"])}">{esc(p.get("path") or p["url"])}</a>')
    if p.get("clone_url"):
        fact("clone", f'<code>{esc(p["clone_url"])}</code>')
    fact("visibility", esc(p.get("visibility") or ""))
    fact("language", esc(p.get("language") or ""))
    if p.get("stars"):
        fact("stars", esc(p["stars"]))
    fact("pushed", esc(short_date(p.get("pushed_at"))))
    fact("updated", esc(short_date(p.get("updated"))))
    if p.get("tags"):
        fact("tags", " ".join(badge("#" + str(t)) for t in p["tags"]))

    local = p.get("local") or {}
    if local.get("path"):
        fact("local", f'<a href="{file_url(local["path"])}"><code>{esc(local["path"])}</code></a>')
        fact("branch", esc(local.get("branch") or ""))
        state = []
        if local.get("dirty"):
            state.append(f"{local['dirty']} uncommitted")
        if local.get("ahead"):
            state.append(f"{local['ahead']} unpushed")
        if local.get("behind"):
            state.append(f"{local['behind']} behind")
        fact("working tree", esc(", ".join(state) or "clean"))
        commit = local.get("last_commit") or {}
        if commit.get("subject"):
            fact(
                "last commit",
                f'{esc(commit["subject"])}<br><span class="mono">{esc(commit.get("hash") or "")} '
                f'{esc(short_date(commit.get("date")))}</span>',
            )
    else:
        fact("local", '<span class="empty">not cloned</span>')

    for link in p.get("links") or []:
        if link.get("url"):
            fact(link.get("label") or "link", f'<a href="{esc(link["url"])}">{esc(link["url"])}</a>')

    sections = [f'<div class="panel"><h2>metadata</h2><dl class="facts">{"".join(facts)}</dl></div>']

    notes = p.get("notes") or {}
    items = notes.get("items") or []
    if items:
        rows = []
        for note in items:
            href = file_url(note["file"]) if note.get("file") else ""
            title = esc(note.get("title") or note.get("file") or "untitled")
            link = f'<a href="{href}">{title}</a>' if href else title
            cmd = f"nb {notes.get('notebook')}:{note.get('id')}" if note.get("id") else ""
            rows.append(
                f'<li>{link}<span class="note-cmd mono">{esc(cmd)}'
                f'{" · " + esc(short_date(note.get("modified"))) if note.get("modified") else ""}</span></li>'
            )
        sections.append(
            f'<div class="panel"><h2>notes · nb:{esc(notes.get("notebook"))}</h2>'
            f'<ul class="notes">{"".join(rows)}</ul></div>'
        )
    else:
        hint = f"nb notebooks add {esc(p['name'])}"
        sections.append(
            f'<div class="panel"><h2>notes</h2><p class="empty">no nb notebook for this project '
            f'(<code>{hint}</code>)</p></div>'
        )

    if p.get("readme"):
        sections.append(f'<div class="panel"><h2>readme</h2><pre class="readme">{esc(p["readme"])}</pre></div>')

    body = (
        '<a class="back" href="../index.html">&larr; all projects</a>'
        f'<div class="meta-row">{"".join(project_badges(p))}</div>'
        + "".join(sections)
        + f'<footer>generated {esc(short_date(meta.get("generated_at")))}</footer>'
    )

    subtitle = p.get("blurb") or p.get("description") or ""
    return page(p.get("title") or p["name"], body, depth=1, subtitle=subtitle)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--meta", required=True, help="projects.json")
    ap.add_argument("--out", required=True, help="output directory")
    ap.add_argument("--assets", required=True, help="directory holding style.css")
    args = ap.parse_args()

    meta = json.loads(pathlib.Path(args.meta).read_text())
    projects = [p for p in meta.get("projects", []) if not p.get("hidden")]

    out = pathlib.Path(args.out)
    # Stale pages from a previous build would otherwise linger forever.
    shutil.rmtree(out / "projects", ignore_errors=True)
    (out / "projects").mkdir(parents=True, exist_ok=True)
    (out / "assets").mkdir(parents=True, exist_ok=True)
    shutil.copyfile(pathlib.Path(args.assets) / "style.css", out / "assets" / "style.css")

    (out / "index.html").write_text(index_page(meta, projects))
    (out / "projects.json").write_text(json.dumps(meta, indent=2))
    for p in projects:
        (out / "projects" / f"{p['slug']}.html").write_text(project_page(meta, p))

    print(f"{len(projects)} pages -> {out}")


if __name__ == "__main__":
    main()
