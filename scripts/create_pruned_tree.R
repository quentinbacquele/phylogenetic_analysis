#!/usr/bin/env Rscript

# ==============================================================================
# Create Pruned Phylogenetic Tree from an Input Trait Table
# ==============================================================================

# --- Configuration ---
cmd_args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", cmd_args, value = TRUE)
script_dir <- if (length(file_arg) > 0) {
  dirname(normalizePath(sub("^--file=", "", file_arg[1])))
} else {
  getwd()
}
project_root <- normalizePath(file.path(script_dir, ".."), mustWork = TRUE)
setwd(project_root)

# Input files
trait_file <- Sys.getenv(
  "TRAIT_FILE",
  "./data/raw/traits_data_pc_gmm_8components_proba_100species.csv"
)
tree_file <- Sys.getenv(
  "FULL_TREE_FILE",
  "/Users/quentinbacquele/Desktop/PhD/analysis/geography/climate/output/consensus_pruned_tree_plots/consensus_sumtrees.tre"
)
synonym_file <- Sys.getenv(
  "SYNONYM_FILE",
  "/Users/quentinbacquele/Desktop/PhD/analysis/geography/climate/matching_final_corrected.csv"
)

# Output file
output_tree_file <- Sys.getenv(
  "OUTPUT_TREE_FILE",
  "./data/phylogeny/consensus_tree_100species.tre"
)
mapping_file <- Sys.getenv(
  "OUTPUT_MAPPING_FILE",
  "./data/phylogeny/species_tree_mapping.csv"
)
dir.create("./data/phylogeny", recursive = TRUE, showWarnings = FALSE)

if (!file.exists(trait_file)) {
  stop(sprintf("Trait file not found: %s", trait_file))
}
if (!file.exists(tree_file)) {
  stop(sprintf("Tree file not found: %s", tree_file))
}
if (!file.exists(synonym_file)) {
  stop(sprintf("Synonym file not found: %s", synonym_file))
}

# --- Load Required Packages ---
required_packages <- c("ape", "readr", "dplyr", "stringr")

for(pkg in required_packages) {
  if(!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "http://cran.us.r-project.org")
  }
  library(pkg, character.only = TRUE)
}

# ==============================================================================
# LOAD DATA
# ==============================================================================

cat("=== Loading data ===\n")

# Load trait data
trait_data <- readr::read_csv(trait_file, show_col_types = FALSE)

# Get unique species and standardize names (replace spaces with underscores)
species_in_traits <- unique(trait_data$species)
species_in_traits <- stringr::str_replace_all(species_in_traits, " ", "_")

cat(sprintf("Species in trait data: %d\n", length(species_in_traits)))

# Load full phylogenetic tree
cat("Loading phylogenetic tree...\n")
full_tree <- ape::read.tree(tree_file)

# Handle multiPhylo if needed
if (inherits(full_tree, "multiPhylo")) {
  full_tree <- full_tree[[1]]
}

# Standardize tree tip labels
full_tree$tip.label <- stringr::str_replace_all(full_tree$tip.label, " ", "_")

cat(sprintf("Tips in full tree: %d\n", length(full_tree$tip.label)))

# Load synonym data
synonym_data <- readr::read_csv(synonym_file, col_types = readr::cols(.default = "c"),
                                show_col_types = FALSE)

# Standardize synonym names (replace spaces with underscores)
synonym_data <- synonym_data %>%
  mutate(across(everything(), ~stringr::str_replace_all(., " ", "_")))

# Create list of synonym rows for matching
synonym_rows_list <- apply(synonym_data, 1, function(row) {
  unique(as.character(row[!is.na(row) & row != "" & row != "_"]))
})

cat(sprintf("Synonym rows loaded: %d\n", length(synonym_rows_list)))

# ==============================================================================
# SPECIES MATCHING
# ==============================================================================

cat("\n=== Matching species to tree ===\n")

# Get tree tip labels
tree_labels <- full_tree$tip.label

# Step 1: Direct matches
initial_matches <- intersect(species_in_traits, tree_labels)
cat(sprintf("Direct matches: %d\n", length(initial_matches)))

# Species missing from tree (need synonym matching)
species_missing_in_tree <- setdiff(species_in_traits, initial_matches)
cat(sprintf("Species needing synonym matching: %d\n", length(species_missing_in_tree)))

# Tree labels still available for matching
tree_labels_still_available <- setdiff(tree_labels, initial_matches)

# Step 2: Synonym matching
synonym_match_results <- list()

