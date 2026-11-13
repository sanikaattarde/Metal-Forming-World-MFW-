# MFW Inputs and Delay Record: Metal Forming World (MFW) Mobile Application

| Field | Detail |
|---|---|
| File | `Documentation/MFW_INPUTS_RECORD.md` |
| Task | MOD20-P2-T04, track MFW inputs and delay notices. The task is Sanika Attarde's, who holds the contact with MFW (CH section 14). This record is prepared by Yuvraj Gaykhe |
| Version | 0.1 |
| Status | Draft for review. **A dated record, not a notice.** No delay notice has been sent and no schedule change has been raised (section 4). It approves nothing, and no date in the plan is changed |
| As of | 14 November 2026 (a Saturday) |
| Baseline | The Charter dates (CH section 12), which are the working baseline under DEC-017 and stay PROVISIONAL (C-08). The S1 and S2 dates are in section 3 beside them |
| Source of what has arrived | Yuvraj Gaykhe, in chat, 14 November 2026, and the repository records named in the table. Nothing in this record is filed from MFW: every "reported" entry rests on that report. Dates that were not given are not guessed |

## 1. How days late are counted

Working days are Monday to Friday. They run from the day after the due date to the day the input arrived, or to 14 November 2026 if it has not. Public holidays are not taken out, so a count can be one or two days high. The due dates are the Charter's. S2, as recorded in `DECISION_LOG.md` DEC-017, says the developer tells MFW in writing as soon as a delay is expected and moves later dates by one working day for each working day a key input is late. A schedule change is raised for a delay over five working days (CHG-11).

## 2. The inputs

| Input | Due (Charter) | Arrived | Working days late | Over five days | Source and status |
|---|---|---|---|---|---|
| Named approver and deputy; signed or accepted S1 and S2 | Before 21 October 2026 | **Reported received, date not given.** Signed or accepted copies were reported held on 27 October 2026 (OQ-28) | Not known | Not known | Reported by Yuvraj Gaykhe, not filed. The repository copies of S1 and S2 are unsigned. Which of the two people holds which role is not stated. OQ-28 stays OPEN until it is filed |
| The S3 emails, or MFW's written confirmation of each amendment | Before M2 (4 November 2026) | **Reported received, date not given** | Not known | Not known | Reported by Yuvraj Gaykhe, not filed (DEC-019, OQ-29). The amendments stay PROVISIONAL until the emails are filed or MFW confirms in writing |
| Logo file | 21 October 2026 | Recorded in `inputs/README.md` on 7 November 2026. The date MFW sent it is not recorded | At most 12 | At most yes | `inputs/README.md` (DEP-02). MFW's approval to keep the logo in the repository is reported, not filed (`DECISION_LOG.md` DEC-024, exception of 14 November 2026) |
| Brand colours and fonts | 21 October 2026 | **Not supplied as files.** MFW directed the team to use its website's colours and fonts (reported by Yuvraj Gaykhe on 8 November 2026) | 12 if the direction counts as the delivery | See text | `BRAND_REFERENCE.md`; OQ-63 stays OPEN |
| Written confirmation that MFW owns or may use the content | 21 October 2026 | **Not received** | 17 | Yes | Reported by Yuvraj Gaykhe on 14 November 2026 |
| Two to three sample PDFs, including the largest expected issue | 28 October 2026 | Three issues, recorded in `inputs/README.md` on 7 November 2026. The date MFW sent them is not recorded | At most 7 | At most yes | `inputs/README.md` (DEP-03). Kept outside Git (DEC-024) |
| WordPress site address, API confirmation and the news categories | 28 October 2026 | **Not received as a set.** The website link was shared (reported on 8 November 2026) and is the source of the colours and the news menu | 12 | Yes | Reported by Yuvraj Gaykhe, 14 November 2026. The confirmation that the API stays open to the app is not given (OQ-39) |
| A cloud project in MFW's name with billing switched on | 28 October 2026 | **Not received** | 12 | Yes | Reported by Yuvraj Gaykhe, 14 November 2026 (OQ-40) |
| Apple Developer Program and Google Play accounts in MFW's name | Active by 18 November 2026 | **Not received** | Not yet late: due in 3 working days | No | Reported by Yuvraj Gaykhe, 14 November 2026 (OQ-42) |
| Privacy policy and terms of use at a public address | 18 November 2026 | **Not received** | Not yet late: due in 3 working days | No | Reported by Yuvraj Gaykhe, 14 November 2026 |
| Launch content: the latest issue and four to six archive issues, with details | 18 November 2026 | **Not received** | Not yet late: due in 3 working days | No | Reported by Yuvraj Gaykhe, 14 November 2026 |
| Admin user list and store listing text | 18 November to 2 December 2026 | Not asked in this check | Not yet late | No | Nothing reported |
| Review by MFW's legal adviser of the collection of age | Before the profile is built (M3, 18 November 2026) | Not asked in this check | Not yet late | No | Nothing reported (OQ-07) |
| Testers from MFW's team | From 2 December 2026 | Not due | Not yet late | No | None |
| MFW's decisions on the open questions | By milestone, as the specification proposes | Open | Not counted | Not counted | `OPEN_QUESTIONS.md`. The drafts of `MFW_REQUEST_DRAFTS.md` ask for them |

## 3. The same dates on the S1 and S2 reading

S1 and S2 give kickoff as 16 November 2026 and store submission as 8 January 2027. On that reading, no input listed above is late yet: the S1 timings are relative to kickoff (end of week 1, week 4 and weeks 5 and 6). The conflict between the two readings is DEC-017 (C-08) and stays OPEN.

## 4. Delay notices

| Item | State |
|---|---|
| Delay notice to MFW | **Not sent** |
| Schedule change under CHG-11 | **Not raised** |
| Why | Yuvraj Gaykhe decided on 27 October 2026 to send MFW no delay notice and to take no action on the M2 date (`DECISION_LOG.md` DEC-017). The task asks both developers to revisit that decision. Yuvraj Gaykhe, asked on 14 November 2026, **keeps the decision**. The position of Sanika Attarde is not filed |
| Accepted as a risk | R7 and R15 |

Four inputs are over five working days late on the Charter reading: the content ownership confirmation (17), and the WordPress details, the cloud project and the brand colours and fonts if the website direction does not count (12 each). The logo and the sample PDFs arrived over five days late on that reading too, by the dates they were recorded. This record states those facts. It does not send a notice or move a date.

## 5. What would change this record

- MFW's written confirmation of what has arrived, with dates (then the "reported" entries are filed).
- A decision by both developers to send a notice, which is a separate action for Yuvraj Gaykhe or Sanika Attarde to take. The text of a notice can be added to `MFW_REQUEST_DRAFTS.md` on request.
- The cloud project, the WordPress confirmation or the store accounts arriving, which closes a row.
