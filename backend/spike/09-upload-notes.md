# Backend spike notes 09: the upload backend

| Field | Detail |
|---|---|
| Branch | `spike/sa-backend-rules` (a spike: not merged to `main`) |
| Date | 3 November 2026 |
| Task | Backend spike for `MOD13-P1-T09` (GAP-02): OP-19 `requestUpload`, OP-20 `listUploadJobs` and OP-40 `onUploadFinalized` from `API_AND_BACKEND_CONTRACT.md`. The backend half of T-09.2, which stays held as a feature |
| Status | Working notes. PROPOSED. Not reviewed. Every result is "emulator only" |
| Rests on | DEC-003 and DEC-020 (OPEN); OQ-21, OQ-22 and OQ-30 (OPEN); GS-Q45 (working position) |

## 1. What was built

| Operation | What it does | Refuses or rejects |
|---|---|---|
| OP-19 `requestUpload` | Admin only. Checks the input, the declared size against `max_upload_bytes`, and that the issue exists. Writes the upload job as pending and returns the job, an upload address and its expiry. A repeat returns the same job | `INVALID_ARGUMENT`, `NOT_FOUND` |
| OP-20 `listUploadJobs` | Admin only. One job, or an issue's jobs newest first, with the status, the reason for a rejection and the revision. The uploader is not shown | `INVALID_ARGUMENT` |
| OP-40 `onUploadFinalized` | Runs for every object in the bucket and acts only on `holding/{job_id}`. Checks the uploader again, the size, and that the bytes are a genuine PDF. Then copies the file to the private area, removes it from the holding area, and in one transaction makes it the current revision (INV-01) | Job rejected with `NOT_A_PDF`, `OVER_LIMIT`, `UPLOADER_NOT_AUTHORISED` or `ISSUE_NOT_FOUND`, and the file removed |

| Part | What it does |
|---|---|
| `pdfCheck.ts` | A file passes only if it starts with `%PDF-`, has `%%EOF` in its last 1,024 bytes, and pdf.js opens it and loads every page, with at least one page. The page count comes from pdf.js. The name and the declared type count for nothing |
| `uploadUrlIssuer.ts` | The interface for the upload address, and a stub. The stub's address ends in `.invalid` and holds no path. Outside the emulators it throws. **The real signed, resumable upload URL is not built** (DEC-020) |
| `pdfjs-dist` 6.4.299 | Installed in `backend/spike/functions` only. Register entry DEP-33 in `DEPENDENCY_REGISTER.md` |

**A replacement** (GS-Q45) becomes the next revision. The old revision is marked superseded and its file is kept. A replacement that fails changes nothing, and readers keep the current revision.

**SEC-CHK-07.** Every object that arrives in the holding area is checked, whatever sent it. One with no pending job is removed: a file put there round the interface, one under a deeper path, and a second file sent to an address already used.

**Not built.** A cover upload and `COVER_INVALID` (OQ-22); a separate rule for protected PDFs (OQ-30); the cleanup that removes orphans and expires stale jobs (OP-41); `RATE_LIMITED` (`MOD13-P1-T07`); deleting a revision (OQ-21); the panel screens (`MOD12-P2-T02`).

## 2. Results

`npm --prefix backend/spike test` on 3 November 2026: **873 tests, 873 passed, 0 failed.** Emulator only.

| Group | Tests | What it shows |
|---|---|---|
| G10 Uploads | 75 | Both callable operations refuse five kinds of caller and write nothing. OP-19's input checks, repeats, a missing issue and an unusable limit. OP-40 end to end through the trigger: a first upload, a replacement, a failed replacement, the boundary, nine kinds of rejected file, the uploader losing standing, the issue deleted, and three files that came round the interface. An accepted file then publishes and reaches a reader through `getIssueFile`. Direct reads refused on the trigger's bucket. OP-20. Then OP-40 called directly, to make a step fail or something change meanwhile |
| U5 PDF check | 22 | Accepted and refused files, the bytes left unchanged, and the upload address stub |
| The rest | 776 | Unchanged |

| Plan test (B2.8) | Result |
|---|---|
| A non-PDF named `.pdf` | `NOT_A_PDF` (FX-PDF-08, and FX-PDF-09, -10, -12, -13) |
| Oversize | `OVER_LIMIT` (FX-PDF-07), whatever size was declared |
| Role removed between request and arrival | `UPLOADER_NOT_AUTHORISED` |
| A valid generated PDF | Accepted. The revision goes up, and the old one is superseded and kept |
| A failure after the move | Leaves an orphan and a pending job. **Its removal is not shown**, because OP-41 is not built (G-10) |
| A reader calling OP-19 | Refused |
| A repeated `request_id` | The same job |
| SEC-CHK-07: a direct upload round the interface | Removed. Every arriving file is checked (section 1) |

**The log.** The run's saved output holds 28 `onUploadFinalized` log lines: 9 accepted, 10 `NOT_A_PDF`, 3 `UPLOADER_NOT_AUTHORISED`, 3 with no pending job, 2 `OVER_LIMIT` and 1 `ISSUE_NOT_FOUND`. None holds a file path, and the stub's address appears nowhere in the output.

