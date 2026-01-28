%path = @runpath 
cd %path
wfopen nwc.wf1

' 1. Data Preparation
'' RGDP (RGDP is seasonally adjusted)
pageselect Quarterly
smpl 2008 2022

rgdp.hpf rgdp_hp
graph graph01_rgdp.line rgdp_hp rgdp 
series rgdp_growth = dlog(rgdp, 0, 4)
rgdp_growth.hpf rgdp_growth_hp
graph graph02_rgdp.line rgdp_growth_hp rgdp_growth

'' independent variables
copy(c=sn) Monthly\retail_sales *
copy(c=sn) Monthly\im *
copy(c=sn) Monthly\ex *
copy(c=an) Monthly\pmi_manu_new *

smpl 2013q2 2022
graph line_dlog_rgdp_retail.line dlog(rgdp) dlog(retail_sales) 
line_dlog_rgdp_retail.axis(l) norm

graph line_dlog_rgdp_im.line dlog(rgdp) dlog(im) 
line_dlog_rgdp_im.axis(l) norm

graph line_dlog_rgdp_ex.line dlog(rgdp) dlog(ex) 
line_dlog_rgdp_ex.axis(l) norm

graph line_dlog_rgdp_pmi.line dlog(rgdp) dlog(pmi_manu_new) 
line_dlog_rgdp_pmi.axis(l) norm

''' crisis
smpl @all
series crisis = @date=@dateval("2020q2") or @date=@dateval("2021q3") 

'' baseline forecasting model
equation baseline_ex.ls dlog(rgdp) dlog(rgdp(-1)) dlog(rgdp(-2)) dlog(rgdp(-3)) dlog(retail_sales) dlog(pmi_manu_new) dlog(ex) crisis c
freeze(baseline_ex_fit) baseline_ex.fit(g, ga, e, forcsmpl=2018 2022q3) rgdp_baseline_ex 

equation baseline_im.ls dlog(rgdp) dlog(rgdp(-1)) dlog(rgdp(-2)) dlog(rgdp(-3)) dlog(retail_sales) dlog(pmi_manu_new) dlog(im) crisis c
freeze(baseline_im_fit) baseline_im.fit(g, ga, e, forcsmpl=2018 2022q3) rgdp_baseline_im

' 2. Nowcasting Preparation
'' We already convert monthly data to quarterly data
smpl 2013 2022
graph line_dlog_gdp_crisis.line(d) dlog(rgdp) crisis 

'' Use the baseline equation to develop as a base forecasting model
smpl 2011q3 2022q2
equation base_forecast_model.ls dlog(rgdp) dlog(rgdp(-1)) dlog(rgdp(-2)) dlog(rgdp(-3)) dlog(retail_sales) dlog(pmi_manu_new) dlog(im) crisis c

'' Forecast 2022Q3
freeze(base_forecast) base_forecast_model.forecast(g, ga, e, forcsmpl=2022q3 2022q3) rgdp_f_2022q3 

smpl 2022 2022
graph line_a_f_2022q3.line @pcy(rgdp) @pcy(rgdp_f_2022q3)

' 3. Bridge Estimation
'' Forecast independent variables during 2022M10-2022M12
pageselect monthly
smpl 2000 2022m09
retail_sales.autoarma(eqname=retail_autoarma_eq, fgraph, atable, agraph, forclen=3) retail_sales_f c
im.autoarma(eqname=im_autoarma_eq, fgraph, atable, agraph, forclen=3) im_f c
pmi_manu_new.autoarma(eqname=pmi_autoarma_eq, fgraph, atable, agraph, forclen=3) pmi_manu_new_f c

'' copy forecasted series as series
smpl @all
copy(o, c=sn) retail_sales_f retail_sales
copy(o, c=sn) im_f im
copy(o, c=an) pmi_manu_new_f pmi_manu_new

'' Convert the monthly forecasted series to the quarterly
pageselect quarterly
smpl @all
copy(o, c=sn) Monthly\retail_sales retail_sales
copy(o, c=sn) Monthly\im im
copy(o, c=an) Monthly\pmi_manu_new pmi_manu_new

'' Estimate the bridge equation
smpl 2011q3 2022q3
equation bridge.ls dlog(rgdp) dlog(rgdp(-1)) dlog(rgdp(-2)) dlog(rgdp(-3)) dlog(retail_sales) dlog(pmi_manu_new) dlog(im) crisis c

'' Forecast 2022Q4
freeze(bridge_forecast) bridge.forecast(g, ga, e, forcsmpl=2022q4 2022q4) rgdp_forecast_bridge

'' In-sample fit during 2018Q1-2022Q3
freeze(bridge_fit) bridge.fit(g, ga, e, forcsmpl=2018q1 2022q3) rgdp_fit_bridge

' 4. Nowcasting using the MIDAS Approach
smpl 2011q3 2022q3
equation midas.midas(lag=auto, maxlag=12) dlog(rgdp) dlog(rgdp(-1)) dlog(rgdp(-2)) dlog(rgdp(-3)) crisis c @ monthly\dlog(retail_sales) monthly\dlog(pmi_manu_new) monthly\dlog(im)

'' Forecast 2022Q4
freeze(midas_forecast) midas.forecast(g, ga, e, forcsmpl=2022q4 2022q4) rgdp_forecast_midas

'' In-sample fit during 2018Q1-2022Q3
freeze(midas_fit) midas.fit(g, ga, e, forcsmpl=2018q1 2022q3) rgdp_fit_midas

' 5. Nowcasting using the U-MIDAS Approach
smpl 2011q3 2022q3
equation umidas.midas(midwgt=umidas, lag=fixed, fixedlag=3) dlog(rgdp) dlog(rgdp(-1)) dlog(rgdp(-2)) dlog(rgdp(-3)) crisis c @ monthly\dlog(retail_sales) monthly\dlog(pmi_manu_new) monthly\dlog(im)

'' Forecast 2022Q4
freeze(umidas_forecast) umidas.forecast(g, ga, e, forcsmpl=2022q4 2022q4) rgdp_forecast_umidas

'' In-sample fit during 2018Q1-2022Q3
freeze(umidas_fit) umidas.fit(g, ga, e, forcsmpl=2018q1 2022q3) rgdp_fit_umidas

' 6. Recap: Nowcasting using Bridge, MIDAS and U-MIDAS
smpl 2019 2022
graph line_rgdp_fit.line rgdp rgdp_fit_bridge rgdp_fit_midas rgdp_fit_umidas
graph line_pcy_rgdp_forecast.line @pcy(rgdp) @pcy(rgdp_forecast_bridge) @pcy(rgdp_forecast_midas) @pcy(rgdp_forecast_umidas)

'' Forecast evaluation
smpl @all
freeze(forceval) rgdp.forceval(mean, evalsmpl=2018q1 2022q3) rgdp_fit_*


