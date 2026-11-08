# Download Resume Spike Evidence: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Download Resume Spike Evidence |
| File | `Documentation/test-evidence/DOWNLOAD_RESUME_SPIKE_EVIDENCE.md` |
| Phase | 4: Testing, Release and Risk Management. A test evidence report (`TESTING_STRATEGY.md` §13) |
| Version | 0.1 |
| Status | Draft for review. Not reviewed. **Simulator and emulator only, debug builds, against a local test server.** No phone was used, and the candidate file mechanism (DEC-020) was not. It is evidence for T-02.4, not a result for AC-4.3, and it approves nothing |
| Date | 8 November 2026 |
| Tests run by | Yuvraj Gaykhe (WS-B), 8 November 2026, in the T-02.4 spike |
| Approval required | Both developers. MOD06-P1-T02 is done when Sanika Attarde has reviewed this report |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 8 November 2026 | First report: four integration tests of the resume spike on an iOS simulator and an Android emulator, with a 150,000,000 byte synthetic file served by a local range server. |

### 1.1 Related documents

| Document | Status |
|---|---|
| `DEVELOPMENT_ROADMAP.md` T-02.4, T-06.3 | Exists, draft. Exit of T-02.4: evidence that a download resumes after a network break without restarting |
| `YUVRAJ_IMPLEMENTATION_ROADMAP.md` MOD06-P1-T02 | Exists, a record of the plan. The resume spike on a near-limit file: a local test server first, then the candidate mechanism |
| `PDF_READER_AND_OFFLINE_DESIGN.md` section 4 | Exists, draft. Invariant I-5: the length of the partial file is the truth for where to resume |
| `API_AND_MODULE_CONTRACTS.md` section 6.6 | Exists, draft. The MOD-06 rules |
| `ACCEPTANCE_CRITERIA.md` AC-4.3 | Exists, draft. A download resumes after a network break, tested with FX-NET-01 on FX-PDF-05 |
| `TEST_DATA_AND_FIXTURES.md` FX-NET-01, FX-NET-07, FX-PDF-05 | Exist, draft. Network lost; a reset mid-transfer; the near-limit file |
| `DECISION_LOG.md` DEC-020; `OPEN_QUESTIONS.md` OQ-30, OQ-37, OQ-54 | Exist, draft. The file mechanism (OPEN); what "MB" means; the mechanism question; background downloads |
| `RISK_REGISTER.md` R2 (AR-01) | Exists, draft. Resume with a signed URL not shown to work |
| `DEVELOPMENT_WORKFLOW.md` §13 item 5 | Exists, draft. A spike is not merged into `main` as production code. Its findings are merged as a document. This report is that document |
| Branch `spike/yg-download-resume`, commit `262f306` | Not merged to `main`. On GitHub. Holds the adapters, the range server (`app/tool/range_server.dart`) and the integration test (`app/integration_test/download_resume_test.dart`) |

## 2. What This Report Is

1. It records four integration tests of the download manager of MOD-06 with its real adapters: an HTTP transport that resumes with a `Range` request, a file store on the device's file system, and a SHA-256 check. They ran on an iOS simulator and an Android emulator.
2. The file is synthetic and deterministic, made by the range server, so no MFW content is involved (DEC-024).
3. The server breaks the connection at set points (FX-NET-07). The app keeps what it received, and the next start asks for the rest.

**What it is not.**

- It is not a result for AC-4.3. That test turns the network off on a phone (FX-NET-01) on the near-limit PDF (FX-PDF-05), and it is T-06.3.
- It does not use the candidate file mechanism. The grant here is a plain URL to the local server. Whether the mechanism of DEC-020 answers a `Range` request, and what happens when a grant expires mid-download, are not shown (step 4 of MOD06-P1-T02; R2, AR-01).
- It changes no requirement, decision, status label or risk score.

## 3. The Run

| Field | Detail |
|---|---|
| Code | `spike/yg-download-resume` at `262f306`, on top of `spike/yg-ws-b`. `IssueDownloadManager`, `HttpFileTransport`, `IoFileStore` and `Sha256Verifier` in `app/lib/features/downloads/` |
| Server | `app/tool/range_server.dart`, run on the Mac with `dart run tool/range_server.dart --port=8099 --size=150000000`. It serves the file with `Range: bytes=n-` (206 with `Content-Range`), can ignore the range (`?norange=1`, 200), breaks the connection once at each set fraction of the file, and logs each request |
| File | 150,000,000 bytes of synthetic content. SHA-256 `663d66cca518e3fae43ec4dd3f75d40f1f317fca0bb812d4ad095491fd22f4f2`. That is 150 MB if "MB" means 10⁶ bytes, which is OQ-30 |
| Test | `app/integration_test/download_resume_test.dart`, four tests, each in a fresh temporary folder. Each prints one `RESUME` line with the server's log |
| iOS | iPhone 18 Pro simulator, iOS 27.2, Xcode 27.2 (27B52). Server address `127.0.0.1` |
| Android | Emulator `mfw_api36`, Android 16 (API 36), arm64. Server address `10.0.2.2`, the emulator's address for the Mac |
| Toolchain | Flutter 3.47.9, Dart 3.13.7, debug builds, on an Apple M2 Mac with 8 processors |
| Date | 8 November 2026, Mac local time |
| Other checks on the same tree | `flutter pub get --enforce-lockfile` passes; `dart format`, 144 files and 0 changed; `dart analyze`, no issues; `flutter test`, 424 passed |

