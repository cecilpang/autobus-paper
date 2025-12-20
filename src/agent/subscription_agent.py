import os
from agents import Agent
from agents.tool import function_tool
import sqlite3
from config import PROLOG_TEMPLATE_DIR, GENERATED_PROLOG_DIR, DB_PATH


LLM = "gpt-5.2"
AGENT_NAME = "subscription_agent"


@function_tool
async def get_prolog_template(template_name:str) -> str:
    """
    Given a template name, return the Prolog template.
    """
    template = None
    file_path = os.path.join(PROLOG_TEMPLATE_DIR, template_name)
    with open(file_path, "r") as f:
        template = f.read()
    return template

@function_tool
async def get_db_schema(db_path:str=DB_PATH) -> str:
    """
    Return the schema of the database as DDL statements (CREATE TABLE/INDEX/etc.).
    The result is a single string containing all DDL statements separated by blank lines.
    """
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # Get all user-defined schema objects (tables, indexes, views, triggers),
    # skipping SQLite's internal tables
    cursor.execute("""
        SELECT type, name, sql
        FROM sqlite_master
        WHERE name NOT LIKE 'sqlite_%'
          AND sql IS NOT NULL
        ORDER BY type, name
    """)

    statements = []
    for obj_type, name, sql in cursor.fetchall():
        # Ensure each statement ends with a semicolon
        sql = sql.strip()
        if not sql.endswith(";"):
            sql += ";"
        statements.append(sql)

    conn.close()

    return "\n\n".join(statements)

@function_tool
async def save_text_to_file(text:str, filepath:str, encoding:str="utf-8") -> None:
    """
    Save the given text to a file.

    :param text: The text content to write.
    :param filepath: Path to the file to write.
    :param encoding: Text encoding (default: 'utf-8').
    """
    with open(filepath, "w", encoding=encoding) as f:
        f.write(text)


subscription_agent = Agent(
    name=AGENT_NAME,
    instructions=f"""
    You are an expert in logic programming in SWI-Prolog. Generate prolog programs with facts and 
    foundational rules based on the database schema and task specific rules from the user prompt.
    Use the Prolog template 'facts_rules_actions_template.pl'. 
    Get the Task ID from the user prompt and save the program to a file with path {GENERATED_PROLOG_DIR+'/<Task ID>_logic.pl'}.
    If you fail to get the prolog template or the database schema, stop and output error message.
    """,
    tools=[get_db_schema, get_prolog_template, save_text_to_file],
    model = LLM,
)