# Ghana quarterly GDP charts

Refactor of the GDP plotting script into three files.

```
R/00_setup.R                 packages, paths, palette, theme_alfred(), save_chart()
R/01_data_gdp_quarterly.R    one reader for the whole GSS workbook, plus the derived tables
R/02_charts_gdp_quarterly.R  the charts, one block each
```

To refresh everything: `source("R/02_charts_gdp_quarterly.R")`. It sources the other two.
To iterate on one chart: source 00 and 01 once, then run that block.

Set `gdp_paths$quarterly` and `chart_dir` at the top of `00_setup.R`. Nothing else
in the code carries a file path.

## What changed

**One reader instead of five.** Every appendix sheet in `gdp_raw.xlsx` has the same
shape: three header rows, a quarter label in the first used column, values to the
right, a footnote row at the bottom. `read_gss_quarter()` handles all of them. It
reads with `col_names = FALSE`, drops empty rows and columns, applies names you
supply positionally, keeps rows whose label starts with a year, and parses the rest
to numeric. That removes `clean_names()` and the fragile `agriculture_2` /
`industry_11` / `total_non_oil_gdp_2` positional names, which silently change
meaning if GSS inserts a column. If the column count no longer matches the names
vector, the reader stops with a message telling you which sheet to look at.

**One date function.** `quarter_to_date()` replaces `convert_date()` and the
`zoo::as.yearqtr(format = "%Y_Q%q")` path. It handles `2006_Q1`, `2013Q1`,
`2025_Q3 *` and `2026_Q1**`, all of which appear in the workbook. The old
`as.yearqtr` route silently failed on the label with the space in it.

**Contributions computed once.** `subsector_contrib` holds each sub-sector's
contribution to its own sector's growth, and `contrib_subsector` holds the
contribution to overall growth taken straight from the workbook's "contribution to
growth rate" sheet. The published series includes gold, which the value sheets do
not carry, so the gold chart no longer needs its own separate read and join.

I checked the published series against your calculation before switching: for
2026 Q1 they agree to three decimals, the 21 published components sum to 6.3685,
and that equals the growth column on the constant price sheet. `01` now runs both
checks on every quarter at load time and warns if either breaks.

**Charts are objects.** Each chart is assigned, then written by `save_chart()`,
which creates the output directory, sets `bg = "floralwhite"` so the theme survives
the PNG, and echoes the path. The three within-sector contribution charts come from
one function called three times.

**Theme.** `theme_alfred()` is the only theme in the file. It uses
`element_markdown()` for title, subtitle and caption, so the coloured-word titles
render, and it leaves `base_family` empty for the device default sans. Charts that
need a legend add `legend_top()`.

## Bugs found in the old script

- The "plot drivers of growth" and "drivers of growth by year" blocks referenced
  `agric_gdp_analytical`, `industry_gdp_analytical` and `services_gdp_analytical`,
  which are only defined inside commented-out blocks. Running the script top to
  bottom errors there.
- Three charts wrote to `Charts/GDP/gdp_contribution_quarter.png` and two to
  `growth_subsector_bar.png` and `gdp_structure.png`, so later ones silently
  overwrote earlier ones. All filenames here are unique; the sectoral share chart
  is now `gdp_sector_shares_quarter.png`.
- In the sub-sector contribution bar chart, label alignment keyed off `growth`
  while the bars plotted `contribution`, so labels sat on the wrong side of any bar
  whose growth and contribution had different signs. It now keys off the plotted
  value.
- `sector_focus.png` set `scale_y_continuous()` twice, so the first one was
  discarded with a warning.
- `service_contrib` was computed and never plotted. It now has a chart.
- `annotate(x = "Cocoa", ...)` in the growth bar chart breaks whenever Cocoa is
  filtered out. The reference label is now positioned by index.
- `size =` on lines is deprecated in ggplot2 3.4 and later. All switched to
  `linewidth =`.

## What was removed

Every commented-out block, the duplicate reads of `current gdp_all`, the
`Y on Y growth rate ...` sheet reads (the same growth is derived from the value
sheets), the second copy of the sectoral structure chart that differed only by
theme and caption, and the `fx_sum` join, which referenced an object this script
never creates.

## Not migrated yet

The annual sections (`annual_gdp.xlsx`, `gdp_annual_prior.xlsx`), the expenditure
sections (`gdp_raw_exp_2.xlsx`) and the MIEG block are still on the old code. They
belong in `03_data_gdp_annual.R` / `04_charts_gdp_annual.R` and a separate MIEG
script, in the same shape as these files: a positional reader per workbook, derived
tables in one place, charts as objects. Send those three workbooks and I will do the
same pass on them, including the annual `clean_sector_gdp_annual()` function, which
currently re-derives the year header row on every call.

## Chart outputs

| File | Chart |
| --- | --- |
| `overall_gdp.png` | headline year-on-year real GDP growth |
| `gdp_contribution_quarter.png` | contribution to growth, three broad sectors |
| `ind_gdp_contribution_quarter.png` | contribution to industry growth by sub-sector |
| `agric_gdp_contribution_quarter.png` | contribution to agriculture growth by sub-sector |
| `svc_gdp_contribution_quarter.png` | contribution to services growth by sub-sector |
| `growth_subsector_bar.png` | latest quarter, growth by sub-sector |
| `contrib_subsector_bar.png` | latest quarter, contribution to overall growth |
| `sector_focus_oil.png` | oil and gas growth |
| `sector_focus_mining.png` | mining excluding oil, by quarter |
| `sector_focus_gold.png` | gold against other sectors |
| `gdp_since_q42019.png` | seasonally adjusted GDP since 2019 Q4 |
| `gdp_since_q42019_sec.png` | the same, by sector |
| `gdp_since_q42019_ind.png` | the same, by industrial sub-sector |
| `gdp_sector_shares_quarter.png` | current price sectoral shares |
