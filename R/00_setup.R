# =============================================================================
# 00_setup.R  |  Ghana quarterly GDP charts: packages, configuration, house style
# Source this once per session, before 01_data_gdp_quarterly.R
# =============================================================================

library(tidyverse)
library(readxl)
library(janitor)
library(scales)
library(ggtext)
library(ggchicklet)
library(ggrepel)
library(RColorBrewer)

# ---- Configuration ----------------------------------------------------------
# Everything that changes between vintages or machines lives here.

gdp_paths <- list(
  quarterly = "data/gdp_raw.xlsx"
)

chart_dir <- "Charts"
chart_dpi <- 200

# Windows used by the charts
contribution_start <- 2018            # stacked contribution charts start here
focus_start        <- 2022            # single sub-sector focus charts start here
long_series_start  <- 2013            # oil and gas series starts here
shares_start       <- 2015            # sectoral share chart starts here
covid_base         <- as.Date("2019-12-01")   # 2019 Q4, base for the "since Covid" charts

# Extra charts (03)
trend_window       <- c(2015, 2019)           # years used to fit the pre-pandemic trend
momentum_quarters  <- 12                      # quarters shown on the quarter-on-quarter chart
index_base         <- as.Date("2013-12-01")   # 2013 Q4 = 100 on the sub-sector index chart
index_focus <- c("manufacturing", "construction", "information_and_communication",
                 "mining_excl_oil", "crops_excl_cocoa")

source_note <- "Data: Ghana Statistical Service"
credit      <- "Chart: alfredappiah.com"

# ---- House palette ----------------------------------------------------------

pal <- list(
  rust     = "#A9432C",
  dark     = "grey15",
  mid      = "grey55",
  light    = "grey80",
  positive = "#008080",
  negative = "#FF5050",
  gold     = "#E3B778",
  ref      = "firebrick1"
)

sector_cols <- c(
  Agriculture = "#7570B3",
  Industry    = "#D95F02",
  Services    = "#1B9E77"
)

# Dark2 only carries 8 colours; services has 11 sub-sectors, so interpolate.
sector_palette <- function(n) {
  grDevices::colorRampPalette(RColorBrewer::brewer.pal(8, "Dark2"))(n)
}

# ---- Theme ------------------------------------------------------------------
# Markdown titles are enabled so titles can colour individual words, e.g.
# "<span style='color:#D95F02;'>Industry</span>".
# base_family is left empty on purpose: the published charts use the device
# default sans rather than Lato.

theme_alfred <- function(base_size = 12, base_family = "") {
  theme_minimal(base_size = base_size, base_family = base_family) +
    theme(
      plot.background     = element_rect(fill = "floralwhite", colour = NA),
      panel.background    = element_rect(fill = "floralwhite", colour = NA),
      panel.grid          = element_blank(),
      axis.ticks          = element_blank(),
      legend.position     = "none",
      plot.title          = element_markdown(hjust = 0.5, colour = "grey30", size = 16,
                                             face = "bold", margin = margin(b = 6)),
      plot.subtitle       = element_markdown(hjust = 0.5, colour = "grey55", size = 11,
                                             face = "bold", lineheight = 1.3,
                                             margin = margin(b = 14)),
      plot.caption        = element_markdown(hjust = 1, colour = "grey55", size = 10,
                                             face = "bold", margin = margin(t = 12)),
      axis.text           = element_text(colour = "grey35", size = 12, face = "bold"),
      axis.title          = element_text(colour = "grey35", size = 12, face = "bold"),
      axis.title.x        = element_text(margin = margin(t = 10)),
      axis.title.y        = element_text(margin = margin(r = 10)),
      strip.text          = element_text(colour = "grey30", size = 12, face = "bold"),
      plot.title.position = "plot",
      plot.margin         = margin(16, 20, 12, 16)
    )
}

# Charts with many series need a legend back; theme_alfred switches it off.
legend_top <- function() {
  theme(
    legend.position   = "top",
    legend.title      = element_blank(),
    legend.background = element_blank(),
    legend.key        = element_blank(),
    legend.text       = element_text(size = 11, face = "bold", colour = "grey35")
  )
}

no_axis_titles <- function() {
  theme(axis.title.x = element_blank(), axis.title.y = element_blank())
}

# ---- Small formatting helpers ----------------------------------------------

lab_pct <- scales::label_percent(scale = 1, accuracy = 1)   # for values already in %
lab_year <- scales::label_date("%Y")

fmt_pct <- function(x, digits = 1) sprintf(paste0("%.", digits, "f%%"), x)
fmt_pp  <- function(x, digits = 2) sprintf(paste0("%.", digits, "f"), x)

# ---- Saving -----------------------------------------------------------------

save_chart <- function(plot, file, width = 10, height = 6.5) {
  if (!dir.exists(chart_dir)) dir.create(chart_dir, recursive = TRUE)
  path <- file.path(chart_dir, file)
  ggsave(path, plot = plot, width = width, height = height,
         dpi = chart_dpi, bg = "floralwhite")
  message("saved: ", path)
  invisible(path)
}
