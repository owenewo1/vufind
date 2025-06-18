#!/bin/bash
set -x

# Print detailed class loading information
/usr/lib/jvm/java-21-openjdk-amd64/bin/java \
    --add-opens java.base/java.lang=ALL-UNNAMED \
    -verbose:class \
    -cp "/usr/local/vufind/import/solrmarc_core_3.5.jar:/usr/local/vufind/import/lib/classgraph-4.8.162.jar" \
    org.solrmarc.index.utils.ClasspathUtils
