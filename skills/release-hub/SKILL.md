---
name: release-hub
description: Use when the user asks to release, publish, ship, or distribute an app via release-hub - direct APK distribution, Play internal/beta/production channels, fetching signing keystores, bumping versions for a release, checking release status, or registering a new app on the hub.
---

# release-hub

Self-hosted release hub for personal Android apps. Single Go binary + SQLite,
source at `~/Code/release-hub` (deployed instance runs remotely). It owns
versioning, artifact storage, signing keystores, Play publishing, and the
update-manifest API for in-app updaters.

| Thing | Value |
|---|---|
| Hub URL (from exe.dev VMs) | `https://release-hub.int.exe.xyz` (edge proxy) |
| Artifact base URL | `https://hub.nesin.io/artifacts/...` |
| Source repo | `~/Code/release-hub` (may lag deployed version; check `origin/main`) |
| Registered apps | `goldview` (io.nesin.goldview), `otpbee` (io.nesin.otpbee), `tinyfirewall` (io.nesin.tinyfirewall) |

## Auth (memorize this)

- **From an exe.dev VM: NO token needed, ever.** The edge proxy authenticates
  the VM and injects/overrides auth even over a dummy bearer. Do not ask the
  user for `HUB_TOKEN` there.
- Repo release scripts check `HUB_TOKEN` is non-empty and die otherwise.
  Satisfy them with any placeholder: `HUB_TOKEN=vm-edge ./scripts/release-internal.sh "notes"`.
- From anywhere else (e.g. Mac mini): a real `rh_...` bearer token is needed,
  created in the hub UI (shown once) or `POST /api/tokens`. Never paste tokens
  into chat; read them from where they are stored (shell rc, keychain, env).
- On the devbox, `~/.zsh_history` contains `export HUB_TOKEN=-` and that
  literal `-` is a valid (extremely weak) token. Worth rotating eventually.

## Channels

| Channel | Artifact | Goes to |
|---|---|---|
| `direct` | `.apk` | Hub only + update manifest for in-app updater (no Play) |
| `internal` | `.aab` | Play **internal testing** track |
| `beta` | `.aab` | Play **open testing** (beta) track |
| `alpha` | `.aab` | Play closed testing (alpha) track |
| `public` | `.aab` | Play **production** track (full rollout on commit) |

Platform defaults to `android` in all paths. iOS releases do NOT go through
the hub today; TestFlight uploads run from the Mac mini via
`release-testflight.sh` straight to App Store Connect.

## Cut a release (the day-2 loop)

### 1. Check hub state

```bash
HUB=https://release-hub.int.exe.xyz
# newest-first; also gives max versionCode the next release must exceed
curl -s $HUB/api/apps/$SLUG/releases | python3 -m json.tool | head -40
# Play wiring sane before burning a build (Play channels only)
curl -s $HUB/api/apps/$SLUG/play/preflight   # want {"ok":true,...}
curl -s $HUB/api/apps/$SLUG/android/tracks   # live Play track state
```

versionCode must strictly increase per app. Both the hub (409 before storing
anything, so retries are safe) and Play enforce it. If a bundle was ever
uploaded to Play before (even one stuck rejected in a draft), that code is
burned - bump again.

### 2. Bump the version

- goldview: changesets drive versionName (`pnpm changeset` -> `pnpm
  changeset:version`), then `pnpm bump` bumps android versionCode + syncs
  versionName into build.gradle (and iOS build numbers).
- tinyfirewall / otpbee: edit `app/build.gradle.kts` (`versionCode`/`versionName`) by hand.
- Omit `versionCode` on upload and the hub assigns `max+1` itself. Consequence
  (bit us on otpbee 0.5.0): the hub's code drifts from gradle's code - hub
  had 8 while gradle said 7 and Play showed "0.5.0 (7)". That is by design;
  don't trip on it.
- Commit + push the bump (imperative-mood message) after the release succeeds.

### 3. Fetch the signing keystore (CRITICAL)

