%path = @runpath
cd %path
wfopen nwc

' 1. Nowcast Combinations and in-Sample Forecast Evaluation
pageselect Quarterly
'' Create indenpendent variables
''' Convert monthly to quarterly
copy(c=sn) Monthly\retail_sales *
copy(c=sn) Monthly\im *
copy(c=an) Monthly\pmi_manu_new *
''' crisis
smpl @all
series crisis = @date=@dateval("2020q2") or @date=@dateval("2021q3") 

'' BRIDGE
smpl 2011q3 2022q3
equation bridge.ls dlog(rgdp) dlog(rgdp(-1)) dlog(rgdp(-2)) dlog(rgdp(-3)) dlog(retail_sales) dlog(pmi_manu_new) dlog(im) crisis c

''' Forecast 2022Q4
freeze(bridge_forecast) bridge.forecast(g, ga, e, forcsmpl=2022q4 2022q4) rgdp_forecast_01_bridge

''' Fit 2018Q1-2022Q3
freeze(bridge_fit) bridge.fit(g, ga, e, forcsmpl=2018q1 2022q3) rgdp_fit_01_bridge

'' MIDAS
smpl 2011q3 2022q3
equation midas.midas(lag=auto, maxlag=12) dlog(rgdp) dlog(rgdp(-1)) dlog(rgdp(-2)) dlog(rgdp(-3)) crisis c @ monthly\dlog(retail_sales) monthly\dlog(pmi_manu_new) monthly\dlog(im)

''' Forecast 2022Q4
freeze(midas_forecast) midas.forecast(g, ga, e, forcsmpl=2022q4 2022q4) rgdp_forecast_02_midas

''' Fit 2018Q1-2022Q3
freeze(midas_fit) midas.fit(g, ga, e, forcsmpl=2018q1 2022q3) rgdp_fit_02_midas

'' UMIDAS
smpl 2011q3 2022q3
equation umidas.midas(midwgt=umidas, lag=fixed, fixedlag=3) dlog(rgdp) dlog(rgdp(-1)) dlog(rgdp(-2)) dlog(rgdp(-3)) crisis c @ monthly\dlog(retail_sales) monthly\dlog(pmi_manu_new) monthly\dlog(im)

'' Forecast 2022Q4
freeze(umidas_forecast) umidas.forecast(g, ga, e, forcsmpl=2022q4 2022q4) rgdp_forecast_03_umidas

'' Fit 2018Q1-2022Q3
freeze(umidas_fit) umidas.fit(g, ga, e, forcsmpl=2018q1 2022q3) rgdp_fit_03_umidas

'' MIDAS with PC
pageselect Monthly
smpl @all
group f_data.add im pmi_manu_new retail_sales
f_data.makepcomp pc_1 pc_2

pageselect Quarterly
smpl 2011q3 2022q3
equation midaspc.midas(lag=auto, maxlag=12) dlog(rgdp) dlog(rgdp(-1)) dlog(rgdp(-2)) dlog(rgdp(-3)) crisis c @ Monthly\d(pc_1)

''' Forecast 2022q4
freeze(midaspc_forecast) midaspc.forecast(g, ga, e, forcsmpl=2022q4 2022q4) rgdp_forecast_04_midaspc

''' Fit 2018q1-2022q3
freeze(midaspc_fit) midaspc.fit(g, ga, e, forcsmpl=2018q1 2022q3) rgdp_fit_04_midaspc

'' UMIDAS with PC
equation umidaspc.midas(midwgt=umidas, lag=fixed, fixedlag=3) dlog(rgdp) dlog(rgdp(-1)) dlog(rgdp(-2)) dlog(rgdp(-3)) crisis c @ Monthly\d(pc_1)

''' Forecast 2022q4
freeze(umidaspc_forecast) umidaspc.forecast(g, ga, e, forcsmpl=2022q4 2022q4) rgdp_forecast_05_umidaspc

''' Fit 2018q1-2022q3
freeze(umidaspc_fit) umidaspc.fit(g, ga, e, forcsmpl=2018q1 2022q3) rgdp_fit_05_umidaspc

'' 3PRF
include threeprf
call threeprf("im pmi_manu_new retail_sales", rgdp, "2011q3 2022q4")
equation threeprf.ls dlog(rgdp) dlog(rgdp(-1)) dlog(rgdp(-2)) dlog(rgdp(-3)) d(f_hat) crisis c

''' Forecast 2022q4
freeze(threeprf_forecast) threeprf.forecast(g, ga, e, forcsmpl=2022q4 2022q4) rgdp_forecast_06_threeprf

'' Fit 2018q1-2022q3
freeze(threeprf_fit) threeprf.fit(g, ga, e, forcsmpl=2018q1 2022q3) rgdp_fit_06_threeprf

'' MFVAR
smpl 2011q3 2022q3
var mfvar.mfvar 1 1 dlog(rgdp) @ crisis @hf monthly\dlog(retail_sales) monthly\dlog(pmi_manu_new) monthly\dlog(im)

''' Forecast 2022q4
smpl 2022q4 2022q4
freeze(dlog_rgdp_mfvar_fo) mfvar.forecast(g, e) fo_mfvar
smpl @all
series rgdp_forecast_07_mfvar = exp(dlog_rgdp__fo_mfvar + log(rgdp(-1)))