**Do the tests catch broken code?** 56 deliberate breaks were tried one at a time, each rebuilt, on clean baselines: OP-19 and OP-20 (20), OP-40 (25), the PDF check (8) and the address stub (3). 52 were caught at first. Two did not compile and were rewritten. Two got through:

| Break | Why it got through | What changed |
|---|---|---|
| The final transaction's checks reduced to "the issue exists" | Creating the record already refuses a revision that exists, so the tests could not tell | Two tests: a job that expires while its file is checked, and an issue whose revision changes meanwhile |
| Pages not loaded, only counted | No file opened and then failed on a page | A file whose page tree points at a missing object |

Those four were then run again, and all were caught. The other 52 were not run again, because the test changes only add cases. Two size tests had already been added while listing the breaks: the store-reported size and the bytes are each checked, and each masked the other end to end. Handing pdf.js the file's own bytes instead of a copy made it fail on every file, so the copy matters.

## 3. Findings

| ID | Finding | What it means |
|---|---|---|
| G-1 | The Storage emulator ignores write conditions entirely. A copy or save marked "only if nothing is there" replaced the object, and so did one naming a wrong generation. A revision path alone could not stop two uploads that finish together from writing the same object, which would leave a record whose checksum belongs to another file | The job's identifier is now part of the path: `issues/{issue_id}/{revision}-{job_id}.pdf`. That differs from the provisional pattern in `DATABASE_AND_DATA_MODEL.md` section 8. The condition is kept as well, and is NOT VERIFIED here. To agree |
| G-2 | A password-protected PDF is rejected as `NOT_A_PDF`. OQ-30 asks whether one is refused at upload | Spike choice: fail closed, since the app could not open it without a password. A reason of its own may be wanted |
| G-3 | A file exactly at the limit is accepted, and the limit is a byte count in `config/private`, with no default. The tests use 8,192 bytes as a test value | OQ-30: the unit (10⁶ or 2²⁰) and the boundary are open, so AC-8.5's boundary case stays BLOCKED |
| G-4 | pdf.js repairs a damaged cross-reference table and loads the pages, so FX-PDF-11 is accepted. A header after a leading byte is refused, although some readers accept one within the first 1,024 bytes | The depth of "genuine" (FX-PDF-09) is a spike choice. To agree with the reader work (DEC-005) |
| G-5 | A job's `reason` holds the code (`NOT_A_PDF`), while section 4.19 describes it as a plain message | The panel maps the code to words. To agree with B5 |
| G-6 | `ISSUE_NOT_FOUND` is added, for an issue deleted between the request and the file arriving. The contract lists no reason for it | To agree, as D-2 was |
| G-7 | A repeat that asks for something different gets the stored job unchanged. A repeat after the job has finished gets its status and no new address | Spike choices |
| G-8 | The content type must be exactly `application/pdf`. At arrival the type counts for nothing and the bytes decide | Spike choice |
| G-9 | The upload address lifetime is a PLACEHOLDER of 900 seconds: OP-19 says only "short-lived" | Needs a value with DEC-020 |
| G-10 | A failure after the copy leaves an orphan in the private area and the job pending. A failure before it, such as an unusable setting, leaves the file in the holding area. Both wait for the cleanup (OP-41), which is not built. A storage trigger is not retried unless set to be | Build OP-41 before uploads are used |
| G-11 | The whole file is read into memory and parsed. At 150 MB that needs a large function instance, and parsing about 120 pages takes time. Neither was measured | Size with DEC-003 and FX-PDF-05 |
| G-12 | The test library's default bucket (`demo-mfw-spike`) is not the one the trigger listens on (`demo-mfw-spike.appspot.com`). G4 tests the rules on the first. G10 shows that they also refuse direct reads on the second | The bucket name is set with DEC-003 |
| G-13 | pdf.js 6 dropped the `isEvalSupported` setting. Its build has no `eval` or `new Function`, which was checked. Font loading is off. It still parses untrusted bytes, which is the risk `SYSTEM_ARCHITECTURE.md` T8 names | Keep it up to date (DEP-33) |
| G-14 | pdfjs-dist brings one optional dependency, `@napi-rs/canvas` (MIT), with native binaries for each platform. It is installed and not used. Leaving optional dependencies out also drops the Firestore and Storage clients that `firebase-admin` needs, so it cannot simply be omitted | Recorded in DEP-33 |
| G-15 | The (issue_id, created_at) index for OP-20 is not written. The emulator does not need it, as with D-4. The list size is a PLACEHOLDER of 50 | Write the index file before deployment |

## 4. Not tested

| Case | Why |
|---|---|
| A real signed upload URL, and its expiry | The issuer is a stub (DEC-020) |
| The condition that stops a copy replacing an object | The emulator ignores it (G-1) |
| Real concurrency | The emulator is not the platform. A same-moment test runs, and is not a pass |
| A repeated or retried trigger event | Not shown by the emulator |
| A 150 MB file, its memory and its time (FX-PDF-05) | Not generated here (G-11) |
| Removing the orphan and expiring a stale job | OP-41 is not built (G-10) |
| A real or expired token | The Functions emulator does not verify tokens (B-1) |
