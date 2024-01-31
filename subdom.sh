#!/bin/bash
#
#

#Colours
bold="\e[1m"
Underlined="\e[4m"
red="\e[31m"
green="\e[32m"
blue="\e[34m"
end="\e[0m"
VERSION="SubDom-0.5"

echo -e "$blue${bold}    _____         __     ____                   $end"
echo -e "$blue${bold}   / ___/ __  __ / /_   / __ \ ____   ________  $end"
echo -e "$blue${bold}   \__ \ / / / // __ \ / / / // __ \ / __  __ \ $end"
echo -e "$blue${bold}  ___/ // /_/ // /_/ // /_/ // /_/ // / / / / /$end"
echo -e "$blue${bold} /____/ \__,_//_.___//_____/ \____//_/ /_/ /_/ $end"
echo -e "$end"
echo -e "$blue${bold}        All in One Subdomain Enumeration Tool         $end"
echo -e "$blue${bold}             Made with${end} ${red}${bold}<3${end} ${blue}${bold}by 0x3hIrsh8k              $end"
echo -e "$end"

PRG=${0##*/}

#Tools
Usage(){
    while read -r line; do
        printf "%b\n" "$line"
    done <<-EOF
    \r
    \r ${bold}Options${end}:
    \r    -d ==> Domain to enumerate
    \r    -o ==> Output file to save the final results
    \r    -h ==> Display this help message and exit
    \r    -v ==> Display the version and exit

EOF
    exit 1
}

# Variables
# Add your api keys, tokens here
subfinder=~/.config/subfinder/provider-config.yaml
amass=~/config-resolvers/config.ini
wordlist=~/SubDomz/dns-wordlist.txt
resolvers=~/SubDomz/resolvers.txt
GITHUB_TOKEN="APIKEY"
GITLAB_TOKEN="APIKEY"
SHODAN_APIKEY="APIKEY"
CENSYS_ID="APIKEY"
CENSYS_SECRET="APIKEY"
CHAOS_APIKEY="APIKEY"
SECURITY_TRAILS_APIKEY="APIKEY"
SUBS_LIST=~/wordlist/subdomains-1000.txt

RunEnumeration() {
    local func_name="$1"
    echo -e "\n${bold}Running $func_name...${end}\n"
}
sleep 30
# Tools
Crt() {
    RunEnumeration "Crt"
    #curl -sk "https://crt.sh/?q=$domain&exclude=expired&group=none" > $domain-crt
    curl -s https://crt.sh/\?q\=$domain\&output\=json | jq . | grep name | cut -d ":" -f2 | grep -v "CN=" | cut -d'"' -f2 | awk '{gsub(/\\n/,"\n");}1;' | sort -u > $domain-crt.txt
}
sleep 5

nMap() {
    RunEnumeration "nmap"
    nmap --script hostmap-crtsh.nse $domain | grep -oP '^[^.]+(?:\.[^.]+)+' > $domain-nmap.txt
}
sleep 5
Subfinder() {
    RunEnumeration "Subfinder"
    subfinder -all -d "$domain" -pc "$subfinder" -silent > $domain-subfinder.txt
}
sleep 5
Assetfinder() {
    RunEnumeration "Assetfinder"
    assetfinder --subs-only "$domain" > $domain-assetfinder.txt
}
sleep 5
Chaos() {
    RunEnumeration "Chaos"
    chaos -d "$domain" -key "$CHAOS_APIKEY" > $domain-chaos.txt
}
sleep 5
#Shuffledns() {
#    RunEnumeration "Shuffledns"
#    shuffledns -silent -d "$domain" -w "$wordlist" -r "$resolvers" > $domain-shuffle.txt
#}
sleep 5
Findomain() {
RunEnumeration "Findomain"
    findomain --target $domain --quiet > $domain-findomain.txt
}
sleep 5
Amass_Passive() {
    RunEnumeration "Amass Passive"
    amass enum -d $domain -config $amass > $domain-amass.txt
}
sleep 5
Gau() {
    RunEnumeration "Gau"
    gau --subs $domain | unfurl -u domains > $domain-gau.txt 
}
sleep 5
Waybackurls() {
    RunEnumeration "Waybackurls"
    waybackurls $domain |  unfurl -u domains > $domain-wayback.txt
}
#sleep 5
#Github-Subdomains() {
#    RunEnumeration "Github-Subdomains"
#    github-subdomains -d $domain -t $GITHUB_TOKEN | unfurl domains > $domain-gitsub.txt 
#}
#sleep 5
#Gitlab-Subdomains() {
#    RunEnumeration "Gitlab-Subdomains"
#    gitlab-subdomains -d $domain -t $GITLAB_TOKEN | unfurl domains > $domain-gitlabsub.txt 
#}
sleep 5
Cero() {
    RunEnumeration "Cero"
    cero $domain > $domain-cero.txt
}
sleep 5

Censys(){
    RunEnumeration "Censys"
    python3 /home/kali/Desktop/github/censys-subdomain-finder/censys-subdomain-finder.py $domain -o censys-results-$domain
}
sleep 5

Dome(){
    RunEnumeration "Dome"
    python3 /home/kali/Desktop/github/Dome/dome.py -m passive -d $domain -t 15 -r $resolvers -o > $domain-dome.txt
    sleep 10
}
sleep 5
#Online_Services
Archive() {
    RunEnumeration "Archive"
    curl -sk "http://web.archive.org/cdx/search/cdx?url=*.$domain&output=txt&fl=original&collapse=urlkey&page=" | awk -F/ '{gsub(/:.*/, "", $3); print $3}' | sort -u > $domain-arch.txt 
}

sleep 5
SecurityTrails(){
    RunEnumeration "SecurityTrails"
    curl -s --request GET \
         --url https://api.securitytrails.com/v1/domain/$domain/subdomains \
         --header 'APIKEY: <api-key>' \
         --header 'Accept: application/json' > $domain-sectrails.txt
}
sleep 5
CertSpotter() {
    RunEnumeration "CertSpotter"
    curl -sk "https://api.certspotter.com/v1/issuances?domain=$domain&include_subdomains=true&expand=dns_names" | jq .[].dns_names | grep -Po "(([\w.-]*)\.([\w]*)\.([A-z]))\w+" > $domain-certspotter.txt
}
sleep 5
JLDC() {
    RunEnumeration "JLDC"
    curl -sk "https://jldc.me/anubis/subdomains/$domain" | grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" > $domain-jldc.txt
}
sleep 5

#ThreatCrowd() {
#   RunEnumeration "ThreatCrowd"
#   curl -sk "https://www.threatcrowd.org/searchApi/v2/domain/report/?domain=$domain" | jq -r '.subdomains' | grep -o "\w.*$domain" | tee $domain-subs.txt "$domain"-subs.txt
#}
sleep 5
Shodan() {
    RunEnumeration "Shodan"
    shodan search "$forshodan" | grep Location > $domain-shodan.txt
}
Ffuf() {
    RunEnumeration "Ffuf"
    ffuf -u https://FUZZ.$domain -w $SUBS_LIST -mc 200 -t 10 -of html -o results.html > $domain-ffuf.txt
}
sleep 5

        
# Output
OUT() {
    local date=$(date +'%Y-%m-%d')
    local out="$domain-$date.txt"
    
    if [ -n "$1" ]; then
        out="$domain-$1.txt"
    fi
}

# Main
Main() {
    if [ -z "$domain" ]; then
        echo -e "${red}[-] Argument -d is required!$end"
        Usage
    fi

    nMap
    Subfinder
    Assetfinder
    Chaos
    ShuffleDNS
    Findomain
    Amass_Passive
    Gau
    Waybackurls
    Cero
    Censys
    Dome
    Archive
    SecurityTrails
    Crt
    CertSpotter
    JLDC
    Shodan
    Ffuf

    OUT "$out"  # Call OUT function with the output file name
}

# Parse command-line arguments
while [ -n "$1" ]; do
    case $1 in
        -d)
            domain="$2"
            forshodan=$(echo "$domain" | awk -F[/.] '{print $(NF-1)}')
            shift ;;
        -o)
            out="$2"
            shift ;;
        -h | --help)
            Usage ;;
        -v)
            echo "Version: $VERSION"
            exit 0 ;;
        *)
            echo "[-] Unknown Option: $1"
            Usage ;;
    esac
    shift