''' Fit 2018q1-2022q3
smpl 2018 2022q3
freeze(dlog_rgdp_mfvar_fit) mfvar.fit(g, e) fit_mfvar
smpl @all
series rgdp_fit_07_mfvar = exp(dlog_rgdp__fit_mfvar + log(rgdp(-1)))

'' Ridge
smpl 2011q3 2022q3
equation ridge.enet(penalty=ridge, cvseed=0) dlog(rgdp) dlog(rgdp(-1)) dlog(rgdp(-2)) dlog(rgdp(-3)) dlog(retail_sales) dlog(pmi_manu_new) dlog(im) crisis c

''' Fit 2018q1-2022q3
freeze(ridge_fit) ridge.fit(g, ga, e, forcsmpl=2018q1 2022q3) rgdp_fit_08_ridge

''' Forecast 2022q4
freeze(ridge_forecast) ridge.forecast(g, ga, e, forcsmpl=2022q4 2022q4) rgdp_forecast_08_ridge

'' Lasso
smpl 2011q3 2022q3
equation lasso.enet(penalty=lasso, cvseed=0) dlog(rgdp) dlog(rgdp(-1)) dlog(rgdp(-2)) dlog(rgdp(-3)) dlog(retail_sales) dlog(pmi_manu_new) dlog(im) crisis c

''' Fit 2018q1-2022q3
freeze(lasso_fit) lasso.fit(g, ga, e, forcsmpl=2018q1 2022q3) rgdp_fit_09_lasso

''' Forecast 2022q4
freeze(lasso_forecast) lasso.forecast(g, ga, e, forcsmpl=2022q4 2022q4) rgdp_forecast_09_lasso

'' Elastic Net
smpl 2011q3 2022q3
equation enet.enet(penalty=enet, cvseed=0) dlog(rgdp) dlog(rgdp(-1)) dlog(rgdp(-2)) dlog(rgdp(-3)) dlog(retail_sales) dlog(pmi_manu_new) dlog(im) crisis c

''' Fit 2018q1-2022q3
freeze(enet_fit) enet.fit(g, ga, e, forcsmpl=2018q1 2022q3) rgdp_fit_10_enet

''' Forecast 2022q4
freeze(enet_forecast) enet.forecast(g, ga, e, forcsmpl=2022q4 2022q4) rgdp_forecast_10_enet 

'' Averaging Forecast
''' Mean
'''' Mean Forecast of 2022Q4
smpl @all
freeze(forcastavg_mean) rgdp.forcavg(wgt=mean, forcsmpl="2022q4 2022q4", name=rgdp_forecastavg_01_mean) rgdp_forecast_*

'''' Mean Fit of 2018Q1-2022Q3
freeze(fitavg_mean) rgdp.forcavg(wgt=mean, forcsmpl="2018q1 2022q3", name=rgdp_fitavg_01_mean) rgdp_fit_*

smpl 2018 2023
graph line_rgdp_forecast_fit.line rgdp_forecastavg_01_mean rgdp rgdp_fitavg_01_mean

'''' Forecast Evaluation
freeze(forceval_fit_mean) rgdp.forceval(evalsmpl="2018q1 2022q3") rgdp_fitavg_01_mean rgdp_fit_*

''' Excluding Worst and Best Models
'''' Trimmed Mean Forecast
smpl @all 
series rgdp_forecastavg_02_exwb = (rgdp_forecast_01_bridge + rgdp_forecast_03_umidas + rgdp_forecast_04_midaspc + rgdp_forecast_05_umidaspc + rgdp_forecast_06_threeprf + rgdp_forecast_08_ridge + rgdp_forecast_09_lasso + rgdp_forecast_10_enet) / 8

'''' Trimmed Mean Fit
smpl 2018q1 2022q3
series rgdp_fitavg_02_exwb = (rgdp_fit_01_bridge + rgdp_fit_03_umidas + rgdp_fit_04_midaspc + rgdp_fit_05_umidaspc + rgdp_fit_06_threeprf + rgdp_fit_08_ridge + rgdp_fit_09_lasso + rgdp_fit_10_enet) / 8

'''' Forecast Evaluation
freeze(forceval_fit_exwb) rgdp.forceval(evalsmpl="2018q1 2022q3") rgdp_fitavg_* rgdp_fit_*

'' DFM


'' 2022Q4 Forecast Comparison
smpl 2022q4 2022q4
freeze(forecast_compare_table) @pcy(rgdp_forecast_01_bridge) @pcy(rgdp_forecast_02_midas) @pcy(rgdp_forecast_03_umidas) @pcy(rgdp_forecast_04_midaspc) @pcy(rgdp_forecast_05_umidaspc) @pcy(rgdp_forecast_06_threeprf) @pcy(rgdp_forecast_07_mfvar) @pcy(rgdp_forecast_08_ridge) @pcy(rgdp_forecast_09_lasso) @pcy(rgdp_forecast_10_enet)


