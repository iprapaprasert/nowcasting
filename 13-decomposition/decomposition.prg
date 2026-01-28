%path = @runpath 
cd %path
wfopen nwc.wf1

' 1. Bridge Estimation
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

''' crisis
smpl @all
series crisis = @date=@dateval("2020q2") or @date=@dateval("2021q3") 

'' Estimate the bridge equation
smpl 2011q3 2022q3
equation bridge.ls dlog(rgdp) dlog(rgdp(-1)) dlog(rgdp(-2)) dlog(rgdp(-3)) dlog(retail_sales) dlog(pmi_manu_new) dlog(im) crisis c

'' Forecast 2022Q4
freeze(bridge_forecast) bridge.forecast(g, ga, e, forcsmpl=2022q4 2022q4) rgdp_forecast_bridge

'' In-sample fit during 2018Q1-2022Q3
freeze(bridge_fit) bridge.fit(g, ga, e, forcsmpl=2018q1 2022q3) rgdp_fit_bridge

' 2. Contribution
include contribution
call contribution("2020q4 2022q4", bridge)
rename contr_graph contr_graph_original

' 3. More Aggregated Contribution
include contribution_graph
group contrs_agg contr_x2+contr_x3+contr_x4 contr_x5 contr_x6 contr_x7 contr_x8+contr_x9 contr_y
call contribution_graph(contrs_agg, "2020q4 2022q4")

