/ip firewall mangle remove [find comment~"STREAM"]
/queue tree remove [find name~"Streaming"]

/ip firewall mangle
add chain=forward action=mark-connection new-connection-mark=streaming_conn passthrough=yes src-address-list=youtube comment=STREAM
add chain=forward action=mark-connection new-connection-mark=streaming_conn passthrough=yes src-address-list=netflix comment=STREAM
add chain=forward action=mark-connection new-connection-mark=streaming_conn passthrough=yes src-address-list=disney comment=STREAM
add chain=forward action=mark-connection new-connection-mark=streaming_conn passthrough=yes src-address-list=hbo comment=STREAM
add chain=forward action=mark-connection new-connection-mark=streaming_conn passthrough=yes src-address-list=tiktok comment=STREAM
add chain=forward action=mark-connection new-connection-mark=streaming_conn passthrough=yes src-address-list=spotify comment=STREAM
add chain=forward action=mark-connection new-connection-mark=iptv_conn passthrough=yes src-address-list=iptv-telkom comment=STREAM
add chain=forward action=mark-connection new-connection-mark=iptv_conn passthrough=yes src-address-list=iptv-biznet comment=STREAM
add chain=forward action=mark-connection new-connection-mark=iptv_conn passthrough=yes src-address-list=iptv-myrepublic comment=STREAM
add chain=forward action=mark-connection new-connection-mark=iptv_conn passthrough=yes src-address-list=iptv-transvision comment=STREAM

add chain=forward connection-mark=streaming_conn action=mark-packet new-packet-mark=streaming_pkt passthrough=no comment=STREAM
add chain=forward connection-mark=iptv_conn action=mark-packet new-packet-mark=iptv_pkt passthrough=no comment=STREAM

/queue tree
add name="Streaming-Video" parent=bridge-WAN packet-mark=streaming_pkt priority=1 max-limit=100M limit-at=40M
add name="IPTV" parent=bridge-WAN packet-mark=iptv_pkt priority=1 max-limit=100M limit-at=40M

/queue simple
add name="Streaming-Video-SQ" target=bridge-LAN packet-marks=streaming_pkt max-limit=50M
add name="IPTV-SQ" target=bridge-LAN packet-marks=iptv_pkt max-limit=50M
