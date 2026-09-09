

source("R/00_setup.R")
source("R/01_data_gdp_quarterly.R")

# Trailing n-period sum. NA until the window fills, and NA propagates.
roll_sum <- function(x, n = 4) as.numeric(stats::filter(x, rep(1, n), sides = 1))
roll_mean <- function(x, n = 4) roll_sum(x, n) / n

quarter_factor <- function(date) {
  forcats::fct_inorder(sprintf("%d\nQ%d", lubridate::year(date), lubridate::quarter(date)))
}

# =============================================================================
# 15. Quarter-on-quarter momentum
#     Year-on-year says where the economy is against last year. This says what
#     is happening now, and it is the series a technical recession is defined on.
# =============================================================================

qoq <- seasonal_all |>
  dplyr::filter(!is.na(qoq_gdp)) |>
  dplyr::slice_tail(n = momentum_quarters) |>
  dplyr::mutate(
    qlab = quarter_factor(date),
    sign = dplyr::if_else(qoq_gdp >= 0, "Positive", "Negative")
  )

p_qoq <- ggplot(qoq, aes(qlab, qoq_gdp, fill = sign)) +
  geom_chicklet(width = 0.75) +
  geom_hline(yintercept = 0, linewidth = 1.5, colour = pal$dark) +
  geom_text(
    aes(label = fmt_pct(qoq_gdp), vjust = dplyr::if_else(qoq_gdp >= 0, -0.5, 1.4)),
    fontface = "bold", colour = "grey35", size = 4
  ) +
  scale_y_continuous(labels = lab_pct, expand = expansion(mult = c(0.12, 0.12))) +
  scale_fill_manual(values = c(Positive = pal$positive, Negative = pal$negative)) +
  theme_alfred() +
  no_axis_titles() +
  theme(axis.text.y = element_blank()) +
  labs(
    title = "Quarter-on-Quarter Growth in Seasonally Adjusted Real GDP",
    subtitle = paste0(source_note, ". Two negative quarters in a row is the usual definition of a technical recession"),
    caption = credit
  )

save_chart(p_qoq, "gdp_qoq_momentum.png", width = 10, height = 6)

# =============================================================================
# 16. Oil against non-oil growth
#     How much of a given quarter's headline number is coming from oil.
# =============================================================================

oil_split <- gdp_all |>
  dplyr::filter(lubridate::year(date) >= long_series_start) |>
  dplyr::select(date, `Overall GDP` = growth_gdp, `Non-oil GDP` = growth_non_oil_gdp) |>
  tidyr::pivot_longer(-date, names_to = "series", values_to = "growth") |>
  dplyr::filter(!is.na(growth))

oil_split_ends <- oil_split |> dplyr::filter(date == max(date))

p_oil_split <- ggplot(oil_split, aes(date, growth, colour = series)) +
  geom_hline(yintercept = 0, linewidth = 1.5, colour = pal$dark) +
  geom_line(linewidth = 1.5) +
  geom_point(data = oil_split_ends, size = 3.5, shape = 21, stroke = 2, fill = "floralwhite") +
  ggrepel::geom_text_repel(
    data = oil_split_ends,
    aes(label = sprintf("%s\n%.1f%%", series, growth)),
    hjust = 0, direction = "y", nudge_x = 90, size = 4.5,
    fontface = "bold", segment.alpha = 0
  ) +
  scale_x_date(date_breaks = "2 years", labels = lab_year,
               expand = expansion(mult = c(0.02, 0.16))) +
  scale_y_continuous(breaks = scales::pretty_breaks(5), labels = lab_pct) +
  scale_colour_manual(values = c(`Overall GDP` = pal$rust, `Non-oil GDP` = "grey45")) +
  theme_alfred() +
  labs(
    x = NULL, y = "Year-on-year growth (%)",
    title = "<span style='color:#A9432C;'>Overall</span> and <span style='color:grey45;'>Non-Oil</span> Real GDP Growth",
    subtitle = paste0(source_note, ". The gap between the two lines is the oil sector's pull on the headline rate"),
    caption = credit
  )

