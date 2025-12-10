# Phylogenetic Analysis Dataset

Filtered subset of passerine acoustic trait data for phylogenetic analysis.

## Files

### `traits_data_pc_gmm_8components_proba_100species.csv`

Acoustic trait data for 100 passerine species.

### `consensus_tree_100species.tre`

Pruned phylogenetic tree in Newick format containing 100 tips matching the species in the trait dataset. Derived from the BirdTree consensus tree (Jetz et al. 2012) by:

1. Matching species names directly or via synonyms (76 direct, 24 synonym matches)
2. Pruning to retain only matched species

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
| `PC1-PC37` | Principal component scores from Modulation Power Spectrum (MPS) analysis |
| `gmm_cluster` | Acoustic motif cluster assignment (0-7, see below) |
| `gmm_prob_0` | Posterior probability for Flat Whistles |
| `gmm_prob_1` | Posterior probability for Slow Trills |
| `gmm_prob_2` | Posterior probability for Fast Trills |
| `gmm_prob_3` | Posterior probability for Chaotic Songs |
| `gmm_prob_4` | Posterior probability for Ultrafast Trills |
| `gmm_prob_5` | Posterior probability for Slow Modulated Whistles |
| `gmm_prob_6` | Posterior probability for Fast Modulated Whistles |
| `gmm_prob_7` | Posterior probability for Harmonic Stacks |

## Acoustic Motifs

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

## Acoustic Feature Extraction and Clustering

1. **Modulation Power Spectrum (MPS):** Each song bout was transformed into an MPS, a 2D representation that quantifies how sound energy is distributed across temporal modulations (e.g., trill rates) and spectral modulations (e.g., pitch changes, tonality).

2. **Dimensionality Reduction:** The high-dimensional MPS features were reduced to **37 Principal Components (PCs)** using weighted PCA. The number of components was selected based on reconstruction fidelity (minimizing error between original and reconstructed MPS).

3. **Gaussian Mixture Model (GMM):** An unsupervised GMM with **8 components** was fitted on the 37-dimensional PC space. The optimal number of clusters (8) was determined using AIC and BIC criteria.

4. **Soft Clustering:** The GMM assigns each song bout a posterior probability of belonging to each of the 8 clusters (`gmm_prob_0` to `gmm_prob_7`). The `gmm_cluster` column indicates the most likely cluster (highest probability).

## Filtering

This dataset was filtered from the full dataset (3,160 species, 116,792 samples) as follows:

1. **Minimum samples:** ≥30 samples per species
2. **Balanced sampling:** 30-50 samples per species
3. **Recording diversity:** ≥10 unique file names per species
4. **Taxonomic diversity:** Round-robin selection across families to maximize family representation

**Removed columns:** UMAP 1, UMAP 2, UMAP3D 1, UMAP3D 2, UMAP3D 3

## Result

| Metric | Value |
|--------|-------|
| Species | 100 |
| Families | 80 |
| Total rows | 3,392 |
| Samples per species | 30-50 (mean: 33.9) |