if (length(species_missing_in_tree) > 0 &&
    length(tree_labels_still_available) > 0 &&
    length(synonym_rows_list) > 0) {

  # Track which tree labels have been used
  available_tree_label_set <- setNames(rep(TRUE, length(tree_labels_still_available)),
                                       nm = tree_labels_still_available)

  for (missing_species in species_missing_in_tree) {

    # Find synonym rows containing this species
    relevant_row_indices <- which(sapply(synonym_rows_list, function(syn_row) {
      missing_species %in% syn_row
    }))

    if (length(relevant_row_indices) > 0) {
      # Get all potential synonyms from relevant rows
      potential_synonyms <- unique(unlist(synonym_rows_list[relevant_row_indices]))
      potential_synonyms <- potential_synonyms[potential_synonyms != "" &
                                                 !is.na(potential_synonyms) &
                                                 potential_synonyms != "_"]

      # Try to find a match in available tree labels
      for (syn in potential_synonyms) {
        if (syn %in% names(available_tree_label_set) &&
            isTRUE(available_tree_label_set[[syn]])) {
          synonym_match_results[[missing_species]] <- syn
          available_tree_label_set[[syn]] <- FALSE
          break
        }
      }
    }
  }
}

cat(sprintf("Synonym matches found: %d\n", length(synonym_match_results)))

# ==============================================================================
# CREATE MAPPING
# ==============================================================================

# Build mapping dataframe
mapping_df <- data.frame(
  trait_species = initial_matches,
  tree_label = initial_matches,
  match_type = "direct",
  stringsAsFactors = FALSE
)

if (length(synonym_match_results) > 0) {
  synonym_df <- data.frame(
    trait_species = names(synonym_match_results),
    tree_label = unlist(synonym_match_results),
    match_type = "synonym",
    stringsAsFactors = FALSE
  )
  mapping_df <- rbind(mapping_df, synonym_df)
}

# Report unmatched species
unmatched_species <- setdiff(species_in_traits, mapping_df$trait_species)
if (length(unmatched_species) > 0) {
  cat(sprintf("\nWarning: %d species could not be matched:\n", length(unmatched_species)))
  print(unmatched_species)
}

cat(sprintf("\nTotal matched species: %d / %d\n",
            nrow(mapping_df), length(species_in_traits)))

# ==============================================================================
# PRUNE TREE
# ==============================================================================

cat("\n=== Pruning tree ===\n")

# Get final tree labels to keep
final_tree_labels <- unique(mapping_df$tree_label)

# Prune tree
pruned_tree <- ape::keep.tip(full_tree, final_tree_labels)

# Resolve polytomies if present
if (!ape::is.binary(pruned_tree)) {
  cat("Resolving polytomies...\n")
  pruned_tree <- ape::multi2di(pruned_tree)
}

# Fix zero or near-zero branch lengths
min_bl_threshold <- .Machine$double.eps^0.5
if (any(pruned_tree$edge.length < min_bl_threshold, na.rm = TRUE)) {
  cat("Fixing near-zero branch lengths...\n")
  zero_indices <- which(pruned_tree$edge.length < min_bl_threshold)
  min_pos_bl <- min(pruned_tree$edge.length[pruned_tree$edge.length >= min_bl_threshold],
                    na.rm = TRUE)
  small_val <- if (is.finite(min_pos_bl) && min_pos_bl > 0) {
    min_pos_bl * 0.001
  } else {
    1e-8
  }
  pruned_tree$edge.length[zero_indices] <- pruned_tree$edge.length[zero_indices] + small_val
}

cat(sprintf("Pruned tree has %d tips\n", length(pruned_tree$tip.label)))

# ==============================================================================
# SAVE OUTPUTS
# ==============================================================================

cat("\n=== Saving outputs ===\n")

# Save pruned tree
ape::write.tree(pruned_tree, file = output_tree_file)
cat(sprintf("Pruned tree saved to: %s\n", output_tree_file))

# Save species mapping for reference
write.csv(mapping_df, mapping_file, row.names = FALSE)
cat(sprintf("Species mapping saved to: %s\n", mapping_file))

# ==============================================================================
# SUMMARY
# ==============================================================================

cat("\n=== Summary ===\n")
cat(sprintf("Input species: %d\n", length(species_in_traits)))
cat(sprintf("Direct matches: %d\n", sum(mapping_df$match_type == "direct")))
cat(sprintf("Synonym matches: %d\n", sum(mapping_df$match_type == "synonym")))
cat(sprintf("Unmatched: %d\n", length(unmatched_species)))
cat(sprintf("Final tree tips: %d\n", length(pruned_tree$tip.label)))

cat("\n=== Done ===\n")
