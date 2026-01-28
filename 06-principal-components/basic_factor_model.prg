%path = @runpath
cd %path
wfopen nwc

' 2. Nowcasting with Principal Component
pageselect Monthly
group f_data.add im pmi_manu_new retail_sales

'' Make principal components
smpl @all
freeze(f_data_pcomp) f_data.pcomp
f_data.makepcomp pc_1 pc_2

'' MIDAS using principal components
''' Generate crisis dummy
pageselect Quarterly
smpl @all
series crisis = @date=@dateval("2020q2") or @date=@dateval("2021q3")

''' Using only pc_1 as it contributes more than 60% variation
smpl 2011q3 2022q3
equation midas.midas(lag=auto, maxlag=12) dlog(rgdp) dlog(rgdp(-1)) dlog(rgdp(-2)) dlog(rgdp(-3)) crisis c @ Monthly\d(pc_1)

''' Forecast 2022q4
freeze(midas_forecast) midas.forecast(g, ga, e, forcsmpl=2022q4 2022q4) rgdp_forecast_midas

''' In-sample fit 2018q1-2022q3
freeze(midas_fit) midas.fit(g, ga, e, forcsmpl=2018q1 2022q3) rgdp_fit_midas

'' UMIDAS using principal components
equation umidas.midas(midwgt=umidas, lag=fixed, fixedlag=3) dlog(rgdp) dlog(rgdp(-1)) dlog(rgdp(-2)) dlog(rgdp(-3)) crisis c @ Monthly\d(pc_1)

''' Forecast 2022q4
freeze(umidas_forecast) umidas.forecast(g, ga, e, forcsmpl=2022q4 2022q4) rgdp_forecast_umidas

''' In-sample fit 2018q1-2022q3
freeze(umidas_fit) umidas.fit(g, ga, e, forcsmpl=2018q1 2022q3) rgdp_fit_umidas

' 3. Nowcasting with Three-pass Regression Filter (3PRF)
'' Convert monthly to quarterly data
copy(o, c=sn) Monthly\retail_sales *
copy(o, c=an) Monthly\pmi_manu_new *
copy(o, c=sn) Monthly\im *

'' Create predictive factor f_hat
include threeprf
call threeprf("im pmi_manu_new retail_sales", rgdp, "2011q3 2022q4")

'' OLS using predictive factor f_hat
equation ls.ls dlog(rgdp) dlog(rgdp(-1)) dlog(rgdp(-2)) dlog(rgdp(-3)) d(f_hat) crisis c

'' Forecast 2022q4
freeze(ls_forecast) ls.forecast(g, ga, e, forcsmpl=2022q4 2022q4) rgdp_forecast_ls

'' In-sample fit 2018q1-2022q3
freeze(ls_fit) ls.fit(g, ga, e, forcsmpl=2018q1 2022q3) rgdp_fit_ls

'' Compare 3PRF factors and PC
smpl 2018 2022
graph fit.line rgdp rgdp_fit_midas rgdp_fit_umidas rgdp_fit_ls
 

