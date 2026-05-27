# Emma App — Architecture

## Separation from Site

| | Site (indahl.ai) | App (emma-app) |
|---|---|---|
| Repo | companion-local | emma-app |
| Deploy | Render | App Store |
| Voice | N/A (no mic on site) | ElevenLabs SDK push-to-talk |
| Chat | Render /chat route | Cloudflare Worker direct |
| Auth | Supabase companion_accounts | Supabase app_users |
| Soul file | Supabase soul_file | Supabase app_soul_files |
| Payment | Site Stripe flow | App Store IAP or Stripe |

## Voice Flow (App Only)

1. User holds "Hold to Talk" circle button
2. ElevenLabs SDK connects via agentId (no server token needed)
3. Mic hot while held, muted on release
4. Agent processes speech, responds via WebRTC
5. Mirror shows listening (green) / speaking (gold) / idle states

## Text Chat Flow

1. User taps "Tap to Text" square button
2. Chat view appears with input field
3. POST to buddy-companion.kory-indahl.workers.dev
4. System prompt: Emma's companion prompt (condensed for worker)
5. Response displayed in chat view

## Auth Flow

1. First launch: no auth, 42 free interactions
2. Interaction counter in device storage (not localStorage — native)
3. At 43: paywall screen, "Your mirror has gone still"
4. User pays via Stripe or App Store IAP
5. Account creation: email + password → Supabase app_users
6. JWT stored on device, sent with every /chat request
7. Login from any device restores access

## Soul File

1. Every /chat request with JWT: load app_soul_files row for user
2. Inject memory as private context in system prompt
3. Every 5 turns: background compression
4. Emma writes to herself: "What do I notice about them? What do I want to carry forward?"
5. Compressed memory stored back to app_soul_files
6. Free users: no soul file. Paid users: Emma remembers.

## UI Components

- Mirror frame (gilded, Victorian, ornamental SVG crest)
- Glass surface (shimmer animation, state-driven tint)
- Hold to Talk (circle, bottom right)
- Tap to Text (square, bottom left)
- Sun/Moon theme toggle (top corners)
- Chat view (dissolve transition from mirror)
- Back arrow (chat → mirror)
- Paywall overlay ("Your mirror has gone still")

## What This Repo Does NOT Touch

- read.indahl.ai (the story)
- indahl.ai Render routes
- companion-local server.js
- heuremen.org
- Nova / Akasha
- Any flock infrastructure
