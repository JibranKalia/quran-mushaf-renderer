#!/usr/bin/env python3

import sqlite3

# Hardcoded paths
COMBINED_DB = "quran-combined.db"
NASTALEEQ_DB = "/Users/jibran.kalia/side/quran_render_poc/qpc-nastaleeq.db"
COLUMN_NAME = "qpc_nastaleeq"

# Connect to both databases
combined_conn = sqlite3.connect(COMBINED_DB)
combined_cursor = combined_conn.cursor()

nastaleeq_conn = sqlite3.connect(NASTALEEQ_DB)
nastaleeq_cursor = nastaleeq_conn.cursor()

# Get all text data from nastaleeq database
nastaleeq_cursor.execute("SELECT location, text FROM words")
nastaleeq_data = nastaleeq_cursor.fetchall()

# Update combined database
update_count = 0
for location, text in nastaleeq_data:
    combined_cursor.execute(
        f"UPDATE words SET {COLUMN_NAME} = ? WHERE location = ?",
        (text, location)
    )
    update_count += 1
    
    if update_count % 1000 == 0:
        print(f"Updated {update_count} records...")

# Commit and close
combined_conn.commit()
combined_conn.close()
nastaleeq_conn.close()

print(f"Done! Updated {update_count} total records.")
