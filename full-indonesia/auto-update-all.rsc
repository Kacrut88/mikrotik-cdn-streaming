/log info "Update CDN + IPTV"
/import auto-update-cdn.rsc
/import iptv-all.rsc
:if ([:len [/system scheduler find name="auto-update-all"]] = 0) do={
/system scheduler add name="auto-update-all" start-time=03:00:00 interval=1d on-event="/import auto-update-all.rsc"
}
