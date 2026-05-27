# Emma App

iOS companion app. Separate from the site. Changes here never touch indahl.ai or read.indahl.ai.

## Architecture

- **Voice:** ElevenLabs agentId direct (no server-side token needed)
- **Text chat:** buddy-companion Cloudflare Worker
- **Auth:** Supabase (app_users, app_sessions, app_soul_files tables)
- **Payment:** Stripe, $4.99/month, 42 free interactions
- **Soul file:** Per-user conversation memory, Emma writes to herself every 5 turns

## The Rule

Nobody pushes to `companion-local` or `claude-wayfinder/indahl.ai` for app work.
App work lives here. If it breaks, it breaks the app. The site stays up.

## Build Order

1. iOS shell (WKWebView or native Swift)
2. Voice integration (ElevenLabs SDK, push-to-talk)
3. Text chat fallback (Cloudflare Worker)
4. Auth flow (Supabase, post-Stripe signup)
5. Soul file persistence (per-user, 5-turn compression)
6. 42-interaction trial (localStorage/device counter)
7. Stripe paywall at interaction 43
8. App Store submission (mic permission with proper purpose string, iPhone only, no iPad)

## Env Vars

```
ELEVENLABS_API_KEY=
ELEVENLABS_VOICE_ID=3470F6oiRpS7SI9iCQLH
ELEVENLABS_ENGINE_ID=seng_2401ksj7062vfr4a5znmqgyfp2n6
STRIPE_SECRET_KEY=
STRIPE_PRICE_ID=
SUPABASE_URL=
SUPABASE_KEY=
BUDDY_WORKER_URL=https://buddy-companion.kory-indahl.workers.dev
```

## App Store Notes (from 5 rounds with the donkeys)

- NSMicrophoneUsageDescription: "Emma uses the microphone for real-time voice conversations with your AI companion. When you tap the Talk button, your speech is captured and sent to ElevenLabs for live transcription so Emma can understand and respond to you by voice."
- iPhone only (TARGETED_DEVICE_FAMILY = "1")
- No iPad until layout is ready
- No camera, no location permissions
- ITSAppUsesNonExemptEncryption: false
- Screenshots needed for: 6.7-inch, 6.5-inch, 6.1-inch iPhone sizes
- Must show actual app in use, not splash screens
