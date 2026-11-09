# WordPress Public Site Evidence: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | WordPress Public Site Evidence |
| File | `Documentation/test-evidence/WORDPRESS_PUBLIC_SITE_EVIDENCE.md` |
| Phase | 4: Testing, Release and Risk Management. Evidence for T-08.1 (MOD-09), OQ-39 and R5 |
| Version | 0.2 |
| Status | Draft for review. Not reviewed. **A one-time read of public data on 8 November 2026. It is not MFW's confirmation, and OQ-39 stays OPEN.** No credentials were used or held. Section 7 adds a development read with the app's own client the same day, which is not the recorded live read of T-08.1. |
| Date | 8 November 2026 |
| Prepared by | Yuvraj Gaykhe (WS-B), 8 November 2026 |
| Approval required | Both developers |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 8 November 2026 | First record: what the public website and its public REST API show, and what still needs MFW's confirmation. Revised on 9 November 2026 after the review of pull request #56: section 6 point 5 notes that eight of the nine categories of CFG-04 hold no post, for the empty state of FR-STATE-002. |
| 0.2 | 8 November 2026 | Section 7 added: a development read of the public API with the app's WordPress client (pull request #58), with counts, IDs and dates only. Sections 1 to 6 are unchanged. |

### 1.1 Related documents

| Document | Status |
|---|---|
| `OPEN_QUESTIONS.md` OQ-39, OQ-17 | Exists, draft. The site address, the API and the categories; how a breaking post is marked |
| `DEPENDENCY_REGISTER.md` DEP-04, DEP-19, DEP-20, DEP-54, DEP-66 | Exists, draft. The WordPress input, the API, the hosting, and the HTML rendering of posts |
| `DEPLOYMENT_PLAN.md` CFG-03, CFG-04, section 7.6 | Exists, draft. The site address, the categories and the checks before release |
| `RISK_REGISTER.md` R5 | Exists, draft. The API blocked, slow or not enabled |
| `TEST_DATA_AND_FIXTURES.md` FX-WP-01 to FX-WP-12 | Exists, draft. The WordPress fixtures |
| `inputs/README.md` | Exists. The website link |

## 2. What MFW Said

Reported by YG on 8 November 2026, not filed: MFW has shared its official website, https://metalformingworld.com, as the website reference for the project. MFW gave no WordPress administrator access, no API credentials and no access to the hosting, and this record assumes none. The app needs none to read public news (DEP-19: read-only and public, with no credentials).

## 3. Method

On 8 November 2026, at YG's request, an automated reading in a browser opened the home page and one news article, and sent GET requests to the public REST API and the RSS feed with no cookies or credentials. Two more GET requests went from a command-line client with a user agent of the form the Dart HTTP client sends (`Dart/3.13 (dart:io)`), to see whether a client that is not a browser is let through. Nothing was posted, submitted or signed in to. No response body is stored in the repository, and no MFW content is copied into a fixture.

## 4. Publicly Verified

Facts seen on 8 November 2026. Each can change when MFW changes its site.

| ID | Check | Result |
|---|---|---|
| WP-PV-01 | The site runs WordPress | Yes. The home page names "WordPress 7.1.4" in its generator tag, and the RSS feed names `https://wordpress.org/?v=7.1.4` |
| WP-PV-02 | Page builder and theme | Elementor 4.3.6 with an Elementor Pro widget set, and the Hello Elementor theme 3.4.7 |
| WP-PV-03 | REST API index | `https://metalformingworld.com/wp-json/` answers 200 with JSON and lists the `wp/v2` namespace, including the posts and categories routes. The home page points to it with a link of type `https://api.w.org/` |
| WP-PV-04 | Posts | `GET /wp-json/wp/v2/posts` answers 200 with no credentials. It reports 11 published posts in the `X-WP-Total` header, and sends `X-WP-TotalPages` for paging. The newest post is dated 21 March 2026. All 11 posts are in one category, Industry News. None is sticky and none has a tag. The five newest posts each have a featured image |
| WP-PV-05 | Categories | `GET /wp-json/wp/v2/categories` answers 200 with 10 categories. Industry News (ID 7) holds the 11 posts. Blog (ID 1), CASE STUDIES (14), EVENT COVERAGE (18), HALL OF FAME (12), INDUSTRY WATCH (11), INNOVATORS (15), PRODUCT VIEW (17), PROJECT UPDATES (16) and WORLD GATEWAY (13) hold none |
| WP-PV-06 | The "News" menu | It lists nine sections, from Industry News to Event Coverage. They link to WordPress pages, such as `/industry-news/`, and not to category archives. The pages route also lists three issue pages (April-May, June-July and August-September 2026) |
| WP-PV-07 | The body of a post | The `content.rendered` field of the newest post (32,422 characters) holds Elementor layout and not only the article: a form with six inputs and a button, a list of six other posts, seven images and four inline SVG icons. No `script` or `iframe` element was found in it. The `excerpt.rendered` field of the five newest posts is short (363 to 458 characters) |
| WP-PV-08 | A client that is not a browser | The two requests with the Dart user agent, for posts and for categories, both answered 200 with JSON. The responses pass through Cloudflare (`server: cloudflare`, `cf-cache-status: DYNAMIC`). One request each, from one network, at one time |
| WP-PV-09 | RSS feed | `/feed/` answers 200 as `application/rss+xml` with 10 items |
| WP-PV-10 | Time zone | The API index gives a GMT offset of 0 and no time zone name, and each post's `date` equals its `date_gmt` |
| WP-PV-11 | Plugins that can affect the API | The API index lists, among others, namespaces for a two-factor sign-in plugin and for the LiteSpeed cache. Security and cache plugins are what OQ-39 asks about. The index also lists namespaces of two hosting companies' tools, so the host is not established from public data |

