import sqlite3
import csv
import sys

def preview_all_tables_csv(db_path):
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Get all table names
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
    tables = cursor.fetchall()
    
    for table in tables:
        table_name = table[0]
        print(f"\n=== {table_name} ===")
        
        try:
            cursor.execute(f"SELECT * FROM {table_name} LIMIT 25")
            rows = cursor.fetchall()
            
            # Get column names
            column_names = [description[0] for description in cursor.description]
            
            # Create CSV writer for stdout
            writer = csv.writer(sys.stdout)
            
            # Write header
            writer.writerow(column_names)
            
            # Write rows
            for row in rows:
                writer.writerow(row)
                
        except Exception as e:
            print(f"Error reading table {table_name}: {e}")
    
    conn.close()


preview_all_tables_csv('quran-combined.db')
