%path = @runpath
cd %path
wfopen nwc

' 1. Nowcasting with Dynamic Factor Models
'' Convert monthly to quarterly data
copy(o, c=sn) Monthly\retail_sales *
copy(o, c=an) Monthly\pmi_manu_new *
copy(o, c=sn) Monthly\im *

'' Data preprocessing (annual growth + demeaned)
pageselect Quarterly
smpl 2011q3 2022q4
group data rgdp pmi_manu_new im retail_sales
series dl_rgdp = @dlog(rgdp, 0, 4) * 100
series g_dl_rgdp = @demean(dl_rgdp, "2011q3 2022q4")

series dl_pmi_manu_new = @dlog(pmi_manu_new, 0, 4) * 100
series g_dl_pmi_manu_new = @demean(dl_pmi_manu_new, "2011q3 2022q4")

series dl_im = @dlog(im, 0, 4) * 100
series g_dl_im = @demean(dl_im, "2011q3 2022q4")

series dl_retail_sales = @dlog(retail_sales, 0, 4) * 100
series g_dl_retail_sales = @demean(dl_retail_sales, "2011q3 2022q4")
group g_dl g_dl_rgdp g_dl_pmi_manu_new g_dl_im g_dl_retail_sales

'' Create Sspace model
sspace ss_dfm
ss_dfm.append @signal g_dl_rgdp = c(1)*s1 + e_dl_rgdp
ss_dfm.append @state e_dl_rgdp = c(2)*e_dl_rgdp(-1) + [var=c(3)^2]

ss_dfm.append @signal g_dl_pmi_manu_new = c(4)*s1 + e_dl_pmi_manu_new
ss_dfm.append @state e_dl_pmi_manu_new = c(5)*e_dl_pmi_manu_new(-1) + [var=c(6)^2]

ss_dfm.append @signal g_dl_im = c(7)*s1 + e_dl_im
ss_dfm.append @state e_dl_im = c(8)*e_dl_im(-1) + [var=c(9)^2]

ss_dfm.append @signal g_dl_retail_sales = c(10)*s1 + e_dl_retail_sales
ss_dfm.append @state e_dl_retail_sales = c(11)*e_dl_retail_sales(-1) + [var=c(12)^2]

ss_dfm.append @state s1 = c(13)*s1(-1) + [var=0.5]
freeze(ss_dfm_spec) ss_dfm.spec

'' Set the initial values
smpl 2011q3 2022q4
c = 0

c(1) = @stdevp(dl_rgdp) / @stdevp(dl_rgdp)
c(2) = 0.5
c(3) = @stdevp(dl_rgdp)

c(4) = @stdevp(dl_pmi_manu_new) / @stdevp(dl_rgdp)
c(5) = 0.5
c(6) = @stdevp(dl_pmi_manu_new)

c(7) = @stdevp(dl_im) / @stdevp(dl_rgdp)
c(8) = 0.5
c(9) = @stdevp(dl_im)

c(10) = @stdevp(dl_retail_sales) / @stdevp(dl_rgdp)
c(11) = 0.5
c(12) = @stdevp(dl_retail_sales)

c(13) = 0.5

'' Estimation
ss_dfm.ml(showopts, m=1000, c=1e-5)
freeze(ss_output) ss_dfm.output

'' Extract state variables
ss_dfm.makestates(t=smooth, n=smooth_states) sm_*

'' Graph state variable
graph dfm_states_line.line(n) smooth_states

'' Generate nowcast 
''' YoY growth rate nowcast from DFM
series dl_rgdp_sspace = c(1)*sm_s1 + sm_e_dl_rgdp + @mean(dl_rgdp, "2011q3 2022q4")
graph dl_rgdp_forecast.line dl_rgdp_sspace dl_rgdp

''' Convert yoy to level
smpl @all
series rgdp_sspace = @recode(@during("2022q3 2022q4"), @exp(dl_rgdp_sspace / 100 + log(rgdp(-4))), rgdp)
smpl 2018 2022
graph rgdp_forecast.line rgdp_sspace rgdp