## 4. Results

All four tests passed on both platforms.

| Test | What it checks | iOS simulator | Android emulator |
|---|---|---|---|
| An unbroken download | One request of 150,000,000 bytes, the hash matches, and the copy on disk is 150,000,000 bytes | Passed | Passed |
| Two breaks | The connection breaks at 30% and at 70%. Each break leaves a waiting status with the bytes kept. Each later start asks for `bytes=<kept>-` and gets 206, and the copy is whole | Passed | Passed |
| A server that ignores the range | After a break at 50%, the server answers the resume with the whole file (200). The transport skips the bytes it already has, and the copy is whole | Passed | Passed |
| Cancel while waiting | Cancel deletes the partial file and clears the status. The next start begins at byte 0 and completes | Passed | Passed |

### 4.1 Bytes kept and sent

| Test | Platform | Kept at each break | Requests (start, status, bytes sent) | Total sent | Time (ms) |
|---|---|---|---|---|---|
| Unbroken | iOS | None | (0, 200, 150,000,000) | 150,000,000 | 7,346 |
| Unbroken | Android | None | (0, 200, 150,000,000) | 150,000,000 | 20,749 |
| Two breaks | iOS | 45,000,000; 105,000,000 | (0, 200, 45,000,000); (45,000,000, 206, 60,000,000); (105,000,000, 206, 45,000,000) | 150,000,000 | 4,684 |
| Two breaks | Android | 45,000,000; 105,000,000 | (0, 200, 45,000,000); (45,000,000, 206, 60,000,000); (105,000,000, 206, 45,000,000) | 150,000,000 | 19,028 |
| No range | iOS | 75,000,000 | (0, 200, 75,000,000); (0, 200, 150,000,000) | 225,000,000 | 3,107 |
| No range | Android | 75,000,000 | (0, 200, 75,000,000); (0, 200, 150,000,000) | 225,000,000 | 27,862 |
| Cancel | Both | One break at 50%, then cancelled | After the cancel: (0, 200, 150,000,000) | 150,000,000 | Not timed |

**What the numbers show.**

- **No byte is sent twice when the server honours the range.** With two breaks, the server sent 150,000,000 bytes in all, the same as an unbroken download.
- **The resume point is the partial file's length (I-5).** Each resume asked from exactly the bytes kept at the break, and the kept bytes equal the break points that the server set.
- **A server that ignores the range costs the whole file again.** The copy is still whole, but 225,000,000 bytes were sent for a 150,000,000 byte file. A mechanism that does not honour `Range` would turn every break into a fresh download.
- **The times are for loopback on one Mac.** They include writing the file and the hash, in debug builds. They say nothing about a phone on a mobile network, and they are not compared with any target.

## 5. What Changed in the Spike for This Run

- **The waiting status in the panel.** A download that waits for the network shows the bytes kept, says that the connection was lost, and offers Resume. Resume starts again from the partial file. Before this, the panel showed the progress bar with no action. Whether a resume starts on its own is T-06.3 (OQ-54). The wording is PLACEHOLDER (M2 designs).
- **The panel test** checks that the second fetch asks from byte 300 after a break at 300 bytes.
- **One analyzer issue** in `IoFileStore` is fixed (an initializing formal).

## 6. What This Run Did Not Show

1. **A network loss on the device.** The break was the server closing the connection. Turning the network off (FX-NET-01, AC-4.3), and a connection that stalls without closing, were not tested. The transport treats a stall of more than 20 seconds as a retryable timeout, and no test covers that path yet.
2. **The candidate file mechanism (DEC-020)** and an expired grant (MOD06-P1-T02 step 4). The spike requests a new grant at each start, but the grant here never expires.
3. **App-private storage.** The test used a temporary folder. The app-private folder waits for its plugin (DEP-49, CANDIDATE).
4. **A restart between the break and the resume.** The partial file survives on disk, but the test kept the same manager. The registry and the repair of partial files at start are `PDF_READER_AND_OFFLINE_DESIGN.md` §4.4.
5. **Background downloads and a locked screen** (OQ-54). The working position is foreground only.
6. **A phone.** Simulator and emulator only, debug builds, on loopback.

## 7. Points for Other Documents

These are points for the owners of the documents to consider. This report changes none of them.

| Document | Point |
|---|---|
| `DECISION_LOG.md` DEC-020; `OPEN_QUESTIONS.md` OQ-37 | Whatever mechanism is chosen should answer `Range: bytes=n-` with 206 and a matching `Content-Range`. Otherwise a break costs the whole file again (section 4.1) |
| `RISK_REGISTER.md` R2 (AR-01) | Resume works with a plain range server. With a signed URL it is still not shown, so AR-01 stands |
| `DEPENDENCY_REGISTER.md` | The spike uses `crypto` directly for SHA-256. The lock file already held it as a transitive package, and it has no register entry of its own. It needs one before it is used beyond a spike (`CODING_STANDARDS.md` §12) |
| `ACCEPTANCE_CRITERIA.md` AC-4.3 | Still to be run on a phone with FX-NET-01 on FX-PDF-05, in T-06.3 |
