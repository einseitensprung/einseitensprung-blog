# Einseitensprung Journal

Ein handgebauter Onepager, der den Look und die Themen von [einseitensprung.at/blog](https://einseitensprung.at/blog/) auf eine einzige Seite destilliert: ein Journal-Feed der letzten Posts, eine `whoami`-Sektion und eine Siegel-Reihe mit den echten Qualitätsmerkmalen des Original-Blogs (WCAG AAA, DSGVO-konform, cookie-frei, handgefertigt).

**🔗 Live-Preview:** https://einseitensprung.github.io/einseitensprung-onepager/

## Design

- **Farben** — das echte Marken-Plum/Magenta des Blogs (`#8e1963` / `#bc2184`), aus dem Original-Stylesheet extrahiert, plus die Tag-Akzentfarben als Kategorie-Coding
- **Typografie** — Josefin Sans (Display) + Inconsolata (Fließtext), das originale Font-Pairing des Blogs, bewusst als durchgängiger Terminal-/Code-Look übernommen
- **Struktur** — ein Journal-Feed im Git-Log-Stil: eine Datumsschiene mit farbcodierten Knoten statt generischer Nummerierung, dazu Tag-Chips pro Eintrag
- **Barrierefreiheit** — sichtbare Fokus-States, `prefers-reduced-motion` respektiert, Light-/Dark-Mode über CSS-Tokens

## Struktur

```
index.html   – die komplette Seite (Single-File, keine Build-Schritte)
```

## Lokal ansehen

```bash
# einfach im Browser öffnen
open index.html   # macOS
start index.html  # Windows
```

Kein Build, kein Backend, keine Abhängigkeiten außer den Google-Fonts-Links.

## Hinweis

Dies ist ein inoffizieller Fan-Onepager basierend auf öffentlich einsehbaren Inhalten von einseitensprung.at/blog. Für den vollständigen Blog, Kontakt und Newsletter siehe das Original.
