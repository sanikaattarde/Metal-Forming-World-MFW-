# Yuvraj Gaykhe's Decision Positions, 14 November 2026

| Field | Detail |
|---|---|
| File | `Documentation/YUVRAJ_DECISION_POSITIONS.md` |
| Task | MOD20-P1-T01, written agreement on the PROPOSED engineering decisions. The task is Sanika Attarde's. This note is the part that Yuvraj Gaykhe prepared, and Sanika Attarde's part is still to come |
| Version | 0.1 |
| Status | Draft for review. **A written note of one developer.** It is Yuvraj Gaykhe's side of the evidence in `DECISION_LOG.md` section 3.1. It changes no status in `DECISION_LOG.md`: an entry moves to AGREED in a later edit, once both notes are filed. It records no MFW approval |
| Date | 14 November 2026 |
| Source of the positions | Yuvraj Gaykhe, in chat, 14 November 2026, one decision at a time, recorded at their instruction |

## 1. The entries of the task that are already AGREED

The task lists DEC-010 to DEC-015, DEC-022 and DEC-024 to DEC-030. Each is AGREED in `DECISION_LOG.md`, with its evidence filed there. Checked on 14 November 2026 against `main`.

| Entries | Where the evidence is |
|---|---|
| DEC-010 to DEC-015, DEC-022 (with the cost), DEC-024 | Section 5.6, with both developers' notes (sections 5.4 and 5.5) and the approving review of pull request #12. DEC-010 changed on 10 November 2026 (section 5.12). The cost of DEC-022 is section 5.9 |
| DEC-025 to DEC-030 | Section 5.8, with the notes of sections 5.4 and 5.7 and the approving review of pull request #42 |

So the acceptance line of the task ("AGREED with a link to the evidence, or stays PROPOSED with the objection written down") holds for every listed entry. No objection is recorded on any of them.

## 2. Positions on the entries that are not yet AGREED

| Entry | Position of Yuvraj Gaykhe | Condition or limit | Still needed |
|---|---|---|---|
| DEC-001 Decision log as the CH section 17.4 record | **Accepts** option (a): `DECISION_LOG.md` in the repository, reviewed with the code and moved to MFW with the repository | None | Sanika Attarde's written note or approving review |
| DEC-021 News retrieval path | **Accepts** option (a): the app reads MFW's WordPress REST API directly and applies the news controls (hidden, breaking) from the backend, as S2 says. The WordPress client stays behind an interface, so option (b), a backend proxy or cache, stays possible | The live read of MFW's site (MOD09-P1-T01, OQ-39) may show a reason to change | Sanika Attarde's note. Risk R5 stays |
| DEC-031 Data location | **Proposes to MFW** Mumbai (asia-south1) for the database, the functions and the PDF bucket (GS-Q52). This is a proposal, not a decision | A Mumbai bucket has no free download allowance, so egress is billed from the first byte (`CLOUD_INFRASTRUCTURE_AND_COSTS.md` section 10). Whether the Firebase console offers Mumbai for each service is NOT VERIFIED, and is checked before anything is created. A location cannot be changed after creation | MFW's written decision, with its legal adviser for personal data (OQ-41). The entry stays OPEN |
| DEC-032 Subscriber list and the edition-update sign-up | **Accepts** option (a), now with a date: one CSV export of registered readers with their profile fields, and no edition-update sign-up. This replaces the earlier report of agreement that gave no date | The sign-up is a deliverable of S1 and S2, so dropping it needs MFW's written agreement (OQ-31). Until then FR-EMAIL-001, FR-USER-001 and DATA-010 stay CONFLICT | Sanika Attarde's written note or approving review. MFW's written agreement |
| DEC-033 Reading and downloading | **Accepts** the two-action model: Read opens a temporary complete copy removed when the reader leaves, and Download keeps a copy until the reader deletes it. **Decides the two points the entry left open** (below) | The two decisions are Yuvraj Gaykhe's position. They are not yet in `PDF_READER_AND_OFFLINE_DESIGN.md`. MFW's answer on keeping a copy is still reported and not filed (OQ-08) | Sanika Attarde's note. MFW's filed answer to OQ-08. The change to the reader design |

**The two points of DEC-033.**

1. **A reader leaves while Read is still downloading.** The download is cancelled, and the partial file is removed. Nothing is kept and nothing is listed.
2. **A reader taps Download while a temporary copy is open.** The open copy is converted into a kept copy. The file is not downloaded a second time.

## 3. Positions recorded earlier, for completeness

| Entry | Where |
|---|---|
| DEC-005 PDF reader library | `DECISION_LOG.md` DEC-005: pdfrx, behind `PdfRenderer` so it can change (10 November 2026). The entry stays OPEN until Sanika Attarde writes a position and MFW approves at M2 |
| DEC-006 | Working default of 27 October 2026, in the entry. MFW's confirmation (OQ-29, OQ-06) is needed |
| DEC-023 | `DECISION_LOG.md` section 5.10 and 5.11. AGREED as an internal position, and MFW's approval is still needed (OQ-40) |

## 4. What this note does not do

- It does not set any entry to AGREED, APPROVED or any other status.
- It does not cover DEC-007, DEC-008, DEC-016 to DEC-019, which wait for MFW's written answers.
- Step 4 of the task, filing references to the S3 emails and the signed S1 and S2, is not done here. It is for Sanika Attarde, who holds the contact with MFW (CH section 14).

## 5. What is needed next

Sanika Attarde's written note or approving review for DEC-001, DEC-021, DEC-032 and DEC-033. Then a follow-up edit to `DECISION_LOG.md`, as sections 5.6 and 5.8 did, that cites both notes. The DEC-033 points go to the reader design in the same follow-up.
