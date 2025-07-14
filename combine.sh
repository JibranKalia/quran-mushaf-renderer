DEST=quran-combined.db

for db in \
  quran-metadata-ayah.db; do
  sqlite3 "$db" .dump | sqlite3 "$DEST"
done
