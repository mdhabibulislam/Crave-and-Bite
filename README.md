# Crave & Bite — website + owner admin

Static site (no build step): `index.html` (public), `admin.html` (owner panel at `/admin`), data in Supabase.

## Supabase (already set up for project `qadsahrzlndzccvcxffg`)
Tables, Row Level Security and the `media` storage bucket are applied (`supabase/migrations/001_schema.sql`). The public page uses only the project URL and *publishable* key, which are safe in frontend code; every write is blocked by RLS unless signed in as an admin. **Never put the service-role key anywhere in this repo.**

## One-time setup you must do
1. **Create the owner login:** Supabase Dashboard → Authentication → Users → *Add user* → email + strong password (tick *Auto Confirm*).
2. **Make that user an admin:** SQL Editor → run `insert into public.admins (user_id) select id from auth.users where email = 'OWNER_EMAIL';`
3. **Turn off public sign-ups:** Authentication → Sign In / Providers → disable *Allow new users to sign up*.
4. **Password reset links:** Authentication → URL Configuration → Site URL = `https://craveandbite.vercel.app`, and add `https://craveandbite.vercel.app/admin` to Redirect URLs.
5. Optional: Authentication → Sessions → set a shorter JWT expiry / inactivity timeout.

## Login & recovery
Open the small "Owner login" link at the very bottom of the website (or go to `/admin`). Sessions end when the tab closes and after 30 minutes idle. "Forgot password?" emails a reset link. If email is unavailable: Supabase Dashboard → Authentication → Users → reset the password there.

## Deploy
Upload these files to the GitHub repo root (`index.html`, `admin.html`, `vercel.json`, `robots.txt`, `logo.png`, `combo-poster.webp`, `supabase/`). Vercel redeploys automatically; no environment variables are needed. Menu, offers, popup and settings changes made in the admin are live immediately, with no redeploy.

## Test the popup / offers
Admin → Offers → New offer → upload image → tick *Published* and *Active* → Save → *Use in popup* (or Popup Manager). Open the website in a new tab: the popup appears immediately on every fresh load. Set an end date in the past or untick Published and it stops appearing.

## Frontend-only vs backend
Orders are sent as a WhatsApp message (no order database, no payments). Before the message is built, the page re-reads current prices, availability, promo and delivery fee from the database. A real order system would need a server-side orders table.
