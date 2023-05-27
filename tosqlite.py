#!/usr/bin/env python3
# -*- encoding: utf-8 -*-

import sqlite3
import sys
from pathlib import Path

import pandas

DBPATH = Path('db.sqlite3')


def main():
    if not DBPATH.is_file():
        with sqlite3.connect(DBPATH) as conn:
            cur = conn.cursor()
            cur.execute("""
                CREATE TABLE linear_regressions (
                    tablename VARCHAR(255) NOT NULL,
                    field_x VARCHAR(255) NOT NULL,
                    field_y VARCHAR(255) NOT NULL,
                    slope DOUBLE NOT NULL,
                    intercept DOUBLE NOT NULL,
                    PRIMARY KEY (tablename, field_x, field_y)
                );
            """)
    for file in sys.argv[1:]:
        if not Path(file).is_file():
            raise FileNotFoundError(file)
    with sqlite3.connect(DBPATH) as conn:
        for file in sys.argv[1:]:
            conn.execute(f'drop table if exists {Path(file).stem};').close()
            pd = pandas.read_csv(Path(file))
            pd.to_sql(Path(file).stem, conn)


if __name__ == '__main__':
    main()
