:global url_indihome "https://raw.githubusercontent.com/Kacrut88/mikrotik-cdn-streaming/main/iptv/indihome.txt"
:global url_transvision "https://raw.githubusercontent.com/Kacrut88/mikrotik-cdn-streaming/main/iptv/transvision.txt"
:global url_biznet "https://raw.githubusercontent.com/Kacrut88/mikrotik-cdn-streaming/main/iptv/biznet.txt"
:global url_mr "https://raw.githubusercontent.com/Kacrut88/mikrotik-cdn-streaming/main/iptv/myrepublic.txt"
:global url_stream "https://raw.githubusercontent.com/Kacrut88/mikrotik-cdn-streaming/main/streaming/cdn-full.txt"

/tool fetch url=$url_indihome dst-path=indihome.txt
/tool fetch url=$url_transvision dst-path=transvision.txt
/tool fetch url=$url_biznet dst-path=biznet.txt
/tool fetch url=$url_mr dst-path=myrepublic.txt
/tool fetch url=$url_stream dst-path=streaming.txt

/ip firewall address-list remove [find comment="auto"]

:foreach x in={"indihome";"transvision";"biznet";"myrepublic";"streaming"} do={
 :local f "$x.txt"
 :local c [/file get $f contents]
 :foreach line in=[:toarray $c] do={
  :if ([:len $line] > 0) do={
   /ip firewall address-list add list=("iptv-" . $x) address=$line comment="auto"
  }
 }
}

/ip firewall raw remove [find comment="iptvstream"]

/ip firewall raw add chain=prerouting src-address-list=iptv-indihome action=accept comment="iptvstream"
/ip firewall raw add chain=prerouting dst-address-list=iptv-indihome action=accept comment="iptvstream"

 /ip firewall raw add chain=prerouting src-address-list=iptv-transvision action=accept comment="iptvstream"
/ip firewall raw add chain=prerouting dst-address-list=iptv-transvision action=accept comment="iptvstream"

 /ip firewall raw add chain=prerouting src-address-list=iptv-biznet action=accept comment="iptvstream"
/ip firewall raw add chain=prerouting dst-address-list=iptv-biznet action=accept comment="iptvstream"

 /ip firewall raw add chain=prerouting src-address-list=iptv-myrepublic action=accept comment="iptvstream"
/ip firewall raw add chain=prerouting dst-address-list=iptv-myrepublic action=accept comment="iptvstream"

 /ip firewall raw add chain=prerouting src-address-list=iptv-streaming action=accept comment="iptvstream"
/ip firewall raw add chain=prerouting dst-address-list=iptv-streaming action=accept comment="iptvstream"

 /ip firewall raw add chain=prerouting protocol=udp dst-port=1900,5353,8000-9000 action=accept comment="iptvstream"
/ip firewall raw add chain=prerouting protocol=udp src-port=1900,5353,8000-9000 action=accept comment="iptvstream"

 /ip firewall raw add chain=prerouting protocol=igmp action=accept comment="iptvstream"

 /ip firewall raw add chain=prerouting protocol=tcp dst-port=80,443 action=accept comment="iptvstream"
/ip firewall raw add chain=prerouting protocol=tcp src-port=80,443 action=accept comment="iptvstream"

/ip firewall mangle remove [find comment="iptvstream"]

/ip firewall mangle add chain=prerouting src-address-list=iptv-streaming action=mark-connection new-connection-mark=stream_conn passthrough=yes comment="iptvstream"
/ip firewall mangle add chain=prerouting connection-mark=stream_conn action=mark-packet new-packet-mark=stream_pkt passthrough=no comment="iptvstream"

 /ip firewall mangle add chain=prerouting src-address-list=iptv-indihome action=mark-connection new-connection-mark=ih_conn passthrough=yes comment="iptvstream"
/ip firewall mangle add chain=prerouting connection-mark=ih_conn action=mark-packet new-packet-mark=ih_pkt passthrough=no comment="iptvstream"

 /ip firewall mangle add chain=prerouting src-address-list=iptv-transvision action=mark-connection new-connection-mark=tv_conn passthrough=yes comment="iptvstream"
/ip firewall mangle add chain=prerouting connection-mark=tv_conn action=mark-packet new-packet-mark=tv_pkt passthrough=no comment="iptvstream"

/queue tree remove [find]

/queue tree add name=streaming parent=global packet-mark=stream_pkt max-limit=100M priority=1
/queue tree add name=iptv-ih parent=global packet-mark=ih_pkt max-limit=100M priority=1
/queue tree add name=iptv-tv parent=global packet-mark=tv_pkt max-limit=100M priority=1

/queue simple remove [find]

/queue simple add name=STREAMING target="" max-limit=50M/50M packet-marks=stream_pkt

/ip dns static remove [find comment="iptvstream"]

/ip dns static add name="useetv.com" address=0.0.0.0 comment="iptvstream"
/ip dns static add name="cdn.ontv.id" address=0.0.0.0 comment="iptvstream"
/ip dns static add name="iptv.transvision.co.id" address=0.0.0.0 comment="iptvstream"
/ip dns static add name="hbo.max.com" address=0.0.0.0 comment="iptvstream"
/ip dns static add name="netflix.com" address=0.0.0.0 comment="iptvstream"
/ip dns static add name="disneyplus.com" address=0.0.0.0 comment="iptvstream"

/system scheduler remove [find name="auto-iptvstream"]

/system scheduler add name="auto-iptvstream" interval=1h on-event="/import all-in-one-iptv-streaming.rsc"
