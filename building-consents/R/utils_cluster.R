# =============================================================================
# R/utils_cluster.R
# Shared helpers for clustering (RQ2). Source AFTER utils_data.R:
#   source(file.path(proj_root, "R", "utils_data.R"))
#   source(file.path(proj_root, "R", "utils_cluster.R"))
# Needs the 'cluster' package (installed with R).
# =============================================================================

paths$models_rq2 <- "outputs/models/rq2"

# ---- Variance inflation factor ----------------------------------------------
# VIF_j = 1 / (1 - R2_j), where R2_j comes from regressing feature j on all the
# other features. 1 = unrelated to the others; above about 5 = largely repeated
# by the others. Returns Inf when a feature is an exact combination of others.
vif_table <- function(df) {
  vars <- names(df)
  tibble(feature = vars,
         vif = map_dbl(vars, function(v) {
           r2 <- summary(lm(reformulate(setdiff(vars, v), response = v), data = df))$r.squared
           if (r2 > 1 - 1e-10) Inf else 1 / (1 - r2)
         }))
}

# ---- Adjusted Rand index -----------------------------------------------------
# Agreement between two partitions of the same items, corrected for chance:
# 1 = identical (labels may be numbered differently), 0 = no better than random.
adjusted_rand <- function(a, b) {
  tab <- table(a, b)
  n   <- sum(tab)
  sum_ij <- sum(choose(tab, 2))
  sum_a  <- sum(choose(rowSums(tab), 2))
  sum_b  <- sum(choose(colSums(tab), 2))
  expected <- sum_a * sum_b / choose(n, 2)
  (sum_ij - expected) / ((sum_a + sum_b) / 2 - expected)
}

# ---- Calinski-Harabasz index --------------------------------------------------
# (between-cluster variance / (k - 1)) / (within-cluster variance / (n - k)).
# Higher = tighter, better separated clusters. Same idea as an ANOVA F ratio.
calinski_harabasz <- function(X, cl) {
  X <- as.matrix(X); k <- length(unique(cl)); n <- nrow(X)
  total  <- sum(scale(X, scale = FALSE)^2)
  within <- sum(sapply(unique(cl), function(g) sum(scale(X[cl == g, , drop = FALSE], scale = FALSE)^2)))
  ((total - within) / (k - 1)) / (within / (n - k))
}

# ---- Mean silhouette width -----------------------------------------------------
mean_silhouette <- function(cl, D) mean(cluster::silhouette(cl, D)[, "sil_width"])

# ---- Bootstrap stability -------------------------------------------------------
# How reproducible is a clustering? Repeat B times: draw a bootstrap sample of
# the rows, re-cluster it, and compare with the clustering of the full data on
# the rows that were drawn (adjusted Rand index). Average over the B repeats.
#   cluster_fun(X) must return a vector of cluster labels for the rows of X.
boot_stability <- function(X, cluster_fun, B = 100, seed = 462) {
  set.seed(seed)
  full <- cluster_fun(X)
  map_dbl(seq_len(B), function(b) {
    rows <- sort(unique(sample(nrow(X), replace = TRUE)))
    adjusted_rand(full[rows], cluster_fun(X[rows, , drop = FALSE]))
  })
}

# ---- k-means and Ward wrappers with fixed settings ----------------------------
kmeans_labels <- function(X, k, nstart = 50) kmeans(X, centers = k, nstart = nstart, iter.max = 100)$cluster
ward_labels   <- function(X, k) cutree(hclust(dist(X), method = "ward.D2"), k = k)

# ---- Relabel clusters by size --------------------------------------------------
# k-means numbers clusters arbitrarily (and differently with another seed).
# Renumber so cluster 1 is the largest, which keeps tables and colours stable.
relabel_by_size <- function(cl) {
  ord <- names(sort(table(cl), decreasing = TRUE))
  as.integer(factor(cl, levels = ord))
}
