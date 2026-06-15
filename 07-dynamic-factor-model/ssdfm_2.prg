%path = @runpath
cd %path

include dfm
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
series dl_rgdp = @dlog(rgdp, 0, 4)
series g_dl_rgdp = @demean(dl_rgdp, "2011q3 2022q4")

series dl_pmi_manu_new = @dlog(pmi_manu_new, 0, 4)
series g_dl_pmi_manu_new = @demean(dl_pmi_manu_new, "2011q3 2022q4")

series dl_im = @dlog(im, 0, 4)
series g_dl_im = @demean(dl_im, "2011q3 2022q4")

series dl_retail_sales = @dlog(retail_sales, 0, 4)
series g_dl_retail_sales = @demean(dl_retail_sales, "2011q3 2022q4")
group g_dl g_dl_rgdp g_dl_pmi_manu_new g_dl_im g_dl_retail_sales

'' Create Sspace model
smpl 2011q3 2022q4
call dfm("g_dl_rgdp g_dl_pmi_manu_new g_dl_im g_dl_retail_sales", "dl_rgdp", "2022q4", "rgdp", 1)

'' Graph state variable
smpl 2011q3 2022q4
graph dfm_states_line.line(n) smooth_states

'' Graph nowcast vs real 
graph dl_rgdp_forecast.line dl_rgdp_dfm dl_rgdp

''' Convert yoy to level
smpl 2018 2022
graph rgdp_forecast.line rgdp_forc_dfm rgdp


