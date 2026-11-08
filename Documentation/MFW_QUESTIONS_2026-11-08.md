# MFW Questions of 8 November 2026: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | MFW Questions of 8 November 2026 |
| File | `Documentation/MFW_QUESTIONS_2026-11-08.md` |
| Phase | 3: Development Planning and Collaboration. A request for MFW's written answers |
| Version | 0.1 |
| Status | Draft for review. **Not sent.** It asks five questions and records no answer. It approves nothing and changes no status label. |
| Date | 8 November 2026 |
| Prepared by | Yuvraj Gaykhe (WS-B) |
| Sent by | Not sent. Decisions go to MFW's approver through the contracting developer, Sanika Attarde (`DECISION_LOG.md` section 4, step 4; CH §14). Who sends this pack, and when, is settled in the review of the pull request that adds it. |
| Approval required | Both developers, before it is sent |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 8 November 2026 | First version: five questions that only MFW can answer, each with the decision it unblocks, the team's working position and the answer that is needed. |

### 1.1 Related documents

| Document | Status |
|---|---|
| `OPEN_QUESTIONS.md` OQ-08, OQ-11, OQ-26, OQ-35, OQ-40 | Exist, draft. The questions below, in the register's words |
| `DECISION_LOG.md` DEC-003, DEC-008, DEC-023, DEC-024, DEC-033, sections 3.1 and 5.10 | Exist, draft. The decisions that wait for these answers and what counts as MFW's approval. Section 5.10, Yuvraj Gaykhe's positions of 8 November 2026, comes with pull request #51, under review |
| `TESTING_STRATEGY.md` §13 | Exists, draft. Large media go in an MFW-approved place, which does not exist yet |
| `inputs/README.md` | Exists. MFW's logo and three sample issues are recorded there by size and SHA-256. The files are not in Git |

## 2. How This Pack Is Used

1. **One email.** The five questions fit in one email to MFW's approver (section 5). An email reply is enough for an approval (S2 Responsibilities, `DECISION_LOG.md` section 3.1).
2. **Nothing of MFW's is attached.** The pack asks about decisions. It attaches no MFW file and no image of an MFW page (DEC-024).
3. **Answers are filed.** Each answer is recorded in `OPEN_QUESTIONS.md` and, where a decision waits for it, in `DECISION_LOG.md`, with the sender, the date and the wording that decides. A question stays OPEN until its answer is filed (section 4).
4. **A partial answer is still useful.** MFW can answer the questions one at a time. Each is independent.

## 3. The Five Questions

| No. | Question | Register | Decision it unblocks | What waits for it |
|---|---|---|---|---|
| Q1 | When a reader opens an issue, is the copy kept afterwards? | OQ-08, OQ-11 | DEC-008, DEC-033 | The reader and Downloads design, T-06.5, AC-4.2 |
| Q2 | Is the Firebase architecture of the statement of work kept? | OQ-35 | DEC-003 | Every backend task, the M1 note, QG-14 |
| Q3 | Will MFW provide a separate test project? | OQ-40 | DEC-023 | ENV-TEST, T-01.3, T-01.4, the integration tests |
| Q4 | Where may the sample PDFs and the reader test recordings be kept? | DEC-024 condition; `TESTING_STRATEGY.md` §13 | DEC-024 (its open condition) | T-02.3 on the test phones, AC-2.1 evidence |
| Q5 | Which phones and versions must the app be tested on? | OQ-26 | None. It sets the device list | AC-10, the T-02.3 phone run, release settings |

## 4. Each Question, With the Team's Position

### Q1 Reading and downloading (OQ-08, OQ-11)

**The question.** When a signed-in reader opens a full issue, should the app keep the copy on the phone afterwards?

**Why we ask.** Two answers have been reported to the team, and they differ. Neither is in writing (`DECISION_LOG.md` DEC-008). The reader and the Downloads screen are designed around the answer.

**The options.**

