

quarter_to_date <- function(x) {
  x  <- stringr::str_squish(stringr::str_remove_all(as.character(x), "\\*"))
  yr <- as.integer(stringr::str_extract(x, "^\\d{4}"))
  qt <- as.integer(stringr::str_match(x, "(?i)Q\\s*(\\d)")[, 2])
  # Project convention: a quarter is dated to the first day of its closing month
  lubridate::make_date(yr, qt * 3L, 1L)
}

as_number <- function(x) {
  x <- as.character(x)
  x[stringr::str_squish(x) %in% c("", "-", "..", "n/a", "N/A")] <- NA_character_
  readr::parse_number(x)
}

#' Read one quarterly sheet from the GSS workbook
#'
#' @param sheet Sheet name.
#' @param cols  Column names, in order, starting with "quarter". These replace
#'   the workbook's merged multi-row headers, which are not machine readable.
#' @param skip  Number of header rows above the first data row.
read_gss_quarter <- function(sheet, cols, skip = 3, path = gdp_paths$quarterly) {

  raw <- readxl::read_excel(path, sheet = sheet, skip = skip, col_names = FALSE) |>
    janitor::remove_empty(which = c("rows", "cols"))

  if (ncol(raw) != length(cols)) {
    stop(sprintf(
      "Sheet '%s' returned %d columns but %d names were supplied. GSS has probably changed the layout: inspect the sheet and update the `cols_*` vector.",
      sheet, ncol(raw), length(cols)
    ), call. = FALSE)
  }
  names(raw) <- cols

  out <- raw |>
    # keeps data rows, drops the "*revised / **provisional" footnote row
    dplyr::filter(stringr::str_detect(.data$quarter, "^\\s*\\d{4}")) |>
    dplyr::mutate(
      date = quarter_to_date(.data$quarter),
      dplyr::across(-dplyr::all_of(c("quarter", "date")), as_number)
    ) |>
    dplyr::relocate(date, .after = "quarter") |>
    dplyr::arrange(.data$date)

  check_quarterly(out, sheet)
  out
}

# Guards against a silently missing quarter, which would corrupt every lag(4)
check_quarterly <- function(df, label) {
  gaps <- diff(df$date)
  if (any(gaps > 120)) {
    warning(sprintf("Sheet '%s' has a gap in the quarterly series near %s. Year-on-year calculations assume no missing quarters.",
                    label, format(df$date[which(gaps > 120)[1]])), call. = FALSE)
  }
  invisible(df)
}

# ---- Column layouts ---------------------------------------------------------
# Positional, in workbook order, after empty columns are dropped.

cols_constant_all <- c(
  "quarter",
  "agriculture", "industry", "services", "total_value_added", "net_indirect_taxes",
  "gdp_purchasers", "informal", "non_oil_gdp",
  "growth_agriculture", "growth_industry", "growth_services",
  "growth_gdp", "growth_informal", "growth_non_oil_gdp"
)

cols_agric <- c(
  "quarter", "crops_and_cocoa", "cocoa", "livestock", "forestry_and_logging",
  "fishing", "total_value_added", "informal"
)

cols_industry <- c(
  "quarter", "mining_and_quarrying", "oil_and_gas", "manufacturing", "electricity",
  "water_and_sewerage", "construction", "total_value_added", "informal"
)

cols_services <- c(
  "quarter", "trade_and_repairs", "accommodation_and_food", "transport_and_storage",
  "information_and_communication", "financial_and_insurance", "real_estate",
  "professional_and_support", "public_administration", "education",
  "health_and_social_work", "other_personal_services", "total_value_added", "informal"
)

cols_seasonal_all <- c(
  "quarter", "agriculture", "industry", "services", "total_value_added",
  "net_indirect_taxes", "gdp_purchasers", "informal",
  "qoq_agriculture", "qoq_industry", "qoq_services", "qoq_gdp", "qoq_informal"
)

cols_seasonal_industry <- c(
  "quarter", "mining_and_quarrying", "manufacturing", "electricity",
  "water_and_sewerage", "construction", "total_value_added", "informal"
)

cols_current_all <- c(
  "quarter", "agriculture", "industry", "services", "total_value_added",
  "net_indirect_taxes", "gdp_purchasers", "informal", "non_oil_gdp",
  "share_agriculture", "share_industry", "share_services", "share_total",
  "share_informal"
)

cols_contribution <- c(
  "quarter",
  "crops", "livestock", "forestry_and_logging", "fishing",
  "mining_and_quarrying", "manufacturing", "electricity", "water_and_sewerage",
  "construction", "trade_and_repairs", "accommodation_and_food",
  "transport_and_storage", "information_and_communication",
  "financial_and_insurance", "real_estate", "professional_and_support",
  "public_administration", "education", "health_and_social_work",
  "other_personal_services", "net_indirect_taxes",
  "agriculture", "industry", "services",
  "cocoa", "oil_and_gas", "gold", "total"
)

