#!/usr/bin/env python3
"""
Prerender crawlable HTML for every route of the Flutter Web app.

Why this exists
---------------
Flutter Web paints everything onto a <canvas>. A crawler that fetches the
page (AdSense's Mediapartners-Google, Googlebot's first pass, link
scrapers) sees only index.html: a "Loading..." div and a script tag. None
of the real content (guides, FAQ, About, ...) is in the DOM, so AdSense
concludes the site has no publisher content.

This script reads the *same* Dart data files the app renders from
(lib/data/*.dart) and writes plain HTML files into web/, so every URL
returns real, readable content in the raw HTML. Firebase Hosting serves
existing files before applying the `** -> /index.html` rewrite.

Usage (from the repo root, before `flutter build web`):
    python3 tool/prerender.py
"""
import html
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LIB = ROOT / "lib"
WEB = ROOT / "web"
ORIGIN = "https://flogo-gen.web.app"
SITE = "FLogo Generator"

# --------------------------------------------------------------------------
# Minimal Dart literal parser (strings, lists, constructor calls)
# --------------------------------------------------------------------------
ESC = {"n": "\n", "t": "\t", "'": "'", '"': '"', "\\": "\\", "$": "$", "r": "\r"}


def tokenize(src):
    i, n, out = 0, len(src), []
    while i < n:
        c = src[i]
        if c.isspace():
            i += 1
        elif src.startswith("//", i):
            while i < n and src[i] != "\n":
                i += 1
        elif src.startswith("/*", i):
            i = src.index("*/", i) + 2
        elif c in "'\"":
            q, i, buf = c, i + 1, []
            while src[i] != q:
                if src[i] == "\\":
                    buf.append(ESC.get(src[i + 1], src[i + 1]))
                    i += 2
                else:
                    buf.append(src[i])
                    i += 1
            i += 1
            s = "".join(buf)
            # adjacent string literals concatenate
            if out and out[-1][0] == "STR":
                out[-1] = ("STR", out[-1][1] + s)
            else:
                out.append(("STR", s))
        elif c.isalpha() or c == "_":
            j = i
            while j < n and (src[j].isalnum() or src[j] in "_."):
                j += 1
            out.append(("ID", src[i:j]))
            i = j
        elif c.isdigit() or (c == "-" and i + 1 < n and src[i + 1].isdigit()):
            j = i + 1
            while j < n and (src[j].isdigit() or src[j] == "."):
                j += 1
            out.append(("NUM", src[i:j]))
            i = j
        else:
            out.append(("P", c))
            i += 1
    return out


class Parser:
    def __init__(self, toks, pos=0):
        self.t, self.p = toks, pos

    def peek(self):
        return self.t[self.p] if self.p < len(self.t) else ("EOF", "")

    def next(self):
        tok = self.peek()
        self.p += 1
        return tok

    def value(self):
        kind, val = self.peek()
        if kind == "ID" and val == "const":
            self.next()
            return self.value()
        if kind == "STR":
            self.next()
            return val
        if kind == "NUM":
            self.next()
            return float(val)
        if (kind, val) == ("P", "["):
            self.next()
            items = []
            while self.peek() != ("P", "]"):
                items.append(self.value())
                if self.peek() == ("P", ","):
                    self.next()
            self.next()
            return items
        if kind == "ID":
            self.next()
            if self.peek() == ("P", "("):
                self.next()
                pos_args, named = [], {}
                while self.peek() != ("P", ")"):
                    if self.t[self.p][0] == "ID" and self.t[self.p + 1] == ("P", ":"):
                        key = self.next()[1]
                        self.next()
                        named[key] = self.value()
                    else:
                        pos_args.append(self.value())
                    if self.peek() == ("P", ","):
                        self.next()
                self.next()
                return {"_": val, "pos": pos_args, "named": named}
            return val  # bare identifier (Icons.foo, Colors.x, ...)
        raise ValueError(f"unexpected token {self.peek()} at {self.p}")


def dart_list(path, var):
    """Parse `const List<...> var = [ ... ];` from a Dart file."""
    toks = tokenize((LIB / path).read_text(encoding="utf-8"))
    for idx in range(len(toks) - 1):
        if toks[idx] == ("ID", var) and toks[idx + 1] == ("P", "="):
            return Parser(toks, idx + 2).value()
    raise KeyError(var)


def dart_string(path, var):
    toks = tokenize((LIB / path).read_text(encoding="utf-8"))
    for idx in range(len(toks) - 1):
        if toks[idx] == ("ID", var) and toks[idx + 1] == ("P", "="):
            return Parser(toks, idx + 2).value()
    raise KeyError(var)


