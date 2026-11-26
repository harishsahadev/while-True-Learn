# =============================================================================
# rq2_poster_figures.R
# Figures for the Q2 panel of the poster and the Q2 slides.
#
# Run AFTER knitting 04_RQ2_v2.Rmd, with the working directory set to this
# script's folder (04_Analysis/Boulton). In RStudio: Session > Set Working
# Directory > To Source File Location, then Source.
#
# Reads   ../outputs/rq2/rq2_types.csv        written by the last chunk of 04_RQ2_v2.Rmd
#         data/rq2_teammates_types.csv        optional: the type each teammate's build gives each district
#         ../data-local-only/boundaries/      optional: one territorial authority boundary file (.gpkg, .shp or .geojson)
# Writes  ../outputs/rq2/rq2_profile_types.png
#         ../outputs/rq2/rq2_scatter_log.png
#         ../outputs/rq2/rq2_map_types.png    only if a boundary file is found
#
# The clustering itself is done in the notebook. This script only draws it.
# =============================================================================

library(tidyverse)

# ---- Settings: everything that is a choice is here ----------------------------

types_file   <- "../outputs/rq2/rq2_types.csv"
builds_file  <- "data/rq2_teammates_types.csv"
boundary_dir <- "../data-local-only/boundaries"
out_dir      <- "../outputs/rq2"

# the three types, in the order they are shown, and the name printed for each
type_levels <- c("slow provincial", "urban multi-unit", "house-building")
type_labels <- c("Slow provincial", "Urban multi-unit", "House-building")

# one colour per type: the three already on the group's poster (style brief palette)
type_colours <- c("Slow provincial"  = "#C76B0A",
                  "Urban multi-unit" = "#FBAC4D",
                  "House-building"   = "#5C5148")

# the light orange is hard to see on the cream poster, so every mark gets a dark
# outline and every type also gets its own point shape (circle, square, triangle)
type_shapes <- c("Slow provincial" = 21, "Urban multi-unit" = 22, "House-building" = 24)

ink         <- "#2B2B2B"   # text and outlines
muted       <- "#5C5148"   # source line
grid_colour <- "#EADFD3"
not_typed   <- "#D9CCBF"   # districts that were not clustered

text_pt  <- 18             # smallest text at print size (poster plan)
title_pt <- 22
dpi      <- 300

# size of each figure at print size, in mm (width, height)
# With no text under 18 pt, the profile chart and the scatter need more height
# than the poster plan's first guess (200 x 110 and 180 x 120).
size_profile <- c(200, 140)
size_scatter <- c(180, 150)
size_map     <- c(150, 200)

source_line <- "Source: Stats NZ, Building consents issued, August 2026"

# the districts named on the scatter and on the map: few, because the text is large
scatter_labels <- c("Auckland", "Wellington", "Queenstown-Lakes", "Selwyn", "Dunedin", "Wairoa")
map_labels     <- c("Auckland", "Wellington", "Christchurch", "Queenstown-Lakes", "Dunedin")

# plain-English names for the seven measures, in the order they are drawn
# (one short line each: at 18 pt there is no room for more)
measure_labels <- c(per1000      = "Homes per 1,000",
                    multi_share  = "Multi-unit homes",
                    retire_share = "Retirement units",
                    house_m2     = "House size",
                    alt_share    = "Renovation share",
                    rel_cost     = "Building cost",
                    growth       = "Recent growth")

# the type names on two lines, for the narrow panel titles of the profile chart
type_two_lines <- c("Slow provincial"  = "Slow\nprovincial",
                    "Urban multi-unit" = "Urban\nmulti-unit",
                    "House-building"   = "House-\nbuilding")

# ---- Data ---------------------------------------------------------------------

types <- read.csv(types_file)

# keep the notebook's name for each type, and add the printed name as a factor
types$type_name <- types$type
types$type <- factor(types$type_name, levels = type_levels, labels = type_labels)