save_chart(p_oil_split, "gdp_oil_vs_nonoil.png", width = 10, height = 6.5)

# =============================================================================
# 17. Real GDP against its pre-pandemic trend
#     A level story rather than a growth rate story: the output that was never
#     made up. Fitted log-linear on the window set in 00_setup.R.
# =============================================================================

trend_fit_data <- seasonal_all |>
  dplyr::select(date, level = gdp_purchasers) |>
  dplyr::filter(!is.na(level))

fit <- stats::lm(
  log(level) ~ as.numeric(date),
  data = dplyr::filter(trend_fit_data,
                       lubridate::year(date) >= trend_window[1],
                       lubridate::year(date) <= trend_window[2])
)

trend_data <- trend_fit_data |>
  dplyr::mutate(trend = exp(stats::predict(fit, newdata = trend_fit_data))) |>
  dplyr::filter(lubridate::year(date) >= trend_window[1])

trend_now <- trend_data |>
  dplyr::filter(date == max(date)) |>
  dplyr::mutate(gap = (level / trend - 1) * 100)

p_trend <- ggplot(trend_data, aes(date)) +
  geom_ribbon(aes(ymin = pmin(level, trend), ymax = pmax(level, trend)),
              fill = pal$rust, alpha = 0.12) +
  geom_line(aes(y = trend), linewidth = 1.1, linetype = "dashed", colour = "grey45") +
  geom_line(aes(y = level), linewidth = 1.6, colour = pal$rust) +
  geom_point(data = trend_now, aes(y = level), size = 3.5, colour = pal$rust) +
  annotate(
    "text",
    x = trend_now$date, y = trend_now$level,
    label = sprintf("%.1f%% %s trend", abs(trend_now$gap),
                    ifelse(trend_now$gap < 0, "below", "above")),
    hjust = 1.05, vjust = 1.8, fontface = "bold", colour = pal$rust, size = 4
  ) +
  annotate(
    "text",
    x = trend_data$date[round(nrow(trend_data) * 0.3)],
    y = max(trend_data$trend) * 0.92,
    label = sprintf("%d to %d trend, extended", trend_window[1], trend_window[2]),
    hjust = 0, fontface = "bold", colour = "grey45", size = 4
  ) +
  scale_x_date(date_breaks = "1 year", labels = lab_year) +
  scale_y_continuous(labels = scales::label_comma()) +
  theme_alfred() +
  labs(
    x = NULL, y = "Quarterly GDP, GHc million, constant prices",
    title = "Real GDP Against Its Pre-Pandemic Trend",
    subtitle = paste0(source_note, ", seasonally adjusted"),
    caption = credit
  )

save_chart(p_trend, "gdp_vs_prepandemic_trend.png", width = 10, height = 6.5)

# =============================================================================
# 18. Informal share of GDP
#     Built on the constant price sheet on purpose. The current price informal
#     column carries a bad value in the 2026 Q2 release: the level falls from
#     113,249 to 26,515 and the published share from 26.9% to 7.1%, which is a
#     workbook error rather than an economic event. 01 warns if that column
#     jumps again.
# =============================================================================

informal_share <- gdp_all |>
  dplyr::transmute(date, share = informal / gdp_purchasers * 100) |>
  dplyr::mutate(share_4q = roll_mean(share)) |>
  dplyr::filter(!is.na(share_4q))

informal_ends <- informal_share |> dplyr::filter(date %in% range(date))

p_informal <- ggplot(informal_share, aes(date, share_4q)) +
  geom_line(linewidth = 1.6, colour = pal$rust) +
  geom_point(data = informal_ends, size = 3.5, colour = pal$rust) +
  geom_text(data = informal_ends, aes(label = fmt_pct(share_4q)),
            vjust = -1.2, fontface = "bold", colour = pal$rust, size = 4.5) +
  scale_x_date(date_breaks = "2 years", labels = lab_year) +
  scale_y_continuous(breaks = scales::pretty_breaks(5), labels = lab_pct) +
  theme_alfred() +
  labs(
    x = NULL, y = "Informal share of GDP",
    title = "The Informal Economy's Share of Ghana's GDP",
    subtitle = paste0(source_note, ", constant prices, four-quarter moving average"),
    caption = credit
  )

