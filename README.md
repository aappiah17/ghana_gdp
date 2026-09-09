# Ghana quarterly GDP charts


```
R/00_setup.R                 packages, paths, palette, theme_alfred(), save_chart()
R/01_data_gdp_quarterly.R    one reader for the whole GSS workbook, plus the derived tables
R/02_charts_gdp_quarterly.R  the charts, one block each
```

To refresh everything: `source("R/02_charts_gdp_quarterly.R")`. It sources the other two.

Set `gdp_paths$quarterly` and `chart_dir` at the top of `00_setup.R`. Nothing else
in the code carries a file path.

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
