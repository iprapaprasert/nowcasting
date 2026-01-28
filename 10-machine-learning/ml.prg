%path = @runpath
cd %path
wfopen nwc

' 2. Nowcasting with Machine Learning
'' crisis
pageselect Quarterly
smpl @all
series crisis = @date=@dateval("2020q2") or @date=@dateval("2021q3") 

'' Convert monthly to quarterly data
copy(o, c=sn) Monthly\retail_sales *
copy(o, c=an) Monthly\pmi_manu_new *
copy(o, c=sn) Monthly\im *

'' Ridge Regression
smpl 2011q3 2022q3
equation ridge.enet(penalty=ridge, cvseed=0) dlog(rgdp) dlog(rgdp(-1)) dlog(rgdp(-2)) dlog(rgdp(-3)) dlog(retail_sales) dlog(pmi_manu_new) dlog(im) crisis c

''' In-sample fit 2018q1-2022q3
freeze(ridge_fit) ridge.fit(g, ga, e, forcsmpl=2018q1 2022q3) rgdp_fit_ridge

''' Forecast 2022q4
freeze(ridge_forecast) ridge.forecast(g, ga, e, forcsmpl=2022q4 2022q4) rgdp_forecast_ridge

'' Lasso Regression
smpl 2011q3 2022q3
equation lasso.enet(penalty=lasso, cvseed=0) dlog(rgdp) dlog(rgdp(-1)) dlog(rgdp(-2)) dlog(rgdp(-3)) dlog(retail_sales) dlog(pmi_manu_new) dlog(im) crisis c

''' In-sample fit 2018q1-2022q3
freeze(lasso_fit) lasso.fit(g, ga, e, forcsmpl=2018q1 2022q3) rgdp_fit_lasso

''' Forecast 2022q4
freeze(lasso_forecast) lasso.forecast(g, ga, e, forcsmpl=2022q4 2022q4) rgdp_forecast_lasso

'' Elastic Net Regression
smpl 2011q3 2022q3
equation enet.enet(penalty=enet, cvseed=0) dlog(rgdp) dlog(rgdp(-1)) dlog(rgdp(-2)) dlog(rgdp(-3)) dlog(retail_sales) dlog(pmi_manu_new) dlog(im) crisis c

''' In-sample fit 2018q1-2022q3
freeze(enet_fit) enet.fit(g, ga, e, forcsmpl=2018q1 2022q3) rgdp_fit_enet

''' Forecast 2022q4
freeze(enet_forecast) enet.forecast(g, ga, e, forcsmpl=2022q4 2022q4) rgdp_forecast_enet

'' Compare the forecasts
smpl 2019q4 2022
freeze(forecast_table) @pcy(rgdp_forecast_ridge) @pcy(rgdp_forecast_lasso) @pcy(rgdp_forecast_enet)
graph forecast_line.line @pcy(rgdp_forecast_ridge) @pcy(rgdp_forecast_lasso) @pcy(rgdp_forecast_enet)