## 5. What Needs MFW's Confirmation

| Item | Why public data is not enough | Tracked in |
|---|---|---|
| That https://metalformingworld.com is the WordPress site the app reads | MFW named it as its website. OQ-39 asks for the address in writing | OQ-39; CFG-03 |
| Which categories the app shows | Only Industry News holds posts. The other nine are empty, and the menu sections are pages. MFW chooses the categories (RS INT-WP-003). Update of 8 November 2026: YG reports (not filed) that the app may use the website's categories, with creative freedom for the team. The working position is in CFG-04, and MFW's written confirmation is still needed | OQ-39; CFG-04 |
| That the API stays open to the app, with no security plugin, firewall or Cloudflare rule that blocks or limits it, and whom to contact if it does | One request of each kind passed. Rules and limits can change, and none was tested under load | OQ-39; R5 |
| How a breaking post is marked | No post is sticky and the site uses no tags | OQ-17 |
| Whether articles will go on being built with Elementor | Elementor layout in `content.rendered` decides how the app shows an article (DEP-54, DEP-66) | DEP-54 |
| Who hosts the site and keeps WordPress updated | Not established from public data | DEP-20 |
| That the app may show the featured images | Content rights are an MFW input | DEP-01; OQ-28 |

## 6. What This Means for T-08.1

1. The client and its fixture tests can be written now against the response shapes in section 4. The fixtures stay synthetic and are written by hand in those shapes (`TEST_DATA_AND_FIXTURES.md`). No MFW post is copied into the repository.
2. The live read stays gated on OQ-39, as `DEVELOPMENT_ROADMAP.md` section 4.3 says.
3. WP-PV-07 is a design input for DEP-54 and is not decided here. The options include showing the excerpt and the featured image with a link to the article on the website, or taking the article text out of the Elementor layout. Both developers decide, and RS FR-NEWS rows set what the app must show.
4. The checks of `DEPLOYMENT_PLAN.md` section 7.6 are repeated before release. This record does not replace them.
5. Eight of the nine categories of the CFG-04 working position hold no post today (WP-PV-05): only Industry News (ID 7) does. The news screens therefore need the empty state of RS FR-STATE-002 for a category, and the M2 designs show it. The working position of CFG-04 stays as it is.

## 7. A Development Read with the App's Client

On 8 November 2026 at 09:46 UTC, `app/tool/wordpress_live_read.dart` (pull request #58) ran the app's own WordPress client from YG's Mac against the public API, with the working position of CFG-03 and CFG-04: the site https://metalformingworld.com and the categories 7 and 11 to 18. It sent seven GET requests with no credentials, and printed counts, IDs, dates and yes or no answers only. No title, article or image was printed or stored.

This is a development read. CFG-03 and CFG-04 stay OPEN until OQ-39 is answered in writing, so it is not the recorded live read that closes T-08.1 (section 6, point 2).

| ID | Check | Result |
|---|---|---|
| WP-DR-01 | Categories | 9 returned, in the configured order: 7, 11, 12, 13, 14, 15, 16, 17, 18 |
| WP-DR-02 | First page of posts | 10 posts, all in category 7, each with an `https` featured image; more pages: yes |
| WP-DR-03 | Dates | Newest 21 March 2026, oldest on the page 16 March 2026, newest first |
| WP-DR-04 | Titles | None still holds an HTML character reference after decoding |
| WP-DR-05 | Category filter | Category 11: 0 posts. Category 7: 10 posts |
| WP-DR-06 | A page past the end | Page 99 gives an empty last page, which is the path of the 400 `rest_post_invalid_page_number` answer |
| WP-DR-07 | One article | The newest post (ID 198): a body of 32,422 characters, with no `script` and no `iframe` element, as WP-PV-07 found |
| WP-DR-08 | An unknown article | `notFound` |

What it shows: the client reads the live response shapes as the fixtures expect. WP-PV-04 found a featured image on the five newest posts; this read finds one on all ten posts of the first page. What it does not show: behaviour under load, rate limits, or the API staying open over time (R5).