- **A. Two actions (the team's working position).** Read downloads the whole issue, opens it, and removes it when the reader leaves. Download does the same and keeps the copy for offline reading until the reader deletes it.
- **B. One action.** Opening an issue downloads it and keeps it until the reader deletes it.

In both, the reader waits for the whole file before the first page opens. Reading before the download finishes is out of scope (S2 "Scope not included").

**Also, for a kept copy (OQ-11).** Please confirm or change these four rules:

1. When the reader signs out, the copy is hidden until the same reader signs in again.
2. When the reader deletes their account, the copy is removed.
3. When MFW unpublishes the issue, the copy stays on the phone.
4. When MFW deletes the issue permanently, the copy is removed the next time the app is online.

**The answer needed.** A or B, and the four rules confirmed or changed, in writing.

### Q2 The backend platform (OQ-35)

**The question.** Does MFW keep the architecture that the statement of work proposes: Firebase Authentication, Cloud Firestore, Cloud Storage for Firebase, Cloud Functions, Firebase Cloud Messaging, and Firebase Crashlytics and Analytics, in MFW's own Firebase project?

**Why we ask.** The charter says that the architecture is not approved yet (CH §11 and §17.4), and no backend code is written as final until it is. The statement of work names Firebase in milestone M3 and in AC-12.

**The team's position.** Yuvraj Gaykhe's written position is Firebase, as the statement of work proposes (`DECISION_LOG.md` section 5.10). Sanika Attarde's written position is not filed yet, so the decision is still OPEN. Before this question is sent, either both positions are filed, or the email says that the team is checking that MFW still expects Firebase.

**The answer needed.** Yes, or the change MFW wants. The M1 requirements and architecture note asks for MFW's formal approval later. This answer does not replace it.

### Q3 A separate test project (OQ-40)

**The question.** Will MFW create a second Firebase project, separate from the live one, for testing, and give both developers access to it?

**Why we ask.** Tests run with made-up readers and files only, never real readers' data (DEC-024). A separate project keeps test data and test mistakes away from the live service. Cloud usage is billed to MFW (S1 Costs outside the fee).

**The team's position.** Three environments: the developers' machines (ENV-LOCAL), a test project in MFW's name (ENV-TEST) and the live project (ENV-PROD) (`DEPLOYMENT_PLAN.md` section 4). Yuvraj Gaykhe accepts it in writing (`DECISION_LOG.md` section 5.10). Sanika Attarde's position is not filed yet. The cost of a second project is not estimated in the repository.

**The answer needed.** Yes or no, in writing. If yes: who creates it, and access for both developers.

### Q4 Where the sample PDFs and recordings may be kept

**The question.** Where may the team keep (a) MFW's sample issue PDFs, and (b) screen recordings of the reader test, which show MFW's pages?

**Why we ask.** The code repository is public, so neither goes there (DEC-024). The reader test on the phones (T-02.3) uses the three sample issues MFW sent, and AC-2.1 is measured with a screen recording. Until MFW names a place, the copies stay on the developers' machines and test phones. The team records that as a working position, not a decision.

**The options.**

- **A.** A folder that MFW owns, for example a shared drive, with access for both developers.
- **B.** Only on the developers' machines and test phones, deleted at handover.
- **C.** Another place that MFW names.

**The answer needed.** A, B or C, in writing, and for A the folder and who gives access.

### Q5 Test phones and versions (OQ-26)

**The question.** Which phones, and which oldest Android and iOS versions, must the app be tested on? Which browsers must the admin panel support?

**Why we ask.** The acceptance tests run on an agreed device list (S2 AC-10). The team has a mid-range Android phone and a current iPhone. It has no low-cost Android phone, no older iPhone and no tablet (GS-Q54). Today the app builds with Flutter's default minimum versions (iOS 15.0 and Flutter's Android default), which is not a decision.

**The answer needed.** The device list and the oldest versions, in writing. If MFW wants a phone tested that the team does not have, who provides it.

## 5. Text for the Email (PROPOSED)

The text below is a draft for the sender. It is not sent by this document.

```text
Subject: MFW app: five questions for your written answer

Dear <MFW approver>,

To keep the build moving, we need your written answers to five questions.
A reply to this email is enough. You can answer them one at a time.

1. Reading and downloading. When a reader opens an issue, should the app
   (A) open a temporary copy that is removed when they leave, with a
   separate Download button that keeps a copy for offline reading, or
   (B) keep every opened issue until the reader deletes it?
   Please also confirm, for a kept copy: hidden on sign-out until the
   same reader signs in again; removed when the account is deleted;
   kept when you unpublish the issue; removed when you delete the issue
   permanently.

2. Backend. Do you keep the Firebase architecture in the statement of
   work, in MFW's own Firebase project?

3. Test project. Will MFW create a second Firebase project for testing,
   separate from the live one, and give both developers access? Its
   usage would be billed to MFW.

4. Storage of your samples. Where may we keep your sample issue PDFs and
   screen recordings of the reader test? Our repository is public, so
   they are never put there. Options: a folder you own and share with
   us; only our machines and test phones, deleted at handover; or a
   place you name.

5. Devices. Which phones and oldest Android and iOS versions must we
   test on, and which browsers must the admin panel support? We have a
   mid-range Android phone and a current iPhone.

Thank you,
<sender>
```

## 6. After the Answers

1. File each answer as `DECISION_LOG.md` section 3.1 asks: the sender's name, the date, and the words that decide.
2. Update the question in `OPEN_QUESTIONS.md` to ANSWERED, and the decision it unblocks, in a documentation pull request with a `CHANGELOG.md` entry.
3. Q2 and Q3 also need both developers' written positions before DEC-003 and DEC-023 can be AGREED.
4. For Q4 option A, move the local copies there and record the move in `inputs/README.md`.
