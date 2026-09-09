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

The previews below point at `Charts/GDP/`, which is where `save_chart()` writes.
They appear once the script has run, so if you change `chart_dir` the paths here
need the same change.

## The standing set

Fourteen charts, refreshed each quarter.

### Headline growth

<img src="Charts/GDP/overall_gdp.png" width="100%">

`overall_gdp.png`. Year-on-year growth in real GDP at purchasers' value, taken
straight from the published growth column. The last point is labelled.

### Contribution to growth

<img src="Charts/GDP/gdp_contribution_quarter.png" width="100%">

`gdp_contribution_quarter.png`. Agriculture, industry and services as percentage
points of growth, with total value added growth as the line. Bars sum to the line
because both sit on a value added basis.

<table>
<tr>
<td width="50%"><img src="Charts/GDP/ind_gdp_contribution_quarter.png" width="100%"></td>
<td width="50%"><img src="Charts/GDP/agric_gdp_contribution_quarter.png" width="100%"></td>
</tr>
<tr>
<td><code>ind_gdp_contribution_quarter.png</code><br>Industry sub-sectors against industry growth.</td>
<td><code>agric_gdp_contribution_quarter.png</code><br>Agriculture sub-sectors against agriculture growth.</td>
</tr>
<tr>
<td><img src="Charts/GDP/svc_gdp_contribution_quarter.png" width="100%"></td>
<td><img src="Charts/GDP/gdp_sector_shares_quarter.png" width="100%"></td>
</tr>
<tr>
<td><code>svc_gdp_contribution_quarter.png</code><br>Services sub-sectors against services growth.</td>
<td><code>gdp_sector_shares_quarter.png</code><br>Current price sectoral shares, stacked.</td>
</tr>
</table>

### The latest quarter

<table>
<tr>
<td width="50%"><img src="Charts/GDP/growth_subsector_bar.png" width="100%"></td>
<td width="50%"><img src="Charts/GDP/contrib_subsector_bar.png" width="100%"></td>
</tr>
<tr>
<td><code>growth_subsector_bar.png</code><br>Growth by sub-sector, ranked, with the headline rate as a dashed reference.</td>
<td><code>contrib_subsector_bar.png</code><br>The same sub-sectors as percentage points of overall growth.</td>
</tr>
</table>

### Sectors in focus

<table>
<tr>
<td width="33%"><img src="Charts/GDP/sector_focus_oil.png" width="100%"></td>
<td width="33%"><img src="Charts/GDP/sector_focus_mining.png" width="100%"></td>
<td width="33%"><img src="Charts/GDP/sector_focus_gold.png" width="100%"></td>
</tr>
<tr>
<td><code>sector_focus_oil.png</code><br>Oil and gas growth.</td>
<td><code>sector_focus_mining.png</code><br>Mining excluding oil, by quarter.</td>
<td><code>sector_focus_gold.png</code><br>Gold against everything else.</td>
</tr>
</table>

### Since 2019 Q4

<table>
<tr>
<td width="33%"><img src="Charts/GDP/gdp_since_q42019.png" width="100%"></td>
<td width="33%"><img src="Charts/GDP/gdp_since_q42019_sec.png" width="100%"></td>
<td width="33%"><img src="Charts/GDP/gdp_since_q42019_ind.png" width="100%"></td>
</tr>
<tr>
<td><code>gdp_since_q42019.png</code><br>Seasonally adjusted GDP, indexed to the pre-Covid quarter.</td>
<td><code>gdp_since_q42019_sec.png</code><br>The same, by sector.</td>
<td><code>gdp_since_q42019_ind.png</code><br>The same, by industrial sub-sector.</td>
</tr>
</table>

## Additional charts

Built when a piece needs them. Momentum, breadth and the trend gap arguably belong
in the standing set.

<table>
<tr>
<td width="50%"><img src="Charts/GDP/gdp_qoq_momentum.png" width="100%"></td>
<td width="50%"><img src="Charts/GDP/gdp_vs_prepandemic_trend.png" width="100%"></td>
</tr>
<tr>
<td><code>gdp_qoq_momentum.png</code><br>Quarter-on-quarter growth, seasonally adjusted, last twelve quarters. The series a technical recession is defined on.</td>
<td><code>gdp_vs_prepandemic_trend.png</code><br>Real GDP against its 2015 to 2019 trend, extended. A level story rather than a rate.</td>
</tr>
<tr>
<td><img src="Charts/GDP/gdp_growth_breadth.png" width="100%"></td>
<td><img src="Charts/GDP/gdp_growth_vs_size.png" width="100%"></td>
</tr>
<tr>
<td><code>gdp_growth_breadth.png</code><br>Share of sub-sectors growing, and share beating the headline rate.</td>
<td><code>gdp_growth_vs_size.png</code><br>Growth against share of GDP. The fast growers are small.</td>
</tr>
<tr>
<td><img src="Charts/GDP/gdp_oil_vs_nonoil.png" width="100%"></td>
<td><img src="Charts/GDP/gdp_nominal_vs_real.png" width="100%"></td>
</tr>
<tr>
<td><code>gdp_oil_vs_nonoil.png</code><br>Overall against non-oil growth. The gap is oil's pull on the headline.</td>
<td><code>gdp_nominal_vs_real.png</code><br>Nominal against real growth. The shaded gap is the implied deflator.</td>
</tr>
<tr>
<td><img src="Charts/GDP/gdp_cumulative_contrib_since_2019.png" width="100%"></td>
<td><img src="Charts/GDP/gdp_rolling_annual_growth.png" width="100%"></td>
</tr>
<tr>
<td><code>gdp_cumulative_contrib_since_2019.png</code><br>Where growth since 2019 Q4 came from, on four-quarter totals.</td>
<td><code>gdp_rolling_annual_growth.png</code><br>Four-quarter rolling growth against single quarters.</td>
</tr>
<tr>
<td><img src="Charts/GDP/gdp_subsector_index.png" width="100%"></td>
<td><img src="Charts/GDP/sector_focus_mining_decomposition.png" width="100%"></td>
</tr>
<tr>
<td><code>gdp_subsector_index.png</code><br>Sub-sector output levels, 2013 Q4 = 100. Growth rates hide stagnation.</td>
<td><code>sector_focus_mining_decomposition.png</code><br>Gold, oil and other mining as contributions to overall growth.</td>
</tr>
<tr>
<td><img src="Charts/GDP/gdp_tax_wedge.png" width="100%"></td>
<td><img src="Charts/GDP/gdp_seasonal_shape.png" width="100%"></td>
</tr>
<tr>
<td><code>gdp_tax_wedge.png</code><br>Value added at basic prices against GDP at purchasers' value. The gap is net indirect taxes.</td>
<td><code>gdp_seasonal_shape.png</code><br>Average share of annual output falling in each quarter, by sector.</td>
</tr>
<tr>
<td><img src="Charts/GDP/gdp_informal_share.png" width="100%"></td>
<td><img src="Charts/GDP/growth_subsector_facets_services.png" width="100%"></td>
</tr>
<tr>
<td><code>gdp_informal_share.png</code><br>Informal share of GDP, four-quarter average, constant prices.</td>
<td><code>growth_subsector_facets_services.png</code><br>Services sub-sector growth, small multiples. An industry version is also written.</td>
</tr>
</table>