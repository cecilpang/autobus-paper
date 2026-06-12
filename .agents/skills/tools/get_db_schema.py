import sqlite3
import os

# Assume the script is run from the project root
DB_PATH = 'database/db.sqlite'

def get_db_schema(db_path=DB_PATH):
    """
    Return the schema of the database as DDL statements.
    """
    if not os.path.exists(db_path):
        print(f"Error: Database file not found at {db_path}")
        return

    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    cursor.execute("""
        SELECT type, name, sql
        FROM sqlite_master
        WHERE name NOT LIKE 'sqlite_%'
          AND sql IS NOT NULL
        ORDER BY type, name
    """)

    statements = []
    for obj_type, name, sql in cursor.fetchall():
        sql = sql.strip()
        if not sql.endswith(";"):
            sql += ";"
        statements.append(sql)

    conn.close()
    print("\n\n".join(statements))

if __name__ == "__main__":
    get_db_schema()
