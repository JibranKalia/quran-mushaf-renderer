DEST=quran-combined.db

for db in \
  quran-metadata-hizb.db \
  quran-metadata-manzil.db \
  quran-metadata-rub.db \
  quran-metadata-ruku.db \
  quran-metadata-sajda.db; do
  sqlite3 "$db" .dump | sqlite3 "$DEST"
done
