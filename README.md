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
| **min30 capped** | 1,303 | Exactly 30 | 43,110 | Balanced design, downsampled for diversity |
| **min30 uncapped** | 1,303 | All available | 92,479 | Same species, full data retained |

### Species eligibility

Both datasets share the same species list. We keep **all species** from the full Xeno-canto corpus that meet two quality thresholds:

1. At least **30 total segments**, and
2. At least **10 distinct recordings** (unique audio files).

The 1,303 species in the dataset are all the species that pass these criteria. This ensures that every species is represented by a reasonable volume of data from multiple independent sources.

### min30 capped: how segments are selected

To produce a balanced dataset with exactly 30 rows per species, segments are selected in a way that maximises diversity across recordings:

1. **One segment per recording first**: pick one segment from each unique recording until we reach 30, or run out of recordings.
2. **Round-robin fill**: if more rows are needed, cycle back through the recordings and pick additional segments, spreading evenly across files.

This avoids overrepresenting a single recording and ensures each species' 30 rows cover as many independent field recordings as possible.

### min30 uncapped

Same eligible species as the capped variant, but all segments are kept with no upper limit. Useful when you need the full data rather than a balanced design.

## Phylogenetic tree

A single pruned consensus tree (Newick format) is provided, matching the 1,303 species in both datasets.

The tree was pruned from a larger Bayesian consensus tree to keep only the species present in the data. It is fully bifurcating and ready for use with phylogenetic comparative methods.
