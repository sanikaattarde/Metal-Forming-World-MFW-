# Inputs from MFW

Files and links supplied by MFW (the client) for the project. First added on 7 November 2026.

## These files stay out of Git

The repository is public. MFW's sample PDFs are confidential (statement of work, Key terms, Confidentiality; DEC-024; `Documentation/TEST_DATA_AND_FIXTURES.md`). The root `.gitignore` ignores every PDF outside `Documentation/`, so the PDFs below are on the machine that holds them and are never committed. Do not attach them to an issue or a pull request, and do not share them outside the team.

Where MFW approves keeping its samples is still open (DEC-024). Until MFW answers, each developer keeps a local copy in this folder, and this index lets a copy be checked.

Test fixtures stay synthetic. These files are for local reading and layout checks only (FX-PDF-03 and FX-PDF-04).

One exception: MFW approved keeping its logo in the repository (reported by YG on 14 November 2026, a WhatsApp message from MFW, not filed; `Documentation/DECISION_LOG.md` DEC-024). The app holds an RGB picture made from the logo file, `app/assets/brand/mfw_logo.png`. The logo PDF itself stays out of Git like the others.

## Files

Size is in bytes. To check a copy, run `shasum -a 256` on the file and compare it with the value here.

| Folder | File | Size | SHA-256 | What it is |
|---|---|---|---|---|
| `brand/` | `Metal Forming Logo-1.pdf` | 1267921 | `9f847ee8ed829f67bdf7ba3326ac857251d64bda29ce328ee6ab6cc982f666ae` | The logo, as supplied (DEP-02). Brand colours and fonts were not in this set. |
| `sample-issues/` | `MFW - APR-MAY 26_Final 2.pdf` | 7718362 | `9fed01e57a5e17e21488e8c2a08b11b40959537e317cdb40eb6bfc570d737a07` | The April-May 2026 issue (DEP-03). |
| `sample-issues/` | `MFW AUG-SEPT 2026_Revised.pdf` | 14877909 | `b4a13661e2c14af2b68d0baa607323dccba34b606575870605793462228d2541` | The August-September 2026 issue (DEP-03). |
| `sample-issues/` | `MFW - Oct-Nov 2026 issue_Final.pdf` | 8421554 | `6f994017eb0fad052429077fa422694fdecd38640b1a6138c5ffd08edfeca09b` | The October-November 2026 issue (DEP-03). |

## Links

| Link | What it is |
|---|---|
| https://metalformingworld.com/ | MFW's official website, which MFW has shared (reported by YG on 8 November 2026, not filed) as the reference for the colours, the fonts and the news (DEP-02, DEP-04). A link only: nothing from the site is stored. |
| https://metalformingworld.com/june-july-2026-issue/ | The June-July 2026 issue page on MFW's website. A link only: nothing from the page is stored. The page text showed no link to a PDF file, so no June-July PDF is held here. |

## Adding an input

Put the file in a folder here that names its kind, add a row above with its size and SHA-256, and check that `git status` does not list a PDF. The folder holds only what MFW supplied, never a file made by the team.
