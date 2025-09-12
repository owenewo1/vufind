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

