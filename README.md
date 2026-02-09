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

## Columns

| Column | Description |
|--------|-------------|
| `gen` | Genus |
| `family` | Taxonomic family |
| `species` | Species name (Genus_species) |
| `sub_species` | Subspecies |
| `common_name` | Common English name |
| `recordist` | Recordist name |
| `date` | Recording date |
| `time` | Recording time |
| `country` | Country of recording |
| `location` | Recording location |
| `lat` | Latitude |
| `lng` | Longitude |
| `bird` | Bird identifier |
| `file_name` | Original audio file name |
| `weights` | Sample weights |
| `PC1`-`PC37` | Principal component scores from MPS analysis |
| `gmm_cluster` | Acoustic motif cluster assignment (0-7, see below) |
| `gmm_prob_0` | Posterior probability for Flat Whistles |
| `gmm_prob_1` | Posterior probability for Slow Trills |
| `gmm_prob_2` | Posterior probability for Fast Trills |
| `gmm_prob_3` | Posterior probability for Chaotic Songs |
| `gmm_prob_4` | Posterior probability for Ultrafast Trills |
| `gmm_prob_5` | Posterior probability for Slow Modulated Whistles |
| `gmm_prob_6` | Posterior probability for Fast Modulated Whistles |
| `gmm_prob_7` | Posterior probability for Harmonic Stacks |
| `oscine_group` | Oscines (vocal learners) or Non-Oscines |

## Acoustic motifs

| Cluster | Motif Name |
|---------|------------|
| 0 | Flat Whistles |
| 1 | Slow Trills |
| 2 | Fast Trills |
| 3 | Chaotic Songs |
| 4 | Ultrafast Trills |
| 5 | Slow Modulated Whistles |
| 6 | Fast Modulated Whistles |
| 7 | Harmonic Stacks |

## Acoustic feature extraction and clustering

1. **Modulation Power Spectrum (MPS):** Each song bout was transformed into an MPS, a 2D representation that quantifies how sound energy is distributed across temporal modulations (e.g., trill rates) and spectral modulations (e.g., pitch changes, tonality).

2. **Dimensionality Reduction:** The high-dimensional MPS features were reduced to **37 Principal Components (PCs)** using weighted PCA. The number of components was selected based on reconstruction fidelity (minimizing error between original and reconstructed MPS).

3. **Gaussian Mixture Model (GMM):** An unsupervised GMM with **8 components** was fitted on the 37-dimensional PC space. The optimal number of clusters (8) was determined using AIC and BIC criteria.

4. **Soft Clustering:** The GMM assigns each song bout a posterior probability of belonging to each of the 8 clusters (`gmm_prob_0` to `gmm_prob_7`). The `gmm_cluster` column indicates the most likely cluster (highest probability).

## Phylogenetic tree

A single pruned consensus tree (Newick format) is provided, matching the 1,303 species in both datasets.

The tree was derived from the BirdTree consensus tree (Jetz et al. 2012) by matching species names directly or via synonyms, then pruning to retain only matched species. It is fully bifurcating and ready for use with phylogenetic comparative methods.