save_chart(p_informal, "gdp_informal_share.png", width = 10, height = 6)

# =============================================================================
# 19. Nominal against real growth
#     The gap is the implied deflator, which is where price effects in cocoa and
#     gold show up as apparent growth.
# =============================================================================

price_effect <- current_all |>
  dplyr::transmute(date, Nominal = (gdp_purchasers / dplyr::lag(gdp_purchasers, 4) - 1) * 100) |>
  dplyr::inner_join(dplyr::select(gdp_all, date, Real = growth_gdp), by = "date") |>
  dplyr::filter(!is.na(Nominal), !is.na(Real), lubridate::year(date) >= long_series_start)

price_long <- price_effect |>
  tidyr::pivot_longer(c(Nominal, Real), names_to = "series", values_to = "growth")

price_ends <- price_long |> dplyr::filter(date == max(date))

p_price <- ggplot() +
  geom_ribbon(data = price_effect, aes(date, ymin = Real, ymax = Nominal),
              fill = pal$rust, alpha = 0.12) +
  geom_hline(yintercept = 0, linewidth = 1.5, colour = pal$dark) +
  geom_line(data = price_long, aes(date, growth, colour = series), linewidth = 1.5) +
  geom_point(data = price_ends, aes(date, growth, colour = series),
             size = 3.5, shape = 21, stroke = 2, fill = "floralwhite") +
  ggrepel::geom_text_repel(
    data = price_ends,
    aes(date, growth, colour = series, label = sprintf("%s\n%.1f%%", series, growth)),
    hjust = 0, direction = "y", nudge_x = 90, size = 4.5,
    fontface = "bold", segment.alpha = 0
  ) +
  scale_x_date(date_breaks = "2 years", labels = lab_year,
               expand = expansion(mult = c(0.02, 0.16))) +
  scale_y_continuous(breaks = scales::pretty_breaks(6), labels = lab_pct) +
  scale_colour_manual(values = c(Nominal = pal$rust, Real = "grey45")) +
  theme_alfred() +
  labs(
    x = NULL, y = "Year-on-year growth (%)",
    title = "<span style='color:#A9432C;'>Nominal</span> Against <span style='color:grey45;'>Real</span> GDP Growth",
    subtitle = paste0(source_note, ". The shaded gap is the implied GDP deflator"),
    caption = credit
  )

save_chart(p_price, "gdp_nominal_vs_real.png", width = 10, height = 6.5)

# =============================================================================
# 20. Sub-sector growth, small multiples
#     The chart that used to be built off the redundant Y on Y sheets, rebuilt
#     from the value sheets so it stays in step with everything else.
# =============================================================================

plot_subsector_facets <- function(group_name, start_year = contribution_start) {

  d <- subsector_values |>
    dplyr::filter(group == group_name, sector != "total_value_added",
                  lubridate::year(date) >= start_year, !is.na(yoy))

  ends <- d |> dplyr::group_by(label) |> dplyr::filter(date == max(date)) |> dplyr::ungroup()

  ggplot(d, aes(date, yoy * 100)) +
    geom_hline(yintercept = 0, linewidth = 1, colour = pal$light) +
    geom_line(linewidth = 1, colour = pal$rust) +
    geom_point(data = ends, size = 2.4, colour = pal$rust) +
    geom_text(data = ends, aes(label = fmt_pct(yoy * 100)),
              hjust = 1, vjust = -0.8, fontface = "bold", colour = pal$rust, size = 4) +
    facet_wrap(~ stringr::str_wrap(label, 28), scales = "free_y") +
    scale_x_date(date_breaks = "2 years", labels = lab_year) +
    scale_y_continuous(breaks = scales::pretty_breaks(4), labels = lab_pct) +
    theme_alfred() +
    no_axis_titles() +
    labs(
      title = sprintf("Real GDP Growth in %s by Sub-Sector", group_name),
      subtitle = source_note,
      caption = credit
    )
}

save_chart(plot_subsector_facets("Services"), "growth_subsector_facets_services.png", width = 12.5, height = 8)
save_chart(plot_subsector_facets("Industry"), "growth_subsector_facets_industry.png", width = 11, height = 6.5)