def title_body_pairs(path):
    """Find every `title: '...', body: '...'` pair in a widget file."""
    toks = tokenize((LIB / path).read_text(encoding="utf-8"))
    pairs = []
    for i in range(len(toks) - 5):
        if (toks[i] == ("ID", "title") and toks[i + 2][0] == "STR"
                and toks[i + 4] == ("ID", "body") and toks[i + 6][0] == "STR"
                and toks[i + 1] == ("P", ":") and toks[i + 3] == ("P", ",")):
            pairs.append((toks[i + 2][1], toks[i + 6][1]))
    return pairs


# --------------------------------------------------------------------------
# Load content
# --------------------------------------------------------------------------
def legal(sections):
    return [(s["pos"][0], s["pos"][1]) for s in sections]


ARTICLES = []
for a in dart_list("data/articles_content.dart", "kArticles"):
    n = a["named"]
    ARTICLES.append({
        "slug": n["slug"], "title": n["title"], "excerpt": n["excerpt"],
        "readTime": n["readTime"], "updated": n.get("lastUpdated", "August 2026"),
        "sections": [(s["named"].get("heading"), s["named"]["paragraphs"]) for s in n["sections"]],
    })

FAQS = [(f["pos"][0], f["pos"][1]) for f in dart_list("data/faq_content.dart", "kFaqs")]
ABOUT = legal(dart_list("data/about_content.dart", "kAboutSections"))
GUIDE = legal(dart_list("data/user_guide_content.dart", "kUserGuideSections"))
PRIVACY = legal(dart_list("data/legal_content.dart", "kPrivacySections"))
TERMS = legal(dart_list("data/legal_content.dart", "kTermsSections"))
STEPS = title_body_pairs("widgets/how_it_works_section.dart")
REASONS = title_body_pairs("widgets/why_use_section.dart")
EMAIL = dart_string("data/contact_info.dart", "kContactEmail")
CONTACT = [(c["named"]["label"], c["named"]["description"])
           for c in dart_list("data/contact_info.dart", "kContactCategories")]

# Route metadata. Titles/descriptions mirror kRouteSeo in lib/main.dart.
ROUTES = {
    "/": ("FLogo Generator — Free Flutter App Icon Generator",
          "Generate Flutter app icons for Android, iOS, Web, Windows, macOS, and Linux from one logo. "
          "Resize, package, and download your icons entirely in your browser — nothing is ever uploaded."),
    "/user-guide": ("User Guide · FLogo Generator",
                    "Learn how to generate, download, and use Flutter app icons for Android, iOS, Web, "
                    "Windows, macOS, and Linux — step by step."),
    "/guides": ("Guides & Articles · FLogo Generator",
                "App icon sizing, Android adaptive icons, iOS icon requirements, notification icons, "
                "and other Flutter icon guides."),
    "/about": ("About FLogo Generator",
               "Learn why FLogo Generator was created, how it works, and how it handles your images and privacy."),
    "/contact": ("Contact · FLogo Generator",
                 "Get in touch about bugs, feature requests, privacy questions, or general feedback for FLogo Generator."),
    "/privacy-policy": ("Privacy Policy · FLogo Generator",
                        "What FLogo Generator does and does not collect, how your uploaded image is processed "
                        "locally, and how advertising on this site is handled."),
    "/terms": ("Terms & Conditions · FLogo Generator",
               "The terms that apply to using FLogo Generator, including acceptable use, intellectual "
               "property, and limitation of liability."),
}

NAV = [("Home", "/"), ("User Guide", "/user-guide"), ("Guides", "/guides"),
       ("About", "/about"), ("Contact", "/contact")]
FOOT = [("Guides & Articles", "/guides"), ("User Guide", "/user-guide"), ("About", "/about"),
        ("Contact", "/contact"), ("Privacy Policy", "/privacy-policy"), ("Terms & Conditions", "/terms")]

# --------------------------------------------------------------------------
# HTML building blocks
# --------------------------------------------------------------------------
e = html.escape


def paras(ps):
    return "".join(f"<p>{e(p)}</p>" for p in ps)


def sections_html(secs, level=2):
    out = []
    for heading, ps in secs:
        if heading:
            out.append(f"<h{level}>{e(heading)}</h{level}>")
        out.append(paras(ps))
    return "\n".join(out)


