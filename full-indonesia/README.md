Repository template for MikroTik RouterOS v7 CDN auto-update.
Fork to: https://github.com/Kacrut88/mikrotik-cdn-streaming

Two variants included:
- full-indonesia/  -> includes Telkom-specific local-prefix suggestions (AS7713 examples)
- global-only/     -> lighter lists with global CDN domains/prefixes only

Usage (on RouterOS):
1. Upload the chosen `auto-update-*.rsc` to Files.
2. Import once: /import auto-update-*.rsc
3. Confirm router can fetch raw.githubusercontent.com
4. Check /log for update messages.

NOTE: Local ISP prefix lists (Telkom) are examples. For best results, edit the telkom-cdn-list.txt in the repo with prefixes you want to prioritize.