# =============================================================================
# 21. What is inside mining
#     Gold, oil and everything else, as contributions to overall growth.
# =============================================================================

mining_mix <- contribution_all |>
  dplyr::transmute(
    date,
    Gold           = gold,
    `Oil and Gas`  = oil_and_gas,
    `Other mining` = mining_and_quarrying - oil_and_gas - gold
  ) |>
  tidyr::pivot_longer(-date, names_to = "series", values_to = "contribution") |>
  dplyr::filter(lubridate::year(date) >= contribution_start)

mining_total <- contribution_all |>
  dplyr::filter(lubridate::year(date) >= contribution_start) |>
  dplyr::select(date, contribution = mining_and_quarrying)

p_mining_mix <- ggplot() +
  geom_col(data = mining_mix, aes(date, contribution, fill = series), position = "stack") +
  geom_line(data = mining_total, aes(date, contribution), linewidth = 1.4, colour = pal$dark) +
  geom_hline(yintercept = 0, linewidth = 1.5, colour = pal$dark) +
  scale_x_date(date_breaks = "1 year", labels = lab_year) +
  scale_y_continuous(breaks = scales::pretty_breaks(6)) +
  scale_fill_manual(values = c(Gold = pal$gold, `Oil and Gas` = "grey45",
                               `Other mining` = pal$positive)) +
  theme_alfred() +
  no_axis_titles() +
  legend_top() +
  labs(
    title = "What Is Inside Mining's Contribution to GDP Growth",
    subtitle = paste0(source_note, ". Percentage points of overall growth; the line is mining as a whole"),
    caption = credit
  )

save_chart(p_mining_mix, "sector_focus_mining_decomposition.png", width = 10, height = 6.5)

# =============================================================================
# 22. Breadth of growth
#     Whether a good quarter is broad-based or two sub-sectors carrying twenty.
# =============================================================================

breadth <- subsector_values |>
  dplyr::filter(sector != "total_value_added", !is.na(yoy)) |>
  dplyr::inner_join(dplyr::select(gdp_all, date, growth_gdp), by = "date") |>
  dplyr::group_by(date) |>
  dplyr::summarise(
    `Growing at all`             = mean(yoy > 0) * 100,
    `Beating the headline rate`  = mean(yoy * 100 > growth_gdp) * 100,
    .groups = "drop"
  ) |>
  tidyr::pivot_longer(-date, names_to = "series", values_to = "share") |>
  dplyr::filter(lubridate::year(date) >= long_series_start)

breadth_ends <- breadth |> dplyr::filter(date == max(date))

p_breadth <- ggplot(breadth, aes(date, share, colour = series)) +
  geom_hline(yintercept = 50, linewidth = 1, colour = pal$light) +
  geom_line(linewidth = 1.5) +
  geom_point(data = breadth_ends, size = 3.5, shape = 21, stroke = 2, fill = "floralwhite") +
  ggrepel::geom_text_repel(
    data = breadth_ends,
    aes(label = sprintf("%s\n%.0f%%", stringr::str_wrap(series, 18), share)),
    hjust = 0, direction = "y", nudge_x = 90, size = 4.2,
    fontface = "bold", segment.alpha = 0
  ) +
  scale_x_date(date_breaks = "2 years", labels = lab_year,
               expand = expansion(mult = c(0.02, 0.22))) +
  scale_y_continuous(limits = c(0, 100), breaks = seq(0, 100, 25), labels = lab_pct) +
  scale_colour_manual(values = c(`Growing at all` = pal$rust,
                                 `Beating the headline rate` = "grey45")) +
  theme_alfred() +
  labs(
    x = NULL, y = "Share of the 22 sub-sectors",
    title = "How Broad Is Ghana's Growth?",
    subtitle = paste0(source_note, ". Share of sub-sectors growing year on year, and share growing faster than overall GDP"),
    caption = credit
  )

save_chart(p_breadth, "gdp_growth_breadth.png", width = 10.5, height = 6.5)