done


Main

#cat $domain-subs.txt | awk -F, '!/nmap|seconds|error/ {gsub(/[^a-zA-Z0-9.-]/, "", $1); if (split($1, arr, ".") > 2) print $1}' | tee $domain-filtered-subs

# Function to send results to Discord webhook
send_to_discord() {
    local webhook_url="$1"
    local results_file="$2"
    local chunk_size=2000
    
    # Read the results file into a variable
    results=$(cat "$results_file")

    # Split the content into chunks of 2000 characters and send each chunk
    while [ -n "$results" ]; do
        chunk=$(echo "$results" | head -c "$chunk_size")
        results=$(echo "$results" | tail -c +$((chunk_size + 1)))
        
        # Build the JSON payload with jq
        payload=$(jq -n --arg content "$chunk" '{"content": $content}')

        # Use curl to send the payload to Discord webhook
        curl -H "Content-Type: application/json" \
             -X POST \
             --data "$payload" \
             "$webhook_url"
    done
}

# Discord webhook URL (replace with your actual Discord webhook URL)
discord_webhook_url="https://discord.com/api/webhooks/../"

# Send results to Discord
#send_to_discord "$discord_webhook_url" "$domain-subs.txt"
#cat $domain-subs.txt | notify -p telegram

cat $domain-sectrails.txt | jq -r '.subdomains[] | "\(.).$domain"' > sectrails-$domain.txt
#cat $domain-crt | grep -Eo '>[^<]*\.$domain<' | sed 's/[><]//g' | anew > crt-$domain.txt


# Array of filenames based on the domain
#files=(
#    "sectrails-$domain.txt"
#    "censys-results-$domain"
#    "$domain-amass.txt"
#    "$domain-arch.txt"
#    "$domain-assetfinder.txt"
#    "$domain-cero.txt"
#    "$domain-certspotter.txt"
#    "$domain-chaos.txt"
#    "$domain-crt.txt"
#    "$domain-dome.txt"
#    "$domain-ffuf.txt"
#    "$domain-findomain.txt"
#    "$domain-gau.txt"
#    "$domain-jldc.txt"
#    "$domain-nmap.txt"
#    "$domain-shodan.txt"
#    "$domain-shuffle.txt"
#    "$domain-subfinder.txt"
#    "$domain-wayback.txt" 
#)
#done
