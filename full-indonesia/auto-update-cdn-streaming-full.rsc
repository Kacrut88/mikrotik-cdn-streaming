# Auto-update master script (Full Indonesia Optimized)
/log info "Starting auto-update (full-indonesia)..."

:local cdnSources {
    "youtube=https://raw.githubusercontent.com/Kacrut88/mikrotik-cdn-streaming/main/full-indonesia/youtube-cdn-list.txt";
    "netflix=https://raw.githubusercontent.com/Kacrut88/mikrotik-cdn-streaming/main/full-indonesia/netflix-cdn-list.txt";
    "disney=https://raw.githubusercontent.com/Kacrut88/mikrotik-cdn-streaming/main/full-indonesia/disney-cdn-list.txt";
    "hbo=https://raw.githubusercontent.com/Kacrut88/mikrotik-cdn-streaming/main/full-indonesia/hbo-cdn-list.txt";
    "tiktok=https://raw.githubusercontent.com/Kacrut88/mikrotik-cdn-streaming/main/full-indonesia/tiktok-cdn-list.txt";
    "spotify=https://raw.githubusercontent.com/Kacrut88/mikrotik-cdn-streaming/main/full-indonesia/spotify-cdn-list.txt";
    "telkom=https://raw.githubusercontent.com/Kacrut88/mikrotik-cdn-streaming/main/full-indonesia/telkom-cdn-list.txt";
}

:foreach item in=$cdnSources do={
    :local parts [:split $item "="]
    :local listName ([:pick $parts 0])
    :local url ([:pick $parts 1])
    :local fileName "$listName-cdn.txt"

    /log info ("Fetching " . $listName . " from " . $url)
    /tool fetch url=$url mode=https dst-path=$fileName keep-result=no
    :delay 1

    :local ids [/ip firewall address-list find list=$listName]
    :if ([:len $ids] > 0) do={ /ip firewall address-list remove $ids }

    :if ([/file find name=$fileName] != "") do={
        :local content [/file get $fileName contents]
        :foreach line in=[:toarray $content] do={
            :local trimLine $line
            :if ([:len $trimLine] > 0) do={
                /ip firewall address-list add list=$listName address=$trimLine comment=("CDN " . $listName)
            }
        }
        /file remove $fileName
        /log info ("Updated " . $listName)
    } else={
        /log warning ("Failed to fetch " . $url)
    }
}

# schedule daily 03:00
/system scheduler
:if ([:len [find name="auto-update-cdn-full"]] = 0) do={
    add name="auto-update-cdn-full" start-time=03:00:00 interval=1d on-event="/import auto-update-cdn-streaming-full.rsc" comment="Auto update CDN full"
}

/log info "Auto-update (full-indonesia) completed."
