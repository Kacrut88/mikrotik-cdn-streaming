/log info "Update IPTV"
/local providers {"telkom";"biznet";"myrepublic";"transvision"}
:foreach p in=$providers do={
:local f ("iptv-" . $p . ".txt")
:local l ("iptv-" . $p)
/tool fetch url=("https://raw.githubusercontent.com/Kacrut88/mikrotik-cdn-streaming/main/full-indonesia/" . $f) mode=https dst-path=$f keep-result=no
:if ([/file find name=$f] != "") do={
:local c [/file get $f contents]
/ip firewall address-list remove [find list=$l]
:foreach line in=[:toarray $c] do={
:if ([:len $line] > 0) do={/ip firewall address-list add list=$l address=$line}
}
 /file remove $f
}
}
