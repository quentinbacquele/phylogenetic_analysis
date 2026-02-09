# Phylogenetic Acoustic Analysis

This repository combines:

1. Acoustic trait tables for passerine song recordings
2. Phylogenetic trees aligned to those species sets

## Shared Deliverables

Only these files are intended for sharing.

### Processed Data (`data/processed`)

1. `traits_data_pc_gmm_8components_proba_100species_with_oscine.csv`
2. `traits_data_pc_gmm_8components_proba_min30_cap30_with_oscine.csv`
3. `traits_data_pc_gmm_8components_proba_min30_uncapped_with_oscine.csv`

### Phylogeny (`data/phylogeny`)

1. `consensus_tree_100species.tre`
2. `consensus_tree_min30.tre`

## Dataset Definitions

### `100species_with_oscine`

- Curated 100-species subset
- 3,392 rows
- Species are the same as the original 100-species table, plus `oscine_group`

### `min30_cap30_with_oscine`

- Species eligibility:
1. at least 30 total samples per species
2. at least 10 unique recordings (`file_name`) per species
- Row cap: exactly 30 rows per species
- Downsampling strategy: maximize recording diversity by selecting distinct `file_name` first, then filling remaining rows round-robin by file

### `min30_uncapped_with_oscine`

- Same eligible species as `min30_cap30_with_oscine`
- No per-species upper cap on rows
- Keeps all available rows for each eligible species

## Column Summary

Core metadata:

- `gen`, `family`, `species`, `sub_species`, `common_name`
- `recordist`, `date`, `time`, `country`, `location`, `lat`, `lng`
- `bird`, `file_name`, `weights`

Acoustic features:

- `PC1` ... `PC37` (weighted PCA components from MPS representations)
- `gmm_cluster` and `gmm_prob_0` ... `gmm_prob_7` (8-component GMM motif model)

Taxonomic split:

- `oscine_group` in `{Oscines, Non-Oscines}` from `data/raw/unique_families_corrected.txt`

## Phylogeny Notes

- Trees are pruned from a larger consensus tree.
- Species matching uses direct name matching plus synonym-based matching.
- `consensus_tree_100species.tre` corresponds to the 100-species dataset.
- `consensus_tree_min30.tre` corresponds to the min30 species set (used by both min30 tables).
- Mapping CSVs are generated as internal build artifacts and are not part of shared deliverables.

## Rebuild

From repository root:

```bash
python scripts/create_oscine_versions.py
```

```bash
Rscript scripts/create_pruned_tree.R
```

Build min30 tree explicitly:

```bash
TRAIT_FILE=./data/processed/traits_data_pc_gmm_8components_proba_min30_uncapped_with_oscine.csv \
OUTPUT_TREE_FILE=./data/phylogeny/consensus_tree_min30.tre \
OUTPUT_MAPPING_FILE=./data/phylogeny/species_tree_mapping_min30.csv \
Rscript scripts/create_pruned_tree.R
```