# Display labels, applied once here so no chart hard-codes a rename
sector_labels <- c(
  crops_excl_cocoa              = "Crops (excl Cocoa)",
  cocoa                         = "Cocoa",
  livestock                     = "Livestock",
  forestry_and_logging          = "Forestry and Logging",
  fishing                       = "Fishing",
  mining_excl_oil               = "Mining and Quarrying (excl Oil)",
  oil_and_gas                   = "Oil and Gas",
  manufacturing                 = "Manufacturing",
  electricity                   = "Electricity",
  water_and_sewerage            = "Water and Sewerage",
  construction                  = "Construction",
  trade_and_repairs             = "Trade and Repairs",
  accommodation_and_food        = "Accommodation and Food",
  transport_and_storage         = "Transport and Storage",
  information_and_communication = "Information and Communication",
  financial_and_insurance       = "Financial and Insurance",
  real_estate                   = "Real Estate",
  professional_and_support      = "Professional and Support Services",
  public_administration         = "Public Administration",
  education                     = "Education",
  health_and_social_work        = "Health and Social Work",
  other_personal_services       = "Other Personal Services"
)

subsector_keys <- names(sector_labels)

# ---- Read -------------------------------------------------------------------

gdp_all           <- read_gss_quarter("constant gdp_all",            cols_constant_all)
agric_values      <- read_gss_quarter("constant gdp_Agric",          cols_agric)
industry_values   <- read_gss_quarter("constant gdp  industry",      cols_industry)
services_values   <- read_gss_quarter("constant gpd  services",      cols_services)
seasonal_all      <- read_gss_quarter("seasonal adjusted gdp All",   cols_seasonal_all)
seasonal_industry <- read_gss_quarter("seasonal adjusted industry",  cols_seasonal_industry)
current_all       <- read_gss_quarter("current gdp_all",             cols_current_all)
contribution_all  <- read_gss_quarter("contribution to growth rate", cols_contribution, skip = 2)

# ---- Reconciliation ---------------------------------------------------------
# The 21 published components should sum to the published headline growth rate,
# and that rate should match the growth column on the constant price sheet.
# If either check fails, a column mapping above is wrong.

contrib_parts <- c(
  "crops", "livestock", "forestry_and_logging", "fishing",
  "mining_and_quarrying", "manufacturing", "electricity", "water_and_sewerage",
  "construction", "trade_and_repairs", "accommodation_and_food",
  "transport_and_storage", "information_and_communication",
  "financial_and_insurance", "real_estate", "professional_and_support",
  "public_administration", "education", "health_and_social_work",
  "other_personal_services", "net_indirect_taxes"
)

local({
  parts_gap <- contribution_all |>
    dplyr::mutate(gap = rowSums(dplyr::across(dplyr::all_of(contrib_parts)), na.rm = TRUE) - total) |>
    dplyr::filter(abs(gap) > 0.05)

  headline_gap <- contribution_all |>
    dplyr::select(date, published = total) |>
    dplyr::inner_join(dplyr::select(gdp_all, date, growth_gdp), by = "date") |>
    dplyr::filter(abs(published - growth_gdp) > 0.05)

  if (nrow(parts_gap) > 0) {
    warning(sprintf("Published contributions do not sum to headline growth in %d quarter(s), first: %s.",
                    nrow(parts_gap), format(parts_gap$date[1])), call. = FALSE)
  }
  if (nrow(headline_gap) > 0) {
    warning(sprintf("Published contributions total disagrees with the constant price growth column in %d quarter(s), first: %s.",
                    nrow(headline_gap), format(headline_gap$date[1])), call. = FALSE)
  }
})

# ---- Derived sub-sector series ---------------------------------------------
# Cocoa sits inside Crops, and oil sits inside Mining, in both the value sheets
# and the published contributions. Net them out once, here.

agric_values <- agric_values |>
  dplyr::mutate(crops_excl_cocoa = crops_and_cocoa - cocoa) |>
  dplyr::select(-crops_and_cocoa)

industry_values <- industry_values |>
  dplyr::mutate(mining_excl_oil = mining_and_quarrying - oil_and_gas) |>
  dplyr::select(-mining_and_quarrying)

to_long <- function(df, group) {
  df |>
    dplyr::select(-dplyr::any_of("informal")) |>
    tidyr::pivot_longer(
      -dplyr::all_of(c("quarter", "date")),
      names_to = "sector", values_to = "value"
    ) |>
    dplyr::mutate(group = group)
}

# Sub-sector levels, year-on-year growth and absolute change
subsector_values <- dplyr::bind_rows(
  to_long(agric_values,    "Agriculture"),
  to_long(industry_values, "Industry"),
  to_long(services_values, "Services")
) |>
  dplyr::arrange(group, sector, date) |>
  dplyr::group_by(group, sector) |>
  dplyr::mutate(
    yoy    = value / dplyr::lag(value, 4) - 1,
    change = value - dplyr::lag(value, 4)
  ) |>
  dplyr::ungroup() |>
  dplyr::mutate(label = dplyr::coalesce(unname(sector_labels[sector]), sector))

