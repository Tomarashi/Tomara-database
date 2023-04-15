from typing import Optional

import click
import pymysql


def test_my_sql(
    sql_script: str, *, username: str, password: str, database: Optional[str] = None
) -> None:
    with pymysql.connect(
        user=username, password=password, database=database, charset="utf8"
    ) as conn:
        with conn.cursor() as cursor:
            cursor.execute(sql_script)
            print(cursor.fetchall())


@click.command()
@click.option("--username", "-U", type=str, required=True)
@click.option("--password", "-P", type=str, required=True)
@click.option("--database", "-D", default=None)
def main(username: str, password: str, database: Optional[str] = None) -> None:
    # SELECT default_character_set_name FROM information_schema.SCHEMATA S WHERE schema_name = "tomara"
    sql_script = """
        select * from words limit 1
    """
    test_my_sql(sql_script, username=username, password=password, database=database)


if __name__ == "__main__":
    main()