# =============================================================================
# 23. Growth against size, latest quarter
#     The fast growers are small and the big ones are flat, in one frame.
# =============================================================================

total_va_latest <- gdp_all |>
  dplyr::filter(date == latest_quarter) |>
  dplyr::pull(total_value_added)

scatter <- subsector_latest |>
  dplyr::mutate(share = value / total_va_latest * 100)

p_scatter <- ggplot(scatter, aes(share, growth_pct, colour = group)) +
  geom_hline(yintercept = headline_growth, linetype = "dashed",
             colour = pal$ref, linewidth = 1) +
  geom_hline(yintercept = 0, linewidth = 1, colour = pal$light) +
  geom_point(aes(size = abs(contribution)), alpha = 0.85) +
  ggrepel::geom_text_repel(
    aes(label = stringr::str_wrap(label, 22)),
    size = 3.4, fontface = "bold", seed = 1, box.padding = 0.5, max.overlaps = 20
  ) +
  annotate("text", x = max(scatter$share), y = headline_growth,
           label = sprintf("Overall growth %.1f%%", headline_growth),
           hjust = 1, vjust = -0.7, fontface = "bold", colour = pal$ref, size = 4) +
  scale_size(range = c(3, 14), guide = "none") +
  scale_x_continuous(labels = lab_pct) +
  scale_y_continuous(labels = lab_pct) +
  scale_colour_manual(values = sector_cols) +
  theme_alfred() +
  legend_top() +
  labs(
    x = "Share of gross value added", y = "Year-on-year growth",
    title = sprintf("Growth Against Size by Sub-Sector, %s", latest_label),
    subtitle = paste0(source_note, ". Point size is the contribution to overall growth"),
    caption = credit
  )

save_chart(p_scatter, "gdp_growth_vs_size.png", width = 11, height = 7.5)

# =============================================================================
# 24. Where the growth since 2019 Q4 actually came from
#     Four-quarter totals, so this is a level comparison rather than a rate, and
#     seasonality drops out. Bars sum to total real growth over the period.
# =============================================================================

rolling_subsector <- subsector_values |>
  dplyr::filter(sector != "total_value_added") |>
  dplyr::arrange(group, sector, date) |>
  dplyr::group_by(group, sector, label) |>
  dplyr::mutate(sum4 = roll_sum(value)) |>
  dplyr::ungroup()

rolling_total <- gdp_all |> dplyr::transmute(date, sum4_total = roll_sum(total_value_added))

base_total <- rolling_total |> dplyr::filter(date == covid_base) |> dplyr::pull(sum4_total)

cumulative <- dplyr::inner_join(
  rolling_subsector |> dplyr::filter(date == covid_base) |> dplyr::select(label, base = sum4),
  rolling_subsector |> dplyr::filter(date == latest_quarter) |> dplyr::select(label, now = sum4),
  by = "label"
) |>
  dplyr::mutate(
    contribution = (now - base) / base_total * 100,
    sign = dplyr::if_else(contribution >= 0, "Positive", "Negative")
  )

p_cumulative <- ggplot(cumulative, aes(forcats::fct_reorder(stringr::str_wrap(label, 40), contribution),
                                       contribution, fill = sign)) +
  geom_chicklet(width = 0.8) +
  geom_hline(yintercept = 0, linewidth = 1.5, colour = pal$dark) +
  geom_text(
    aes(label = fmt_pp(contribution, 1),
        hjust = dplyr::if_else(contribution > 0, 1.1, -0.1)),
    fontface = "bold", colour = "floralwhite", size = 4.5
  ) +
  coord_flip(clip = "off") +
  scale_fill_manual(values = c(Positive = pal$positive, Negative = pal$negative)) +
  theme_alfred() +
  no_axis_titles() +
  theme(axis.text.x = element_blank()) +
  labs(
    title = "Where Ghana's Growth Since 2019 Has Come From",
    subtitle = paste0(source_note,
                      ". Change in four-quarter output between 2019 Q4 and ", latest_label,
                      ", as a percentage of 2019 GDP"),
    caption = credit
  )

save_chart(p_cumulative, "gdp_cumulative_contrib_since_2019.png", width = 12, height = 8)

