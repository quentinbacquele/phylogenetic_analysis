# Phylogenetic Acoustic Analysis

Acoustic trait data and phylogenetic trees for passerine species, built for comparative analyses of song evolution.

## Data overview

Each row represents a single **song segment** extracted from a [Xeno-canto](https://xeno-canto.org/) recording. Every segment is described by:

- **37 PCA components** — a weighted PCA projection of the segment's Modulation Power Spectrum (MPS), capturing the main axes of acoustic variation.
- **8 GMM motif probabilities** — posterior probabilities from a Gaussian Mixture Model fitted in PCA space. Each component represents a recurring acoustic motif type.

All species are labelled as **Oscine** (vocal learners) or **Non-Oscine**, enabling comparisons across this major taxonomic divide.

## Three dataset variants

### 100-species

A hand-picked subset of 100 passerine species used for early analyses. No filtering or row constraints — all available segments for these species are included.

### min30 capped (30 rows per species)

A much broader set of ~1,300 species, each required to have at least **30 segments** from at least **10 distinct recordings**. To keep the dataset balanced, each species is downsampled to exactly **30 rows**, prioritising diversity across recordings.

### min30 uncapped

Same eligible species as above, but **all segments are kept** — no upper limit per species. Useful when you need the full data rather than a balanced design.

## Phylogenetic trees

Two pruned consensus trees (Newick format) are provided, one per species set:

- **100-species tree** — matches the 100-species dataset.
- **min30 tree** — matches both min30 variants (they share the same species list).

The trees were pruned from a larger Bayesian consensus tree to keep only the species present in each dataset. They are fully bifurcating and ready for use with phylogenetic comparative methods.
