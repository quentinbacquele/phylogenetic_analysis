#!/usr/bin/env python3

import csv
from collections import defaultdict
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
RAW_DIR = PROJECT_ROOT / "data" / "raw"
PROCESSED_DIR = PROJECT_ROOT / "data" / "processed"

INPUT_FULL = RAW_DIR / "traits_data_pc_gmm_8components_proba.csv"
INPUT_100SPECIES = RAW_DIR / "traits_data_pc_gmm_8components_proba_100species.csv"
FAMILY_SPLIT = RAW_DIR / "unique_families_corrected.txt"

# Keep the same eligibility rule used previously: minimum 30 samples and
# minimum 10 unique recordings (file_name) per species.
MIN_SAMPLES = 30
MIN_UNIQUE_FILES = 10
TARGET_PER_SPECIES = 30

OUTPUT_MIN30_UNCAPPED = PROCESSED_DIR / "traits_data_pc_gmm_8components_proba_min30_uncapped_with_oscine.csv"
OUTPUT_MIN30_CAP30 = PROCESSED_DIR / "traits_data_pc_gmm_8components_proba_min30_cap30_with_oscine.csv"
OUTPUT_100SPECIES = PROCESSED_DIR / "traits_data_pc_gmm_8components_proba_100species_with_oscine.csv"


def load_family_split(path: Path) -> dict[str, str]:
    family_to_group: dict[str, str] = {}
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line:
            continue
        if line.endswith(" Non-Oscines"):
            family_to_group[line[: -len(" Non-Oscines")]] = "Non-Oscines"
        elif line.endswith(" Oscines"):
            family_to_group[line[: -len(" Oscines")]] = "Oscines"
    return family_to_group


def species_eligible(rows: list[dict[str, str]]) -> bool:
    if len(rows) < MIN_SAMPLES:
        return False
    unique_files = {r["file_name"] for r in rows}
    return len(unique_files) >= MIN_UNIQUE_FILES


def select_all30_max_file_diversity(rows: list[dict[str, str]]) -> list[dict[str, str]]:
    # Group rows by recording file and preserve first-seen file order.
    by_file: dict[str, list[dict[str, str]]] = defaultdict(list)
    file_order: list[str] = []
    seen_files: set[str] = set()
    for r in rows:
        fn = r["file_name"]
        by_file[fn].append(r)
        if fn not in seen_files:
            seen_files.add(fn)
            file_order.append(fn)

    # First pass: take at most one row per file (maximizes unique files in sample).
    selected: list[dict[str, str]] = []
    used_per_file: dict[str, int] = defaultdict(int)
    for fn in file_order:
        if len(selected) >= TARGET_PER_SPECIES:
            break
        selected.append(by_file[fn][0])
        used_per_file[fn] = 1

    # Additional passes: round-robin by file to fill remaining slots.
    while len(selected) < TARGET_PER_SPECIES:
        progressed = False
        for fn in file_order:
            i = used_per_file[fn]
            if i < len(by_file[fn]):
                selected.append(by_file[fn][i])
                used_per_file[fn] += 1
                progressed = True
                if len(selected) >= TARGET_PER_SPECIES:
                    break
        if not progressed:
            # Safety fallback: should never happen for eligible species (>=30 rows).
            break
    return selected


def read_csv_with_oscine(path: Path, family_to_group: dict[str, str]) -> tuple[list[dict[str, str]], list[str]]:
    rows: list[dict[str, str]] = []
    with path.open(newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        fieldnames = list(reader.fieldnames or [])
        for row in reader:
            family = row["family"]
            row["oscine_group"] = family_to_group.get(family, "Unknown")
            rows.append(row)
    if "oscine_group" not in fieldnames:
        fieldnames.append("oscine_group")
    return rows, fieldnames


def write_csv(path: Path, fieldnames: list[str], rows: list[dict[str, str]]) -> None:
    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def main() -> None:
    PROCESSED_DIR.mkdir(parents=True, exist_ok=True)

    family_to_group = load_family_split(FAMILY_SPLIT)

    # Load full table with oscine label once, then derive min30-eligible outputs.
    full_rows, fieldnames = read_csv_with_oscine(INPUT_FULL, family_to_group)

    rows_by_species: dict[str, list[dict[str, str]]] = defaultdict(list)
    for row in full_rows:
        rows_by_species[row["species"]].append(row)

    eligible_species = [sp for sp, rows in rows_by_species.items() if species_eligible(rows)]
    eligible_species.sort()

    min30_uncapped_rows: list[dict[str, str]] = []
    min30_cap30_rows: list[dict[str, str]] = []
    unknown_family_species = 0

    for sp in eligible_species:
        rows = rows_by_species[sp]
        min30_uncapped_rows.extend(rows)
        min30_cap30_rows.extend(select_all30_max_file_diversity(rows))
        if rows[0]["oscine_group"] == "Unknown":
            unknown_family_species += 1

    # 1) min30_uncapped = min-30-eligible species, no max cap
    write_csv(OUTPUT_MIN30_UNCAPPED, fieldnames, min30_uncapped_rows)

    # 2) min30_cap30 = same eligible species, capped to 30 rows/species
    write_csv(OUTPUT_MIN30_CAP30, fieldnames, min30_cap30_rows)

    # 3) 100-species table + oscine label
    rows_100, fieldnames_100 = read_csv_with_oscine(INPUT_100SPECIES, family_to_group)
    write_csv(OUTPUT_100SPECIES, fieldnames_100, rows_100)

    print(f"Eligible species: {len(eligible_species)}")
    print(f"Unknown-family species: {unknown_family_species}")
    print(f"Min30 uncapped rows written: {len(min30_uncapped_rows)} -> {OUTPUT_MIN30_UNCAPPED}")
    print(f"Min30 cap30 rows written: {len(min30_cap30_rows)} -> {OUTPUT_MIN30_CAP30}")
    print(f"100-species rows written: {len(rows_100)} -> {OUTPUT_100SPECIES}")


if __name__ == "__main__":
    main()
