import random
import sys
import unicodedata
from typing import Dict, List, Set, Tuple

import click

IF_RANDOM_SCALE_BY = 50

UNICODE_CATEGORIES = {"Cc", "Cf", "Cs"}
CONTROL_CHARS = {
    chr(c)
    for c in range(sys.maxunicode)
    if unicodedata.category(chr(c)) in UNICODE_CATEGORIES
}

GEO_LETTERS = "აბგდევზთიკლმნოპჟრსტუფქღყშჩცძწჭხჯჰ"
ENG_LETTERS = "abgdevzTiklmnopJrstufqRySCcZwWxjh"
GEO_TO_ENG_MAP = {g: e for g, e in zip(GEO_LETTERS, ENG_LETTERS)}


def read_file(file_path: str) -> str:
    with open(file_path, "r", encoding="utf-8") as reader:
        return reader.read()


def write_file(file_path: str, data: str) -> None:
    with open(file_path, "w", encoding="utf-8") as writer:
        writer.write(data)


def clean_str(word: str, by_set: Set[str] = CONTROL_CHARS) -> str:
    return "".join(filter(lambda c: c not in by_set, word))


def replace_chars(word: str, by_dict: Dict[str, str] = GEO_TO_ENG_MAP) -> str:
    return "".join(by_dict[c] if c in by_dict else c for c in word)


def handle_file(file_path: str) -> List[Tuple[str, str, int]]:
    content = read_file(file_path)
    result: List[Tuple[str, str, int]] = []
    for line in content.split():
        word, freq = clean_str(line).rsplit(",", 1)
        result.append((word, replace_chars(word), int(freq)))
    return result


def create_sql_script(proc_lines: List[Tuple[str, str, int]], drop_random: bool) -> str:
    table_name = "tomara.words"
    column_names = ["word_geo", "word_eng", "frequency"]
    value_lines = [""]
    for i, (word_geo, word_eng, freq) in enumerate(proc_lines):
        word_geo = word_geo.replace("'", "''")
        word_eng = word_eng.replace("'", "''")
        value_lines.append(
            f"('{word_geo}', '{word_eng}', {freq})"
            + (";" if i == len(proc_lines) - 1 else ",")
        )
    if drop_random:
        value_lines_new = [value_lines[0]]
        value_lines_new.extend(
            random.choices(value_lines[1:-1], k=len(value_lines) // IF_RANDOM_SCALE_BY)
        )
        value_lines_new.append(value_lines[-1])
        value_lines = value_lines_new
    values_sql = "\n\t".join(value_lines)
    return f"""
INSERT INTO {table_name}({", ".join(column_names)})
VALUES{values_sql}
    """.strip()


@click.command()
@click.option(
    "--input_file",
    "-I",
    type=str,
    required=True,
    help="File with row format: <Word>,<Freq>",
)
@click.option(
    "--output_file",
    "-O",
    type=str,
    required=True,
    help="Out sql file",
)
@click.option("--drop-random", is_flag=True, default=False)
def main(input_file: str, output_file: str, drop_random: bool) -> None:
    proc_lines = handle_file(input_file)
    sql_script = create_sql_script(proc_lines, drop_random)
    write_file(output_file, sql_script)


if __name__ == "__main__":
    main()
