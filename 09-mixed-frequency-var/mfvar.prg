%path = @runpath
cd %path
wfopen nwc

' 2. Estimating Mixed-frequency VARs
'' crisis
pageselect Quarterly
smpl @all
series crisis = @date=@dateval("2020q2") or @date=@dateval("2021q3") 

'' Estimation
smpl 2011q3 2022q3
var mfvar.mfvar 1 1 dlog(rgdp) @ crisis @hf monthly\dlog(retail_sales) monthly\dlog(pmi_manu_new) monthly\dlog(im)

' 3. Nowcasting using Mixed-frequency VARs
'' Dynamic forecast
smpl 2022q4 2022q4
freeze(dlog_rgdp_mfvar_fo) mfvar.forecast(g, e) fo_mfvar
smpl @all
series rgdp_fo_mfvar = exp(dlog_rgdp__fo_mfvar + log(rgdp(-1)))

'' In-sample fit
smpl 2018 2022q3
freeze(dlog_rgdp_mfvar_fit) mfvar.fit(g, e) fit_mfvar
smpl @all
series rgdp_fit_mfvar = exp(dlog_rgdp__fit_mfvar + log(rgdp(-1)))
smpl 2018 2022
graph line_rgdp_fit.line rgdp rgdp_fit_mfvar

' 4. Replicating MFVAR using standard VAR approach and OLS
'' Convert monthly to quarterly by split
for %v retail_sales im pmi_manu_new
	pageselect Monthly
	series dlog_{%v} = dlog({%v})
	pageselect Quarterly
	copy(c=split) Monthly\dlog_{%v} *
next

'' Replicate MFVAR using OLS (VAR Single Equation)
smpl 2011Q3 2022Q3
equation ls.ls dlog(rgdp) dlog_retail_sales_1(-1) dlog_retail_sales_2(-1) dlog_retail_sales_3(-1) dlog_im_1(-1) dlog_im_2(-1) dlog_im_3(-1) dlog_pmi_manu_new_1(-1) dlog_pmi_manu_new_2(-1) dlog_pmi_manu_new_3(-1) dlog(rgdp(-1)) crisis c

'' Replicate MFVAR using VAR
var var.ls 1 1 dlog_retail_sales_1 dlog_retail_sales_2 dlog_retail_sales_3 dlog_pmi_manu_new_1 dlog_pmi_manu_new_2 dlog_pmi_manu_new_3 dlog_im_1 dlog_im_2 dlog_im_3 dlog(rgdp) @ crisis c