```bash
KEY=$(mktemp -d)/release.jks; HDR=$(mktemp)
curl -sf -D "$HDR" -o "$KEY" $HUB/api/apps/$SLUG/signing
hdrval() { grep -i "^$1:" "$HDR" | sed 's/^[^:]*: *//' | tr -d '\r'; }
[ "$(hdrval x-hub-keystore-sha256)" = "$(sha256sum "$KEY" | cut -d' ' -f1)" ] || echo MISMATCH
export HUB_KEYSTORE="$KEY" \
       HUB_STORE_PW="$(hdrval x-hub-store-password)" \
       HUB_KEY_ALIAS="$(hdrval x-hub-key-alias)" \
       HUB_KEY_PW="$(hdrval x-hub-key-password)"
```

The gradle signingConfig reads these `HUB_*` vars and **silently falls back
to the debug keystore** when they are unset. A debug-signed bundle is stored
by the hub fine but Play rejects it with an SHA1 mismatch (happened on otpbee
0.5.0). Belt and braces: `keytool -printcert -jarfile app-release.aab` and
check the SHA1 matches what Play expects BEFORE uploading.

### 4. Build + gates

- Play channels: `./gradlew bundleRelease` -> `app/build/outputs/bundle/release/app-release.aab`
- Direct channel: `./gradlew assembleRelease` -> arm64-v8a APK
- **16 KB alignment gate** (goldview: `scripts/check-16kb.sh <artifact>`):
  Play hard-rejects bundles whose 64-bit native libs have 4 KB ELF LOAD
  alignment ("does not support 16 KB memory page sizes"). v27 of goldview was
  rejected exactly this way: a hand-applied pnpm patch to
  react-native-quick-sqlite got silently reverted by `pnpm install`. Register
  patches in `pnpm-workspace.yaml`, clean the lib's build dir, rebuild, and
  run the gate. 32-bit ABIs are exempt.
- Run builds in tmux/detached; RN release builds take minutes. Poll the log.

### 5. Upload

```bash
RESP=$(curl -s -w '\n%{http_code}' --max-time 600 \
  -F "file=@$ARTIFACT" -F "channel=$CHANNEL" \
  -F "versionName=$VERSION_NAME" -F "notes=$NOTES" \
  $HUB/api/apps/$SLUG/releases)
```

- `201` -> check the body: `"playRelease":"1.0.13 (24)"` means Play accepted;
  `"playError":"..."` means stored on hub but Play failed - decide whether to
  fail (common cause: versionCode not increased, or declarations incomplete).
- `409` -> versionCode already used; nothing was stored. Bump and retry.
- Large multipart can time out behind proxies: retry up to 3x with backoff;
  safe because duplicates 409 before storage.
- `versionCode` form field: **required for direct-channel android APKs**
  (must be the ABI-adjusted BuildConfig.VERSION_CODE, e.g. tinyfirewall's
  base*10+abi scheme so arm64 of base 7 ships as 71); optional otherwise
  (hub auto-assigns max+1).
- `notes` and any user-visible strings: no em dashes (standing rule).
- NEVER probe or test-upload with a POST - every POST creates a real release,
  and non-direct releases cannot be deleted (only `direct`-channel ones can,
  via `DELETE /api/apps/{slug}/releases/{versionCode}`). Probe with GETs only.

### 6. Verify

```bash
curl -s $HUB/api/apps/$SLUG/releases | python3 -c '
import json,sys
r=json.load(sys.stdin)[0]
print(r["versionCode"], r["versionName"], r["channel"], r.get("playStatus"), r.get("playRelease",r.get("playError","")))'
```

`playStatus=ok` and the right `playRelease` = done. For production pushes,
confirm in Play Console (tailbrowser: app list shows track + "In review" /
"Live"; releases page shows the new release and no warnings). Then commit +
push the version bump if not already committed.

## Repo release scripts

Prefer existing scripts; they encode preflight, keystore fetch + sha verify,
build, 16 KB gate, retry logic:

