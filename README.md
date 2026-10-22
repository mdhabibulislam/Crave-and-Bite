# Crave & Bite

Static mobile-first restaurant website (single `index.html`, no build step).

- Menu, search, filters, cart and WhatsApp ordering are frontend-only.
- Set the WhatsApp number in `index.html` (`WHATSAPP_NUMBER`, international format, e.g. `8801760747936`).
- Orders are only placed when the customer sends the WhatsApp message and the restaurant confirms.

## Deploy on Vercel
1. Push this folder to a GitHub repo.
2. On vercel.com choose **Add New → Project**, import the repo.
3. Framework Preset: **Other**. No build command, no output directory. Click **Deploy**.
