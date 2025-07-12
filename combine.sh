DEST=quran-combined.db
rm -f "$DEST" # wipe any previous run

for db in \
  qpc-v1-15-lines.db \
  qpc-v1-glyph-codes-wbw.db \
  quran-metadata-ayah.db \
  quran-metadata-surah-name.db \
  quran-metadata-juz.db; do
  # Dump each source and pipe into the destination
  sqlite3 "$db" .dump | sqlite3 "$DEST"
done
