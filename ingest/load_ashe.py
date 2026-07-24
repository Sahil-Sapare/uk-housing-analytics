'''
Parse ONS ASHE Table 8.7a spreasheets into a PostgreSQL earnings table.
Reads one file per year from data/ashe/ashe_YYYY/, extracts median gross
annual pay for the 12 UK regions, and loads the combined result (288 rows)
into the `earnings` table.
'''

import glob
import os
import re

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine

# The 9 English regions plus the three other UK nations. Local authorities
# and super-totals (UK, Great Britain, England) are excluded: they sit at
# different levels of the same hierarchy and would double-count.
REGIONS = [
    'North East', 'North West', 'Yorkshire and The Humber',
    'East Midlands', 'West Midlands', 'East', 'London',
    'South East', 'South West', 'Wales', 'Scotland', 'Northern Ireland',
]

# Older releases use a bilingual name for Wales.
RENAME = {'Wales / Cymru': 'Wales'}


def parse_ashe(path):
    """Read one ASHE Table 8.7a file, return 12 regions with median pay and year."""
    year = int(re.search(r'ashe_(\d{4})', path).group(1))

    # header=None: ONS sheets have title and multi-row headers above the data,
    # so columns are referenced by position (0 = area name, 3 = median pay).
    df = pd.read_excel(path, sheet_name='All', header=None)
    df[0] = df[0].astype(str).str.strip().replace(RENAME)

    out = df[df[0].isin(REGIONS)][[0, 3]].copy()
    out.columns = ['region', 'median_pay']
    out['year'] = year

    return out


def main():
    load_dotenv()

    engine = create_engine(
        f"postgresql+psycopg2://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
        f"@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
    )

    files = sorted(glob.glob("data/ashe/*/*8.7a*"))
    if not files:
        raise SystemExit("No ASHE files found under data/ashe/ - see README.")

    earnings = pd.concat([parse_ashe(f) for f in files], ignore_index=True)
    earnings['median_pay'] = earnings['median_pay'].astype(int)

    expected = len(files) * len(REGIONS)
    if len(earnings) != expected:
        raise SystemExit(f"Expected {expected} rows, got {len(earnings)}.")

    earnings.to_sql('earnings', engine, if_exists='replace', index=False)
    print(f"Loaded {len(earnings)} rows from {len(files)} annual releases.")


if __name__ == "__main__":
    main()