- goldview (`apps/mobile-app`): `pnpm release:direct` / `release:internal` /
  `release:production` (env: `HUB_URL` default `https://release-hub.int.exe.xyz`,
  `HUB_SLUG` default goldview, `HUB_TOKEN` any non-empty value on a VM).
- tiny-firewall: `./release-internal.sh` (Play internal), `./deploy.sh`
  (direct APK + regenerates the update manifest; reads the ABI-adjusted
  versionCode back out of the built APK with aapt).
- For a channel without a script, copy release-internal.sh and change the
  `-F channel=` value (that is how beta and production variants were born).

## New app on the hub (one-time)

```bash
curl -F slug=$SLUG $HUB/api/apps                        # register product
curl -F platform=android -F packageName=io.example.app \
     $HUB/api/apps/$SLUG/platforms                      # generates RSA-2048 keystore automatically
# Play publishing: one shared service account for the whole hub
curl -F file=service-account.json $HUB/api/play-accounts   # once per hub
curl -F account=1 $HUB/api/apps/$SLUG/play                 # enable per app
```

Then: point the app's gradle signingConfig at the `HUB_*` env vars (with a
debug fallback for local builds), copy the release scripts (set `HUB_SLUG`),
and in Play Console create the internal-track tester email list + opt-in
link. Keystore is generated once and never rotates (rotation breaks update
signing for the installed base); keep an offline backup.

## API quick reference

```
GET  /health                                         -> "ok"
GET  /api/apps                                       -> apps + platforms
GET  /api/apps/{slug}/releases                       -> newest-first; max versionCode
POST /api/apps/{slug}/releases                       -> multipart: file, channel, versionCode?, versionName?, notes
GET  /api/apps/{slug}/signing                        -> keystore + x-hub-* password/sha headers
GET  /api/apps/{slug}/play/preflight                 -> {ok, detail}
GET  /api/apps/{slug}/android/tracks                 -> live Play tracks
GET  /api/apps/{slug}/manifest?channel=direct        -> PUBLIC update manifest (devices)
GET  /artifacts/{slug}/{platform}/{file}             -> PUBLIC download
POST /api/tokens                                     -> form: name (token shown once)
DELETE /api/apps/{slug}/releases/{versionCode}       -> direct channel ONLY
```

## Troubleshooting (seen in the wild)

| Symptom | Cause / fix |
|---|---|
| `playError` SHA1 mismatch | Built with debug keystore: `HUB_*` signing vars were not exported (silent fallback). Fetch keystore, rebuild, verify with keytool first. |
| Play: "does not support 16 KB memory page sizes" | A native lib has 4 KB alignment. Register the pnpm patch properly, clean the lib build dir, rebuild, run check-16kb.sh. |
| Play declarations (e.g. AD_ID) rejected even though the new release is clean | Play validates EVERY active artifact across tracks: a stale internal-track build without AD_ID keeps the production declaration error alive. Ship the fix to both production and the internal track (vc22 + vc23 lesson). |
| 409 versionCode must be > N | versionCode already used. Bump. Retry-safe: nothing stored. |
| Play 400 "Only releases with status draft may be created on draft app" | App still draft in Console; internal track works on drafts, beta/alpha do not. Finish declarations (privacy policy, content rating), launch, then beta. |
| playError 403 not linked / API not used | Service account not invited in Play Console or API access not linked; see hub repo docs/play-internal-testing.md. |
| Upload OK but testers see nothing | Tester list empty / opt-in not done, or Play still processing (minutes). |
| Duplicate-looking releases on the hub | A failed Play push still records the release (and burns the code); harmless but permanent for Play channels. |

## Security

- The signing endpoint returns live key material - treat the hub token and
  the VM edge auth as production credentials; keep the hub behind TLS.
- Never print tokens or keystore passwords in chat or logs; pass via env.
- Keystore never rotates; losing it (without Play App Signing) means users
  can never update. Offline backup exists - do not regenerate casually.