# Two tests of how firm a district's type is:
#   core   - the same type in all four runs of the notebook
#   agreed - the same type in all three group members' builds
# A district is drawn solid if it passes both. Without the teammates' file only
# the first test can be made.
if (file.exists(builds_file)) {
  builds <- read.csv(builds_file)
  types <- types %>%
    left_join(builds[, c("ta", "niwesh", "harish")], by = "ta") %>%
    mutate(agreed = type_name == niwesh & type_name == harish,
           firm   = core & agreed)
  firm_note <- paste0("Solid: same type in all four runs and all three\nbuilds (",
                      sum(types$firm), " of ", nrow(types), "). Faint: borderline.")
} else {
  message("No ", builds_file, ": 'firm' is the notebook's core districts only.")
  types <- types %>%
    mutate(agreed = NA, firm = core)
  firm_note <- paste0("Solid: same type in all four of our runs (",
                      sum(types$firm), " of ", nrow(types), ").\nFaint: borderline.")
}

# how many districts pass each test
cat("Districts:", nrow(types), "\n")
cat("Core (four runs):", sum(types$core), "\n")
cat("Agreed (three builds):", sum(types$agreed), "\n")
cat("Firm on both:", sum(types$firm), "\n")
print(table(types$type, types$firm))

# the number of districts of each type, for legends and panel titles
type_counts <- table(types$type)
type_with_n <- paste0(names(type_counts), " (", as.vector(type_counts), ")")
names(type_with_n) <- names(type_counts)

# ---- One look for all three figures -------------------------------------------

theme_poster <- function() {
  theme_minimal(base_size = text_pt) +
    theme(text                  = element_text(colour = ink),
          plot.title            = element_text(size = title_pt, face = "bold"),
          plot.title.position   = "plot",
          plot.caption          = element_text(size = text_pt, colour = muted, hjust = 0),
          plot.caption.position = "plot",
          axis.text             = element_text(size = text_pt, colour = ink),
          axis.title            = element_text(size = text_pt),
          strip.text            = element_text(size = text_pt, face = "bold", colour = ink),
          legend.text           = element_text(size = text_pt),
          legend.title          = element_blank(),
          legend.position       = "top",
          panel.grid.minor      = element_blank(),
          panel.grid.major      = element_line(colour = grid_colour),
          # transparent, so the poster background shows through
          plot.background       = element_rect(fill = "transparent", colour = NA),
          panel.background      = element_rect(fill = "transparent", colour = NA),
          legend.background     = element_rect(fill = "transparent", colour = NA))
}

save_figure <- function(plot, file, size) {
  ggsave(file.path(out_dir, file), plot, width = size[1], height = size[2],
         units = "mm", dpi = dpi, bg = "transparent")
  message("Saved ", file.path(out_dir, file))
}

dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# ---- Figure 1: what sets each type apart --------------------------------------
# Each measure is put on the same scale (standard deviations from the average of
# the 65 districts), then averaged within each type. A bar to the right means the
# type is above the average district on that measure.

inputs <- names(measure_labels)

scaled <- as.data.frame(scale(types[, inputs]))
scaled$type <- types$type

profile_long <- scaled %>%
  pivot_longer(all_of(inputs), names_to = "measure", values_to = "z") %>%
  group_by(type, measure) %>%
  summarise(z = mean(z), .groups = "drop") %>%
  mutate(measure = factor(measure, levels = rev(inputs), labels = rev(measure_labels)))

p_profile <- ggplot(profile_long, aes(x = z, y = measure, fill = type)) +
  geom_col(width = 0.6, colour = ink, linewidth = 0.3) +
  geom_vline(xintercept = 0, colour = ink, linewidth = 0.5) +
  facet_wrap(~ type, nrow = 1, labeller = as_labeller(type_two_lines)) +
  scale_fill_manual(values = type_colours, guide = "none") +
  scale_x_continuous(breaks = c(-1, 0, 1)) +
  labs(title = "Slow districts renovate, urban ones build up,\nhouse-building ones build fast",
       x = NULL,
       y = NULL,
       caption = paste("Bars: each type's average against the average district,",
                       "in standard deviations. Left is below, right is above.",
                       source_line, sep = "\n")) +
  theme_poster() +
  theme(panel.grid.major.y = element_blank())

save_figure(p_profile, "rq2_profile_types.png", size_profile)

# ---- Figure 2: the districts on two of the seven measures ---------------------
# The building rate is on a log axis, which spreads out the slow districts and
# pulls in Queenstown-Lakes.

