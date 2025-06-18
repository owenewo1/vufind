#!/bin/bash
/usr/lib/jvm/java-21-openjdk-amd64/bin/java \
    --add-opens java.base/java.lang=ALL-UNNAMED \
    -Xms1024m -Xmx2048m \
    -cp "/usr/local/vufind/import/solrmarc_core_3.5.jar:/usr/local/vufind/import/lib/classgraph-4.8.162.jar" \
    org.solrmarc.driver.IndexDriver \
    -reader_opts /usr/local/vufind/import/import.properties \
    -dir /usr/local/vufind/import,/usr/local/vufind/import/import_scripts \
    -solrURL http://localhost:8983/solr/biblio/update \
    -config marc.properties,marc_local.properties \
    "$@"