# =============================================================================
# 25. Four-quarter rolling growth
#     What to use when writing about a trend rather than a single print.
# =============================================================================

rolling_growth <- gdp_all |>
  dplyr::transmute(
    date,
    quarterly = growth_gdp,
    sum4 = roll_sum(gdp_purchasers)
  ) |>
  dplyr::mutate(rolling = (sum4 / dplyr::lag(sum4, 4) - 1) * 100) |>
  dplyr::filter(!is.na(rolling), lubridate::year(date) >= long_series_start)

rolling_end <- rolling_growth |> dplyr::filter(date == max(date))

p_rolling <- ggplot(rolling_growth, aes(date)) +
  geom_hline(yintercept = 0, linewidth = 1.5, colour = pal$dark) +
  geom_line(aes(y = quarterly), linewidth = 1, colour = pal$light) +
  geom_line(aes(y = rolling), linewidth = 1.8, colour = pal$rust) +
  geom_point(data = rolling_end, aes(y = rolling), size = 3.5, colour = pal$rust) +
  geom_text(data = rolling_end, aes(y = rolling, label = fmt_pct(rolling)),
            vjust = -1.2, fontface = "bold", colour = pal$rust, size = 4.5) +
  scale_x_date(date_breaks = "2 years", labels = lab_year) +
  scale_y_continuous(breaks = scales::pretty_breaks(5), labels = lab_pct) +
  theme_alfred() +
  labs(
    x = NULL, y = "GDP growth (%)",
    title = "Real GDP Growth, <span style='color:#A9432C;'>Four-Quarter Average</span> Against <span style='color:grey80;'>Single Quarters</span>",
    subtitle = source_note,
    caption = credit
  )

save_chart(p_rolling, "gdp_rolling_annual_growth.png", width = 10, height = 6.5)

# =============================================================================
# 26. Sub-sector output levels, 2013 Q4 = 100
#     Growth rates hide stagnation. Levels do not.
# =============================================================================

index_data <- rolling_subsector |>
  dplyr::filter(sector %in% index_focus, !is.na(sum4)) |>
  dplyr::group_by(sector, label) |>
  dplyr::mutate(index = sum4 / sum4[match(index_base, date)] * 100) |>
  dplyr::ungroup() |>
  dplyr::filter(date >= index_base, !is.na(index))

index_ends <- index_data |> dplyr::filter(date == max(date))

p_index <- ggplot(index_data, aes(date, index, colour = label)) +
  geom_hline(yintercept = 100, linewidth = 1, colour = pal$light) +
  geom_line(linewidth = 1.5) +
  geom_point(data = index_ends, size = 3.5, shape = 21, stroke = 2, fill = "floralwhite") +
  ggrepel::geom_text_repel(
    data = index_ends,
    aes(label = sprintf("%s\n%.0f", stringr::str_wrap(label, 20), index)),
    hjust = 0, direction = "y", nudge_x = 90, size = 4,
    fontface = "bold", segment.alpha = 0
  ) +
  scale_x_date(date_breaks = "2 years", labels = lab_year,
               expand = expansion(mult = c(0.02, 0.20))) +
  scale_y_continuous(breaks = scales::pretty_breaks(6)) +
  scale_colour_manual(values = setNames(sector_palette(dplyr::n_distinct(index_data$label)),
                                        sort(unique(index_data$label)))) +
  theme_alfred() +
  labs(
    x = NULL, y = "Output, 2013 Q4 = 100",
    title = "Real Output by Sub-Sector, 2013 Q4 = 100",
    subtitle = paste0(source_note, ", four-quarter totals at constant prices"),
    caption = credit
  )

save_chart(p_index, "gdp_subsector_index.png", width = 11, height = 6.5)

# =============================================================================
# 27. The tax wedge
#     Growth in value added at basic prices against growth at purchasers' value.
#     The gap is net indirect taxes: a revenue story sitting inside a GDP release.
# =============================================================================

wedge <- gdp_all |>
  dplyr::transmute(
    date,
    `Value added (basic prices)` = (total_value_added / dplyr::lag(total_value_added, 4) - 1) * 100,
    `GDP (purchasers' value)`    = growth_gdp
  ) |>
  dplyr::filter(!is.na(`Value added (basic prices)`), lubridate::year(date) >= long_series_start)

