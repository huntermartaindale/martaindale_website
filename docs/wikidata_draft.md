# Wikidata entry — draft and walkthrough

Wikidata is a free knowledge base that powers Google's Knowledge Panels, voice assistants, and many AI tools. Having an entry for yourself is the second-biggest single factor for getting a Google Knowledge Panel — after a Wikipedia article, which has a much higher bar. The notability requirement for Wikidata is much lower; for academics, having an ORCID and published peer-reviewed work is almost always enough.

This draft contains everything you need. Pick one of the two paths below.

---

## Step 0 — One-time account setup (~2 minutes)

If you don't already have a Wikipedia/Wikidata account:

1. Go to https://www.wikidata.org/wiki/Special:CreateAccount
2. Pick a username (it will be public; many academics use their real name)
3. Verify your email

You only do this once. The same account works on Wikipedia, Wikidata, and all sister sites.

---

## Path A (Recommended): Use QuickStatements (~3 minutes after account setup)

QuickStatements is a tool that creates an entire item from one block of text. Faster than clicking through the web UI 20 times.

1. Go to https://quickstatements.toolforge.org/
2. Click "Log in" (top right) and authorize with your Wikidata account
3. Click "New batch"
4. Paste the block below into the text box (it's already in the correct format)
5. Click "Import" → "Run"

QuickStatements will create the new item, generate a Q-number for you, and apply all statements with the reference URLs attached.

### The block to paste

```
CREATE
LAST	Len	"M. Hunter Martaindale"
LAST	Den	"American criminologist; Director of Research at ALERRT Center, Texas State University"
LAST	Aen	"Hunter Martaindale"
LAST	Aen	"Michael Hunter Martaindale"
LAST	P31	Q5	S854	"https://huntermartaindale.com"
LAST	P21	Q6581097	S854	"https://huntermartaindale.com"
LAST	P106	Q8142883	S854	"https://huntermartaindale.com"
LAST	P106	Q1622272	S854	"https://huntermartaindale.com"
LAST	P108	Q1495387	S854	"https://huntermartaindale.com"
LAST	P69	Q1495387	S854	"https://huntermartaindale.com"
LAST	P101	Q37445	S854	"https://huntermartaindale.com"
LAST	P496	"0000-0002-8100-7698"	S854	"https://orcid.org/0000-0002-8100-7698"
LAST	P1960	"_7PlqKYAAAAJ"	S854	"https://scholar.google.com/citations?user=_7PlqKYAAAAJ"
LAST	P2037	"huntermartaindale"	S854	"https://github.com/huntermartaindale"
LAST	P6634	"hmartaindale"	S854	"https://www.linkedin.com/in/hmartaindale/"
LAST	P856	"https://huntermartaindale.com"	S854	"https://huntermartaindale.com"
LAST	P735	Q16563753
```

### What each line means (in plain English)

| Line | Meaning |
|---|---|
| `CREATE` | Create a new item (Wikidata assigns the Q-number) |
| `Len` | English label — "M. Hunter Martaindale" |
| `Den` | English description — disambiguates from any other Hunter Martaindale |
| `Aen` | English alias — alternate name people search for |
| `P31 → Q5` | Instance of → human |
| `P21 → Q6581097` | Sex or gender → male |
| `P106 → Q8142883` | Occupation → criminologist |
| `P106 → Q1622272` | Occupation → university researcher (fits "Director of Research" + "Associate Research Professor") |
| `P108 → Q1495387` | Employer → Texas State University |
| `P69 → Q1495387` | Educated at → Texas State University |
| `P101 → Q37445` | Field of work → police science |
| `P496` | ORCID iD |
| `P1960` | Google Scholar author ID |
| `P2037` | GitHub username |
| `P6634` | LinkedIn personal profile ID |
| `P856` | Official website |
| `P735 → Q16563753` | Given name → Hunter |
| `S854` | Source/reference URL for the statement above it |

(Family name "Martaindale" is intentionally not in the batch — Wikidata may not yet have an item for it. You can add it manually after creation if you want; Wikidata will offer to create the surname item for you.)

---

## Path B: Use the Wikidata web UI (manual, ~15 minutes)

If you'd rather click through and see what you're doing instead of pasting a block:

1. Go to https://www.wikidata.org/wiki/Special:NewItem
2. **Label (English):** `M. Hunter Martaindale`
3. **Description (English):** `American criminologist; Director of Research at ALERRT Center, Texas State University`
4. **Aliases (English):** `Hunter Martaindale`, `Michael Hunter Martaindale`
5. Click "Create"
6. On the item page, click "+ add statement" and add each of the statements below

### Statements to add

For each statement, click "+ add statement", type the property name (Wikidata auto-suggests), then enter the value. After adding the value, click the small reference icon below the statement and add a reference URL — use `https://huntermartaindale.com` as the source for biographical claims and the relevant profile URL for ID claims (ORCID, Scholar, GitHub, LinkedIn).

| Property | Value | Reference URL |
|---|---|---|
| instance of | human | huntermartaindale.com |
| sex or gender | male | huntermartaindale.com |
| occupation | criminologist | huntermartaindale.com |
| occupation | university researcher | huntermartaindale.com |
| employer | Texas State University | huntermartaindale.com |
| educated at | Texas State University (with qualifier "academic degree" → "Doctor of Philosophy" and "point in time" → 2016) | huntermartaindale.com |
| field of work | police science | huntermartaindale.com |
| ORCID iD | `0000-0002-8100-7698` | orcid.org/0000-0002-8100-7698 |
| Google Scholar author ID | `_7PlqKYAAAAJ` | scholar.google.com/citations?user=_7PlqKYAAAAJ |
| GitHub username | `huntermartaindale` | github.com/huntermartaindale |
| LinkedIn personal profile ID | `hmartaindale` | linkedin.com/in/hmartaindale/ |
| official website | `https://huntermartaindale.com` | huntermartaindale.com |
| given name | Hunter | (no reference needed) |
| family name | Martaindale (skip if Wikidata doesn't have an item for "Martaindale" yet) | (no reference needed) |

---

## After creation — return for the PhD detail

The "educated at" statement is more powerful with the degree and year attached as qualifiers. QuickStatements can do this too, but to keep the initial batch simple, add it after the item exists:

1. Open your new Wikidata item
2. Find the "educated at: Texas State University" statement
3. Click "add qualifier"
4. Add `academic degree` → `Doctor of Philosophy`
5. Add another qualifier: `point in time` → `2016`
6. Save

---

## Optional fields to fill in later

These are all helpful but require info I don't have. Add them when you have a free minute:

- **date of birth (P569)** — even just the year (e.g., `1985`)
- **place of birth (P19)** — city
- **academic dissertation (P1026)** — title of your dissertation, if you remember it offhand
- **doctoral advisor (P184)** — name(s) of your dissertation chair
- **languages spoken (P1412)** — English (`Q1860`); add others if applicable
- **notable work (P800)** — one or two of your most-cited papers
- **work location (P937)** — San Marcos, Texas (`Q49229`)

---

## How long until this affects Google?

Google re-crawls Wikidata fairly regularly. Expect:
- **First few days:** statement appears in your Wikidata page
- **2–6 weeks:** Google's entity graph picks it up; you may start seeing your photo/bio in a "people also search for" sidebar on `huntermartaindale.com` Google searches
- **Months:** if combined with the reciprocal sameAs link work (see `docs/sameas_link_checklist.md`), a Knowledge Panel becomes possible

This isn't an overnight switch — it's adding one more strong signal that anchors your online identity.
