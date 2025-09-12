# MSMNYC VuFind notes

## Indexing
- MARC source: /usr/local/vufind/incoming/marc/msmnyc-catalog-full-2025-04-09-10-34-56.mrc
- Local rules: /usr/local/vufind/local/import/marc_local.properties
- Pattern map: /usr/local/vufind/local/import/bibnum_map.map
- Reindex full:
  /usr/local/vufind/import-marc.sh /usr/local/vufind/incoming/marc/msmnyc-catalog-full-2025-04-09-10-34-56.mrc /usr/local/vufind/local/import/marc_local.properties

## Sierra API test
TOKEN=$(curl -s -u "$KEY:$SEC" -d "grant_type=client_credentials" https://library.msmnyc.edu/iii/sierra-api/v5/token | jq -r .access_token)
curl -s -H "Authorization: Bearer $TOKEN" "https://library.msmnyc.edu/iii/sierra-api/v5/bibs/<id>" | jq .

# MSMNYC VuFind Operations

This repository tracks local configuration and indexing rules for the MSMNYC VuFind instance.

## Paths and Layout
- VuFind root: `/usr/local/vufind`
- Local overrides: `/usr/local/vufind/local/`
- MARC source (exports): `/usr/local/vufind/incoming/marc/`
- Indexing rules:
  - `/usr/local/vufind/local/import/marc_local.properties`
  - `/usr/local/vufind/local/import/bibnum_map.map` (pattern map)
- Logs:
  - VuFind: `/var/log/vufind.log`
  - Solr: `/var/solr/logs/` (path may vary)

## MARC Field Conventions (Sierra)
- `001` = OCLC number
- `907$a` = Sierra bib number (e.g., `.b1000001x`)
  - Numeric API ID = strip optional dot and `b`, drop trailing check digit → `1000001`
- `907$b` = Bib location (e.g., `scost`)
- `945$l` = Item location (e.g., `scost`)

## Indexing Rules (Key Mappings)
In `local/import/marc_local.properties`:

```properties  
# ID: ".b1000001x" -> "1000001"  
id = pattern_replace(907a, "^\\.?b([0-9]+).*$", "$1")  
# If pattern_replace not supported, use:  
# bib_raw = 907a  
# id = pattern_map.bibnum_map, bib_raw  

# Locations  
building_facet = 907b  
institution_facet = 907b  
bib_location_str = 907b  
location_facet = 945l  
item_location_str_mv = 945l  

# OCLC  
ctrlnum_str = 001  

TOKEN=$(curl -s -u "$KEY:$SEC" -d "grant_type=client_credentials" https://library.msmnyc.edu/iii/sierra-api/v5/token | jq -r .access_token)

# Replace <id> with numeric bib (e.g., 1000001)
curl -s -H "Authorization: Bearer $TOKEN" "https://library.msmnyc.edu/iii/sierra-api/v5/bibs/<id>" | jq .
curl -s -H "Authorization: Bearer $TOKEN" "https://library.msmnyc.edu/iii/sierra-api/v5/items?bibIds=<id>" | jq .

Reindexing Steps
Sanity-check the export (first record only):
bash
apt-get update -y && apt-get install -y yaz jq
yaz-marcdump -i marc -o marcxml /usr/local/vufind/incoming/marc/msmnyc-catalog-full-YYYY-MM-DD-HH-MM-SS.mrc | head -n 120
Small sample test:
bash
yaz-marcdump -i marc -o marc /usr/local/vufind/incoming/marc/msmnyc-catalog-full-YYYY-MM-DD-HH-MM-SS.mrc \
  | head -c 60000 > /tmp/sample.mrc

/usr/local/vufind/import-marc.sh /tmp/sample.mrc /usr/local/vufind/local/import/marc_local.properties

curl -s 'http://127.0.0.1:8983/solr/biblio/select?q=*:*&rows=5&fl=id,building_facet,location_facet,ctrlnum_str&wt=json&indent=true' | jq .
Full reindex:
bash
# Optional: wipe index if IDs are wrong
php /usr/local/vufind/harvest/batch-delete.php --query '*:*'

# Index full file
/usr/local/vufind/import-marc.sh /usr/local/vufind/incoming/marc/msmnyc-catalog-full-YYYY-MM-DD-HH-MM-SS.mrc /usr/local/vufind/local/import/marc_local.properties

# Clear caches and restart web
rm -rf /usr/local/vufind/local/cache/*
systemctl restart apache2
Verify a known record in VuFind and tail logs:
bash
# Replace 1000001 with an indexed numeric bib
echo "http://YOUR-HOST/vufind/Record/1000001"
tail -f /var/log/vufind.log
Git Backup Workflow
Before any config/indexing change:

bash
cd /usr/local/vufind