wedge_long <- wedge |>
  tidyr::pivot_longer(-date, names_to = "series", values_to = "growth")

wedge_ends <- wedge_long |> dplyr::filter(date == max(date))

p_wedge <- ggplot() +
  geom_ribbon(data = wedge,
              aes(date,
                  ymin = pmin(`Value added (basic prices)`, `GDP (purchasers' value)`),
                  ymax = pmax(`Value added (basic prices)`, `GDP (purchasers' value)`)),
              fill = pal$rust, alpha = 0.12) +
  geom_hline(yintercept = 0, linewidth = 1.5, colour = pal$dark) +
  geom_line(data = wedge_long, aes(date, growth, colour = series), linewidth = 1.5) +
  ggrepel::geom_text_repel(
    data = wedge_ends,
    aes(date, growth, colour = series,
        label = sprintf("%s\n%.1f%%", stringr::str_wrap(series, 18), growth)),
    hjust = 0, direction = "y", nudge_x = 90, size = 4,
    fontface = "bold", segment.alpha = 0
  ) +
  scale_x_date(date_breaks = "2 years", labels = lab_year,
               expand = expansion(mult = c(0.02, 0.22))) +
  scale_y_continuous(breaks = scales::pretty_breaks(6), labels = lab_pct) +
  scale_colour_manual(values = c(`Value added (basic prices)` = "grey45",
                                 `GDP (purchasers' value)` = pal$rust)) +
  theme_alfred() +
  labs(
    x = NULL, y = "Year-on-year growth (%)",
    title = "The Tax Wedge in the GDP Release",
    subtitle = paste0(source_note, ". The gap between the two lines is net indirect taxes"),
    caption = credit
  )

save_chart(p_wedge, "gdp_tax_wedge.png", width = 10.5, height = 6.5)

# =============================================================================
# 28. The seasonal shape of the economy
#     Why the unadjusted numbers move the way they do. Agriculture's swing is
#     the reason a weak Q2 headline is not always a weak quarter.
# =============================================================================

quarter_shares <- gdp_all |>
  dplyr::select(date, Agriculture = agriculture, Industry = industry, Services = services) |>
  tidyr::pivot_longer(-date, names_to = "sector", values_to = "value") |>
  dplyr::mutate(year = lubridate::year(date), q = lubridate::quarter(date)) |>
  dplyr::group_by(sector, year) |>
  dplyr::filter(dplyr::n() == 4) |>
  dplyr::mutate(share = value / sum(value) * 100) |>
  dplyr::ungroup()

recent_years <- sort(unique(quarter_shares$year), decreasing = TRUE)[1:5]

seasonal_shape <- quarter_shares |>
  dplyr::filter(year %in% recent_years) |>
  dplyr::group_by(sector, q) |>
  dplyr::summarise(share = mean(share), .groups = "drop") |>
  dplyr::mutate(q = factor(sprintf("Q%d", q)))

p_seasonal_shape <- ggplot(seasonal_shape, aes(q, share, fill = sector)) +
  geom_chicklet(width = 0.75) +
  geom_hline(yintercept = 25, linetype = "dashed", linewidth = 1, colour = "grey45") +
  geom_text(aes(label = fmt_pct(share, 0)), vjust = 1.4,
            fontface = "bold", colour = "floralwhite", size = 4) +
  facet_wrap(~ sector) +
  scale_y_continuous(labels = lab_pct) +
  scale_fill_manual(values = sector_cols) +
  theme_alfred() +
  no_axis_titles() +
  theme(axis.text.y = element_blank()) +
  labs(
    title = "The Seasonal Shape of Ghana's Economy",
    subtitle = sprintf("%s, unadjusted. Average share of annual output falling in each quarter, %d to %d. The dashed line is an even quarter",
                       source_note, min(recent_years), max(recent_years)),
    caption = credit
  )

save_chart(p_seasonal_shape, "gdp_seasonal_shape.png", width = 11, height = 6)
