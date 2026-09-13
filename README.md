# PhD interview presentation

A Quarto reveal.js deck styled to match the
[BiodivPond](https://biodivpond.github.io/) site theme.

## Render

Quarto is installed at `%LOCALAPPDATA%\Programs\Quarto\bin\quarto.cmd` (not on PATH).

```powershell
& "$env:LOCALAPPDATA\Programs\Quarto\bin\quarto.cmd" render          # -> docs/index.html
& "$env:LOCALAPPDATA\Programs\Quarto\bin\quarto.cmd" preview index.qmd   # live reload
```

Export to PDF: open the deck in Chrome, append `?print-pdf` to the URL, then print
to PDF with background graphics enabled.

## Files

| Path | Purpose |
|---|---|
| `index.qmd` | The deck — 13 slides, ~10 minutes |
| `theme/biodivpond.scss` | Theme ported from the site's `styles.css` + `colors.json` |
| `images/` | Logos and photographs; `colek.jpg`, `logo-aopk.svg` and `biodivpond_header_crop.png` are unused |
| `docs/` | Render output (gitignored, except the committed `docs/index.html`) |

## Sources

Every factual claim in the deck traces to one of these. Nothing else was added.

| Source | Used for |
|---|---|
| `topic.md` | Project title, aims, outputs, conventional method list |
| `270023G_Investigation.docx.md` | MSci slides — species, study area, model, results, the host-ant omission |
| `BiodivPond workplan_updated.pdf` | Pond numbers, core-pond design, ddPCR, PAM, ring test, budget, partner network, coordination role |
| Hypotheses as stated by the author | H1, H1b, H2, H3, H3b |
| PROSPECTIVE LIFE action plans as stated by the author | *Epidalea calamita*, *Lissotriton montandoni* |

### Discrepancies to resolve

- **Pond count** — the deck uses **560** (60 core + 500 citizen science). The workplan
  §3.2 and §4.1 read 80 core ponds; confirm which figure is current before the talk.
- **Trapping method** — the deck says *umbrella trapping*, `topic.md` says *funnel
  trapping*. Pick one and use it in both.
- **BiodivPond timeline** — workplan §4.3 reads "30 months from January 1st 2026, to
  June 30th 2027", but 30 months from January 2026 ends June 2028, and the Gantt runs
  into 2028 Q2. No dates are shown on the slides because of this.

## Theme reference

Palette taken from the BiodivPond site:

| Token | Hex | Used for |
|---|---|---|
| `$bp-green` | `#4C7D31` | Headings, links, title slide, dividers |
| `$bp-green-light` | `#CCE0B3` | Heading rules, chips, subtitle |
| `$bp-white` | `#FCFCFA` | Slide background |
| `$bp-black` | `#393947` | Body text |
| `$bp-blue` / `$bp-red` / `$bp-yellow` / `$bp-brown` | from `colors.json` | Callout cards |

### Classes available in `index.qmd`

- `::: {.card-green}` — also `card-blue`, `card-red`, `card-yellow`, `card-brown`.
  Tinted callout box with a coloured left bar (the site's `.callout-red` pattern).
- `::: {.map-card}` — solid green panel with white text (the site's `.map-card`).
- `## Slide title {.divider}` — full-green section-break slide.
  Add `::: {.divider-sub}` inside for the subtitle line.
- `[text]{.chip}` — rounded green pill, for data sources and methods.
- `[text]{.todo}` / `::: {.todo-block}` — **yellow placeholder markers.**
- `.small`, `.fine`, `.muted`, `.accent` — type helpers.
- `[text]{.hyp}` — dark-green hypothesis badge; `[n]{.strand-num}` — numbered circle
  for the three research strands.
- `## Title {.tight}` — steps that slide's top-level body text down to 0.92em, for a
  slide whose copy would otherwise run into the footer.
- `::: {.logo-row}` — centred, evenly spaced logo strip.

## Before the interview

The deck is content-complete — no `.todo` placeholders remain. If you add any while
editing, they render in loud yellow on purpose, so nothing can be missed on screen:

```powershell
Select-String -Path index.qmd -Pattern 'todo'
```

Still worth a last pass: the discrepancies listed above, and the date in the YAML
header (`date: 09/16/2026`).


### Apparent typos noticed in the thesis text

None of these reach the slides, since the MSci section no longer carries study-area or
parameter detail — but they are worth correcting in the thesis itself:

- Mean annual precipitation given as **7980 mm** for Křivoklátsko (implausible).
- Record filter written as "recent (< 2009) findings", but the next sentence says only
  data from 2009–2021 entered the analysis.
- The 95-percentile interval for *b1* is printed as [−0.00116, −0.00269] — bounds
  reversed.

Speaker notes (`::: {.notes}`) record **which source each slide's content came from**,
so any claim can be traced back. Press `S` in the browser for the presenter view.
