%path = @runpath
cd %path
wfopen data

' 1. Stationarity-inducing transformation
smpl @all
series lgdp = log(gdp)
freeze(lgdp_hpf) lgdp.hpf(lambda=1600) lgdp_trend @ lgdp_gap

freeze(rer_hpf) rer.hpf(lambda=1600) rer_trend @ rer_gap

' 2. Estimate VAR
smpl 1993 2012
var canada_var.ls 1 4 lgdp_gap rer_gap infl mpr

'' Stationary test
freeze(canada_arroots) canada_var.arroots(graph)

' 3. Estimate variation of VAR
var canada2_var.ls 1 1 lgdp_gap rer_gap infl mpr
freeze(canada2_arlm) canada2_var.arlm(8)

' 4. Lag length criteria of canada_var
freeze(canada_laglen) canada_var.laglen(8) 

' 5. Reestimate the optimal VAR and forecast
var canada_lag2_var.ls 1 2 lgdp_gap rer_gap infl mpr

'' Dynamic forecast
smpl 2013 2014
freeze(canada_lag2_forecast) canada_lag2_var.forecast(g, e) fo fose

''' Generate the upper and lower inflation band
smpl @all
series infl_fo_upper = @recode(@during("2013 2014"), infl_fo + 2*infl_fose, infl)
series infl_fo_lower = @recode(@during("2013 2014"), infl_fo - 2*infl_fose, infl)

graph infl_fo_line.line infl infl_fo infl_fo_upper infl_fo_lower

'' Static forecast
smpl 2013 2014
freeze(canada_lag2_fit) canada_lag2_var.fit(g, e) fit itse

''' Generate the upper and lower inflation band
smpl @all
series infl_fit_upper = @recode(@during("2013 2014"), infl_fit + 2*infl_fitse, infl)
series infl_fit_lower = @recode(@during("2013 2014"), infl_fit - 2*infl_fitse, infl)

graph infl_fit_line.line infl infl_fit infl_fit_upper infl_fit_lower