# Sector totals, used as the denominator for within-sector contributions
group_totals <- subsector_values |>
  dplyr::filter(sector == "total_value_added") |>
  dplyr::arrange(group, date) |>
  dplyr::group_by(group) |>
  dplyr::mutate(total_lag4 = dplyr::lag(value, 4)) |>
  dplyr::ungroup() |>
  dplyr::select(group, date, total = value, total_yoy = yoy, total_lag4)

# Contribution of each sub-sector to ITS OWN sector's growth, in percentage points
subsector_contrib <- subsector_values |>
  dplyr::filter(sector != "total_value_added") |>
  dplyr::left_join(group_totals, by = c("group", "date")) |>
  dplyr::mutate(contribution = change / total_lag4 * 100) |>
  dplyr::filter(!is.na(contribution))

# ---- Broad sector series ----------------------------------------------------

sector_values <- gdp_all |>
  dplyr::select(quarter, date, Agriculture = agriculture, Industry = industry,
                Services = services, total = total_value_added) |>
  tidyr::pivot_longer(dplyr::all_of(c("Agriculture", "Industry", "Services")),
                      names_to = "sector", values_to = "value") |>
  dplyr::arrange(sector, date) |>
  dplyr::group_by(sector) |>
  dplyr::mutate(
    change       = value - dplyr::lag(value, 4),
    total_lag4   = dplyr::lag(total, 4),
    contribution = change / total_lag4 * 100
  ) |>
  dplyr::ungroup()

total_va_growth <- gdp_all |>
  dplyr::transmute(date, growth = (total_value_added / dplyr::lag(total_value_added, 4) - 1) * 100)

# ---- Published contributions to overall growth ------------------------------
# GSS publishes these directly and they reconcile to the headline growth rate,
# so there is no need to recompute them from the value sheets.

contrib_subsector <- contribution_all |>
  dplyr::mutate(
    crops_excl_cocoa = crops - cocoa,
    mining_excl_oil  = mining_and_quarrying - oil_and_gas
  ) |>
  dplyr::select(quarter, date, dplyr::all_of(subsector_keys)) |>
  tidyr::pivot_longer(-dplyr::all_of(c("quarter", "date")),
                      names_to = "sector", values_to = "contribution") |>
  dplyr::mutate(label = unname(sector_labels[sector]))

gold_split <- contribution_all |>
  dplyr::transmute(date, Gold = gold, `Other sectors` = total - gold) |>
  tidyr::pivot_longer(-date, names_to = "series", values_to = "contribution")

# ---- Latest quarter ---------------------------------------------------------

latest_quarter <- max(subsector_values$date)
latest_label   <- sprintf("Q%d %d", lubridate::quarter(latest_quarter),
                          lubridate::year(latest_quarter))
headline_growth <- gdp_all |>
  dplyr::filter(date == latest_quarter) |>
  dplyr::pull(growth_gdp)

if (max(contrib_subsector$date) != latest_quarter) {
  warning("The contributions sheet and the value sheets end in different quarters. The latest-quarter charts use whichever quarter both cover.")
}

subsector_latest <- subsector_values |>
  dplyr::filter(date == latest_quarter, sector != "total_value_added") |>
  dplyr::select(group, sector, label, value, yoy) |>
  dplyr::inner_join(
    contrib_subsector |>
      dplyr::filter(date == latest_quarter) |>
      dplyr::select(sector, contribution),
    by = "sector"
  ) |>
  dplyr::mutate(
    growth_pct     = yoy * 100,
    growth_sign    = dplyr::if_else(growth_pct >= 0, "Positive", "Negative"),
    contrib_sign   = dplyr::if_else(contribution >= 0, "Positive", "Negative")
  )

# ---- Seasonally adjusted, indexed to 2019 Q4 --------------------------------

index_since_base <- function(df, cols, base = covid_base) {
  df |>
    dplyr::filter(date >= base) |>
    dplyr::arrange(date) |>
    dplyr::select(dplyr::all_of(c("date", unname(cols)))) |>
    dplyr::rename(dplyr::all_of(cols)) |>
    dplyr::mutate(dplyr::across(-date, ~ .x / dplyr::first(.x) - 1)) |>
    tidyr::pivot_longer(-date, names_to = "series", values_to = "change")
}

seasonal_index <- index_since_base(
  seasonal_all,
  c(Overall = "gdp_purchasers", Agriculture = "agriculture",
    Industry = "industry", Services = "services")
)

seasonal_index_industry <- index_since_base(
  seasonal_industry,
  c(`Mining and Quarrying` = "mining_and_quarrying", Manufacturing = "manufacturing",
    Electricity = "electricity", `Water and Sewerage` = "water_and_sewerage",
    Construction = "construction")
)

# ---- Current-price sectoral shares -----------------------------------------

sector_shares <- current_all |>
  dplyr::select(date, Agriculture = share_agriculture, Industry = share_industry,
                Services = share_services) |>
  tidyr::pivot_longer(-date, names_to = "sector", values_to = "share") |>
  dplyr::filter(lubridate::year(date) >= shares_start)
