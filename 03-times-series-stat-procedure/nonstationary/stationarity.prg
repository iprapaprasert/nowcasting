' Stationarity
%path = @runpath
cd %path 

wfopen "stationarity_data"

spool report
report.title Report
report.options titles comments displaynames

' Q1
smpl @all
series lchfusd = log(chfusd)
series lgbpusd = log(gbpusd)
series lcadusd = log(cadusd)
smpl 1976 2009
graph graph01_plots.line lcadusd lchfusd lgbpusd

report.append(name=graph01_plots) graph01_plots
report.comment graph01_plots "All three exchange rate series show a tendency to drift over time without returning to a consistent mean or trend. This behavior suggests the presence of stochastic trends, a common feature of non-stationary time series. The series do not fluctuate randomly around a fixed mean or deterministic trend. Instead, they appear to evolve in a random walk-like manner, which is indicative of non-stationarity."

' Q2
freeze(table01_lchfusd_correlogram) lchfusd.correl(12)
table01_lchfusd_correlogram.displayname Correlogram of log(chfusd)

report.append(name=table01_lchfusd_correlogram) table01_lchfusd_correlogram
report.comment table01_lchfusd_correlogram "Correlogram of log(chfusd) suggesting the presence of unit root."

' Q3
freeze(table02_df_none) lchfusd.uroot(exog=none, adf, lag=0)
table02_df_none.displayname Dickey-Fuller Unit Root Test on log(chfusd) without exogenous
report.append(name=table02_df_none) table02_df_none

freeze(table03_df_constant) lchfusd.uroot(exog=const, adf, lag=0)
table03_df_constant.displayname Dickey-Fuller Unit Root Test on log(chfusd) with constant
report.append(name=table03_df_constant) table03_df_constant

' Q4
freeze(table04_adf_none) lchfusd.uroot(exog=none, adf, lagmethod=sic)
freeze(table05_adf_constant) lchfusd.uroot(exog=const, adf, lagmethod=sic)

' Q5
freeze(table06_kpss_constant) lchfusd.uroot(exog=const, kpss)
freeze(table07_kpss_linear) lchfusd.uroot(exog=trend, kpss)

' Q6
'' Part 1
freeze(table08_dlchfusd_correlogram) dlog(chfusd).correl(12)

'' Part 2
smpl 1976 2009m11
equation eq01_constant.ls dlog(chfusd) c
equation eq02_random_walk.ls log(chfusd) c log(chfusd(-1))
freeze(table09_eq01_auto) eq01_constant.auto(12)
freeze(graph_eq01_resids) eq01_constant.resids(g)

'' Part 3
freeze(graph02_forecast) eq01_constant.forecast(e, g, ga, forcsmpl=2009m12 2009m12) chfusd_f

'' Part 4
smpl 2009m12 2009m12
graph graph03_with_random.plot chfusd chfusd_f 1.005

report.display