def nav_html():
    links = "".join(f'<a href="{href}">{e(label)}</a>' for label, href in NAV)
    return f'<header class="seo-head"><a class="seo-logo" href="/">FLogo Generator</a><nav aria-label="Main">{links}</nav></header>'


def footer_html():
    links = "".join(f'<a href="{href}">{e(label)}</a>' for label, href in FOOT)
    return (f'<footer class="seo-foot"><nav aria-label="Footer">{links}</nav>'
            f'<p>© 2026 FLogo Generator · Open source · MIT Licence · Your logo never leaves your device.</p></footer>')


def wrap_main(inner):
    return (f'<div id="loading">Loading…</div>\n'
            f'<div id="seo-content">{nav_html()}<main>{inner}</main>{footer_html()}</div>')


def home_inner():
    steps = "".join(f"<li><h3>{e(t)}</h3><p>{e(b)}</p></li>" for t, b in STEPS)
    reasons = "".join(f"<li><h3>{e(t)}</h3><p>{e(b)}</p></li>" for t, b in REASONS)
    faqs = "".join(f"<h3>{e(q)}</h3><p>{e(a)}</p>" for q, a in FAQS)
    guides = "".join(
        f'<li><a href="/guides/{a["slug"]}">{e(a["title"])}</a><p>{e(a["excerpt"])}</p></li>' for a in ARTICLES)
    return f"""
<h1>FLogo Generator — Free Flutter App Icon Generator</h1>
<p>Upload one logo and generate platform-perfect Flutter app icons for Android, iOS, Web, Windows, macOS, and
Linux — sized, named, and folder-structured exactly as Flutter expects. Everything runs in your browser; nothing is
ever uploaded to a server. Free to use, with no account required.</p>
<h2>How It Works</h2><ol>{steps}</ol>
<h2>Why Use FLogo Generator</h2><ul>{reasons}</ul>
<h2>Frequently Asked Questions</h2>{faqs}
<h2>Guides &amp; Articles</h2><ul>{guides}</ul>
"""


def article_inner(a):
    return f"""
<article>
<p class="crumb"><a href="/guides">Guides</a> › {e(a['title'])}</p>
<h1>{e(a['title'])}</h1>
<p class="meta">{e(a['readTime'])} · Updated {e(a['updated'])}</p>
<p class="lede">{e(a['excerpt'])}</p>
{sections_html(a['sections'])}
<p>Ready to generate your icons? <a href="/">Open FLogo Generator</a>.</p>
</article>
"""


def legal_inner(title, intro, secs):
    return f"<h1>{e(title)}</h1><p class=\"lede\">{e(intro)}</p>" + \
        "".join(f"<h2>{e(t)}</h2>{paras(ps)}" for t, ps in secs)


def guides_inner():
    items = "".join(
        f'<li><h2><a href="/guides/{a["slug"]}">{e(a["title"])}</a></h2><p>{e(a["excerpt"])}</p>'
        f'<p class="meta">{e(a["readTime"])}</p></li>' for a in ARTICLES)
    return (f"<h1>Guides &amp; Articles</h1><p class=\"lede\">App icon sizing, platform requirements, and design "
            f"tips — everything we learned building this generator, written up so you don't have to dig through "
            f"platform docs yourself.</p><ul class=\"cards\">{items}</ul>")


def contact_inner():
    cats = "".join(f"<li><strong>{e(l)}</strong> — {e(d)}</li>" for l, d in CONTACT)
    return f"""<h1>Contact</h1>
<p class="lede">FLogo Generator is maintained by a single developer, so every message is read directly — there's no
support ticket system or automated reply. Pick the category that fits best and write to the address below.</p>
<h2>What kind of message is this?</h2><ul>{cats}</ul>
<h2>Email directly</h2><p><a href="mailto:{e(EMAIL)}">{e(EMAIL)}</a></p>
<p>This is a side project maintained in spare time, so replies aren't instant — but every message does get read.
For bug reports, including your browser and the platform(s) you selected helps a lot.</p>"""


def json_ld(route, title, desc, article=None):
    blocks = []
    if article:
        blocks.append({"@context": "https://schema.org", "@type": "Article", "headline": article["title"],
                       "description": article["excerpt"], "url": ORIGIN + route,
                       "publisher": {"@type": "Organization", "name": SITE}})
    crumbs = [("Home", "/")]
    if route.startswith("/guides/"):
        crumbs += [("Guides", "/guides"), (title.split(" · ")[0], route)]
    elif route != "/":
        crumbs += [(title.split(" · ")[0], route)]
    blocks.append({"@context": "https://schema.org", "@type": "BreadcrumbList", "itemListElement": [
        {"@type": "ListItem", "position": i + 1, "name": n, "item": ORIGIN + (r if r != "/" else "/")}
        for i, (n, r) in enumerate(crumbs)]})
    return "\n".join(f'<script type="application/ld+json">{json.dumps(b, ensure_ascii=False)}</script>' for b in blocks)