p_scatter <- ggplot(types, aes(x = per1000, y = multi_share)) +
  geom_point(aes(fill = type, shape = type, alpha = firm),
             colour = ink, size = 5, stroke = 0.6) +
  # hjust = "inward" keeps a label near the edge of the plot inside it
  geom_text(data = types %>% dplyr::filter(district %in% scatter_labels),
            aes(label = district), size = text_pt / .pt, colour = ink,
            vjust = -1.1, hjust = "inward") +
  scale_fill_manual(values = type_colours, labels = type_with_n) +
  scale_shape_manual(values = type_shapes, labels = type_with_n) +
  scale_alpha_manual(values = c("TRUE" = 1, "FALSE" = 0.3), guide = "none") +
  scale_x_log10(breaks = c(2, 5, 10, 20)) +
  scale_y_continuous(labels = function(x) paste0(round(100 * x), "%"),
                     expand = expansion(mult = c(0.05, 0.22))) +
  labs(title = "Three market types, one cloud of districts",
       x = "New homes per 1,000 people a year (log scale)",
       y = "Multi-unit homes",
       caption = paste(firm_note, source_line, sep = "\n")) +
  theme_poster() +
  theme(legend.justification = "left") +
  # the legend in one column: three names with their counts do not fit on one line
  guides(fill  = guide_legend(ncol = 1, override.aes = list(alpha = 1, size = 6)),
         shape = guide_legend(ncol = 1))

save_figure(p_scatter, "rq2_scatter_log.png", size_scatter)

# ---- Figure 3: the map --------------------------------------------------------
# Needs one boundary file of the territorial authorities. Skipped if there is none.

boundary_file <- list.files(boundary_dir, pattern = "\\.(gpkg|shp|geojson)$",
                            full.names = TRUE, ignore.case = TRUE)

if (length(boundary_file) == 0) {

  message("No boundary file in ", boundary_dir, ": the map is skipped.")

} else {

  library(sf)

  ta_map <- st_read(boundary_file[1], quiet = TRUE)

  # the column that holds the district name without macrons, e.g. TA2026_V1_00_NAME_ASCII
  name_col <- grep("NAME_ASCII$", names(ta_map), value = TRUE)[1]
  if (is.na(name_col)) {
    name_col <- grep("NAME$", names(ta_map), value = TRUE)[1]
  }
  ta_map$ta <- ta_map[[name_col]]

  # every clustered district has to find its shape
  not_matched <- setdiff(types$ta, ta_map$ta)
  if (length(not_matched) > 0) {
    message("No boundary found for: ", paste(not_matched, collapse = ", "))
  }

  # the Chatham Islands are 800 km east of the mainland and are left out of the frame
  mainland <- ta_map %>%
    dplyr::filter(!ta %in% c("Chatham Islands Territory", "Area Outside Territorial Authority")) %>%
    left_join(types[, c("ta", "district", "type")], by = "ta") %>%
    mutate(map_group = ifelse(is.na(type), "Not clustered", as.character(type)))

  map_levels  <- c(type_labels, "Not clustered")
  map_colours <- c(type_colours, "Not clustered" = not_typed)
  map_names   <- c(type_with_n, "Not clustered" = "Not clustered")

  mainland$map_group <- factor(mainland$map_group, levels = map_levels)

  p_map <- ggplot(mainland) +
    geom_sf(aes(fill = map_group), colour = ink, linewidth = 0.2) +
    geom_sf_text(data = mainland %>% dplyr::filter(district %in% map_labels),
                 aes(label = district), size = text_pt / .pt, colour = ink, check_overlap = TRUE) +
    scale_fill_manual(values = map_colours, labels = map_names, drop = FALSE) +
    labs(title = "Three kinds of building market",
         caption = paste("Kawerau and the Chatham Islands",
                         "(not shown) were not clustered.",
                         "Source: Stats NZ, Building consents",
                         "issued, August 2026", sep = "\n")) +
    theme_poster() +
    # the legend sits inside the frame, over the sea north-west of the North Island
    theme(axis.text = element_blank(), axis.title = element_blank(),
          panel.grid.major = element_blank(),
          legend.position = c(0.02, 0.98), legend.justification = c(0, 1)) +
    guides(fill = guide_legend(ncol = 1))

  save_figure(p_map, "rq2_map_types.png", size_map)
}
