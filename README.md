# Phylogenetic Acoustic Analysis

Acoustic trait data and phylogenetic trees for passerine species, built for comparative analyses of song evolution.

## Data overview

Each row represents a single **song segment** extracted from a [Xeno-canto](https://xeno-canto.org/) recording. Every segment is described by:

- **37 PCA components**: a weighted PCA projection of the segment's Modulation Power Spectrum (MPS), capturing the main axes of acoustic variation.
- **8 GMM motif probabilities**: posterior probabilities from a Gaussian Mixture Model fitted in PCA space. Each component represents a recurring acoustic motif type.

All species are labelled as **Oscine** (vocal learners) or **Non-Oscine**, enabling comparisons across this major taxonomic divide.

## Dataset variants

| Dataset | Species | Rows per species | Total rows | Description |
|---|---|---|---|---|
| **100-species** | 100 | All available | 3,392 | Hand-picked species subset, no filtering |
| **min30 capped** | ~1,300 | Exactly 30 | ~43,000 | Balanced design, downsampled for diversity |
| **min30 uncapped** | ~1,300 | All available | ~92,000 | Same species, full data retained |

### 100-species

A curated subset of 100 passerine species used for early analyses. All available segments for these species are included, with no filtering or row constraints.

### min30: species eligibility

Both min30 datasets share the same species list. A species is included only if it has:

1. At least **30 total segments** in the full corpus, and
2. At least **10 distinct recordings** (unique audio files).

This ensures that every species in the dataset is represented by a reasonable volume of data from multiple independent sources.

### min30 capped: how segments are selected

To produce a balanced dataset with exactly 30 rows per species, segments are selected in a way that maximises diversity across recordings:

1. **One segment per recording first**: pick one segment from each unique recording until we reach 30, or run out of recordings.
2. **Round-robin fill**: if more rows are needed, cycle back through the recordings and pick additional segments, spreading evenly across files.

This avoids overrepresenting a single recording and ensures each species' 30 rows cover as many independent field recordings as possible.

### min30 uncapped

Same eligible species as the capped variant, but all segments are kept with no upper limit. Useful when you need the full data rather than a balanced design.

## Phylogenetic trees

Two pruned consensus trees (Newick format) are provided, one per species set:

- **100-species tree**: matches the 100-species dataset.
- **min30 tree**: matches both min30 variants (they share the same species list).

The trees were pruned from a larger Bayesian consensus tree to keep only the species present in each dataset. They are fully bifurcating and ready for use with phylogenetic comparative methods.
