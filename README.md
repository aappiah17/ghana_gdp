# Ghana quarterly GDP charts

```
R/00_setup.R                 packages, paths, palette, theme_alfred(), save_chart()
R/01_data_gdp_quarterly.R    one reader for the whole GSS workbook, plus the derived tables
R/02_charts_gdp_quarterly.R  the standing chart set, one block each
R/03_charts_gdp_extra.R      additional charts, built when a piece needs them
```

To refresh everything: `source("R/02_charts_gdp_quarterly.R")`. It sources the other
two. `03` is independent and sources them itself.

Set `gdp_paths$quarterly` and `chart_dir` at the top of `00_setup.R`. Nothing else
in the code carries a file path.

The previews below point at `./Charts/GDP/`, which is where `save_chart()` writes.
They appear once the script has run, so if you change `chart_dir` the paths here
need the same change.



### Headline growth

Year-on-year growth in real GDP at purchasers' value.

![overall_gdp](./Charts/overall_gdp.png)

### Contribution to growth

Agriculture, industry and services as percentage points of growth, with total
value added growth as the line. 

![gdp_contribution_quarter](./Charts/gdp_contribution_quarter.png)

The same idea inside each sector, where the denominator is the sector's own total
rather than GDP.

![ind_gdp_contribution_quarter](./Charts/ind_gdp_contribution_quarter.png)

![agric_gdp_contribution_quarter](./Charts/agric_gdp_contribution_quarter.png)

![svc_gdp_contribution_quarter](./Charts/svc_gdp_contribution_quarter.png)

Current price sectoral shares, stacked.

![gdp_sector_shares_quarter](./Charts/gdp_sector_shares_quarter.png)

### The latest quarter

Growth by sub-sector, ranked, with the headline rate as a dashed reference.

![growth_subsector_bar](./Charts/growth_subsector_bar.png)

The same sub-sectors as percentage points of overall growth, using the
contributions GSS publishes.

![contrib_subsector_bar](./Charts/contrib_subsector_bar.png)

### Sectors in focus

Oil and gas growth.

![sector_focus_oil](./Charts/sector_focus_oil.png)

Mining excluding oil, by quarter.

![sector_focus_mining](./Charts/sector_focus_mining.png)

Gold against everything else.

![sector_focus_gold](./Charts/sector_focus_gold.png)

### Since 2019 Q4

Seasonally adjusted GDP indexed to the pre-Covid quarter, overall and then split
by sector and by industrial sub-sector.

![gdp_since_q42019](./Charts/gdp_since_q42019.png)

![gdp_since_q42019_sec](./Charts/gdp_since_q42019_sec.png)

![gdp_since_q42019_ind](./Charts/gdp_since_q42019_ind.png)

## Additional charts

Quarter-on-quarter growth, seasonally adjusted, last twelve quarters. The series a
technical recession is defined on.

![gdp_qoq_momentum](./Charts/gdp_qoq_momentum.png)

Real GDP against its 2015 to 2019 trend, extended. A level story rather than a
rate.

![gdp_vs_prepandemic_trend](./Charts/gdp_vs_prepandemic_trend.png)

Share of sub-sectors growing, and share beating the headline rate.

![gdp_growth_breadth](./Charts/gdp_growth_breadth.png)

Growth against share of GDP, latest quarter. The fast growers are small.

![gdp_growth_vs_size](./Charts/gdp_growth_vs_size.png)

Overall against non-oil growth. The gap is oil's pull on the headline.

![gdp_oil_vs_nonoil](./Charts/gdp_oil_vs_nonoil.png)

Nominal against real growth. The shaded gap is the implied deflator.

![gdp_nominal_vs_real](./Charts/gdp_nominal_vs_real.png)

Where growth since 2019 Q4 came from, on four-quarter totals.

![gdp_cumulative_contrib_since_2019](./Charts/gdp_cumulative_contrib_since_2019.png)

Four-quarter rolling growth against single quarters.

![gdp_rolling_annual_growth](./Charts/gdp_rolling_annual_growth.png)

Sub-sector output levels, 2013 Q4 = 100. Growth rates hide stagnation.

![gdp_subsector_index](./Charts/gdp_subsector_index.png)

Gold, oil and other mining as contributions to overall growth.

![sector_focus_mining_decomposition](./Charts/sector_focus_mining_decomposition.png)

Value added at basic prices against GDP at purchasers' value. The gap is net
indirect taxes.

![gdp_tax_wedge](./Charts/gdp_tax_wedge.png)

Average share of annual output falling in each quarter, by sector.

![gdp_seasonal_shape](./Charts/gdp_seasonal_shape.png)

Informal share of GDP, four-quarter average, constant prices.

![gdp_informal_share](./Charts/gdp_informal_share.png)

Sub-sector growth as small multiples. An industry version is written alongside it.

![growth_subsector_facets_services](./Charts/growth_subsector_facets_services.png)