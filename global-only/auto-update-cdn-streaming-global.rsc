# Auto-update master script (Global-only)
/log info "Starting auto-update (global-only)..."

:local cdnSources {
    "youtube=https://raw.githubusercontent.com/Kacrut88/mikrotik-cdn-streaming/main/global-only/youtube-cdn-list.txt";
    "netflix=https://raw.githubusercontent.com/Kacrut88/mikrotik-cdn-streaming/main/global-only/netflix-cdn-list.txt";
    "disney=https://raw.githubusercontent.com/Kacrut88/mikrotik-cdn-streaming/main/global-only/disney-cdn-list.txt";
    "hbo=https://raw.githubusercontent.com/Kacrut88/mikrotik-cdn-streaming/main/global-only/hbo-cdn-list.txt";
    "tiktok=https://raw.githubusercontent.com/Kacrut88/mikrotik-cdn-streaming/main/global-only/tiktok-cdn-list.txt";
    "spotify=https://raw.githubusercontent.com/Kacrut88/mikrotik-cdn-streaming/main/global-only/spotify-cdn-list.txt";
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
:if ([:len [find name="auto-update-cdn-global"]] = 0) do={
    add name="auto-update-cdn-global" start-time=03:00:00 interval=1d on-event="/import auto-update-cdn-streaming-global.rsc" comment="Auto update CDN global"
}

/log info "Auto-update (global-only) completed."