BOOT_SCRIPT = ""


def full_page(route, inner, article=None):
    title, desc = (ROUTES[route] if route in ROUTES else
                   (f"{article['title']} · {SITE}", article["excerpt"]))
    url = ORIGIN + (route if route != "/" else "/")
    return f"""<!DOCTYPE html>
<!-- GENERATED by tool/prerender.py from lib/data/*.dart — do not edit by hand. -->
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
  <meta name="theme-color" content="#0A0D14">
  <title>{e(title)}</title>
  <meta name="description" content="{e(desc, quote=True)}">
  <link rel="canonical" href="{url}">
  <meta property="og:type" content="{'article' if article else 'website'}">
  <meta property="og:title" content="{e(title, quote=True)}">
  <meta property="og:description" content="{e(desc, quote=True)}">
  <meta property="og:url" content="{url}">
  <meta property="og:site_name" content="{SITE}">
  <meta property="og:image" content="{ORIGIN}/icons/Icon-512.png">
  <meta name="twitter:card" content="summary">
  <meta name="google-adsense-account" content="ca-pub-7777887209744733">
  <base href="/">
  {json_ld(route, title, desc, article)}
  <link rel="manifest" href="manifest.json">
  <link rel="icon" type="image/png" href="favicon.png">
  <link rel="apple-touch-icon" href="icons/Icon-192.png">
  <link rel="stylesheet" href="seo.css">
</head>
<body>
{wrap_main(inner)}
{BOOT_SCRIPT}
<script src="flutter_bootstrap.js" async></script>
</body>
</html>
"""


# --------------------------------------------------------------------------
# Write files
# --------------------------------------------------------------------------
def write(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")
    print("wrote", path.relative_to(ROOT))


def patch_index():
    """Inject the homepage content into the Flutter index.html template."""
    idx = WEB / "index.html"
    src = idx.read_text(encoding="utf-8")
    block = ("<!-- SEO_CONTENT_START (generated by tool/prerender.py) -->\n"
             + wrap_main(home_inner()) + "\n" + BOOT_SCRIPT + "\n<!-- SEO_CONTENT_END -->")
    if "<!-- SEO_CONTENT_START" in src:
        src = re.sub(r"<!-- SEO_CONTENT_START.*?<!-- SEO_CONTENT_END -->", lambda m: block, src, flags=re.S)
    else:
        # First run: replace the "Loading…" div and the <noscript> fallback.
        src, n = re.subn(r'<div id="loading">.*?</div>\s*', "", src, count=1, flags=re.S)
        src, m = re.subn(r"<!--\s*Fallback content for crawlers.*?</noscript>", lambda _: block, src, count=1, flags=re.S)
        assert n == 1 and m == 1, "index.html layout changed; update patch_index()"
        src = src.replace("</head>", '  <link rel="stylesheet" href="seo.css">\n</head>', 1)
    idx.write_text(src, encoding="utf-8")
    print("patched web/index.html")


def main():
    patch_index()
    write(WEB / "about.html", full_page("/about", legal_inner(
        "About FLogo Generator", ROUTES["/about"][1], ABOUT)))
    write(WEB / "user-guide.html", full_page("/user-guide", legal_inner(
        "User Guide", ROUTES["/user-guide"][1], GUIDE)))
    write(WEB / "privacy-policy.html", full_page("/privacy-policy", legal_inner(
        "Privacy Policy", ROUTES["/privacy-policy"][1], PRIVACY)))
    write(WEB / "terms.html", full_page("/terms", legal_inner(
        "Terms & Conditions", ROUTES["/terms"][1], TERMS)))
    write(WEB / "contact.html", full_page("/contact", contact_inner()))
    write(WEB / "guides.html", full_page("/guides", guides_inner()))
    for a in ARTICLES:
        write(WEB / "guides" / f"{a['slug']}.html", full_page(f"/guides/{a['slug']}", article_inner(a), a))
    total = sum(len(" ".join(p).split()) for a in ARTICLES for _, p in a["sections"])
    print(f"done — {len(ARTICLES)} articles, ~{total} article words")


if __name__ == "__main__":
    main()
