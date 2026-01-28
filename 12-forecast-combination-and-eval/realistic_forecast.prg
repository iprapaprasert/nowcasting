%path = @runpath
cd %path
wfopen nwc

include model
include placeholder
include forcresult

' Suppose that we are at 2018m01, RGDP is at 2017q4, while monthly variables are at 2018m01
%estsmpl = "@first 2017q4" ' Last date should be Q4 so we can assess the Q1 onwards
%y = "rgdp"
%xs = "retail_sales im pmi_manu_new"
%lastevaldate = "2022q3"

pageselect Quarterly
smpl @all
series crisis = @date=@dateval("2020q2") or @date=@dateval("2021q3")

' Find number of evaluation period
!firstplacedate = @dateadd(@dateval(@word(%estsmpl, 2)), 3, "M")
!lastevaldateval = @dateval(%lastevaldate)

' Since lastevaldate is evaluated at the start of quarter, we + 3 to cover the entire quarter
!numeval = @datediff({!lastevaldateval}, {!firstplacedate} , "MM") + 3 

' Always start to evaluate at month 1
for !i = 1 to !numeval
	' Placeholder period : Suppose we start to evaluate at month 1 (Jan), 
	' and the last date of estimation sample starts at the first month of quarter such as Oct for Q4, 
	' so the first placeholder should be evaluated in the next 2+!i = 2+1 = 3 month (Jan)
	%placedate = @datestr(@dateadd(@dateval(@word(%estsmpl, 2)), 2+!i, "M"))
	
	' Forecast period : If we are at month 1 (!i=1), we forecast Q1 (1->1). 
	' So the sequence is 1->1, 2->1, 3->1, 4->2, 5->2, 6->2, ...
	%forcdate = @datestr(@dateadd(@dateval(@word(%estsmpl, 2)), @floor((!i-1) / 3) + 1, "Q"))
	
	' 1. Create a RGDP series that reflects the actual data available in 2018M1 (end) (Latest RGDP is in 2017q4)
	pageselect Quarterly
	' Follow the sequence : 1->0, 2->0, 3->0 (latest GDP is still at Q4) /
	' 4->1, 5->1, 6->1 (update the latest GDP to Q1 next year), ...
	smpl {%estsmpl} + @floor((!i-1) / 3)
	series {%y}_!i = {%y}

	' 2. Nowcast the high-frequency dependent variables to the entire quarter
	for %x {%xs}
		pageselect Monthly
		' Copy the monthly variables until month !i
		smpl {%estsmpl} + !i
		series {%x}_!i = {%x}
		' Forecast the remaining month until the end quarter
		!mrestofq = 2 - @mod(!i-1, 3)
		{%x}.autoarma(forclen=!mrestofq) {%x}_{!i}

		pageselect Quarterly
		' Follow the sequence : 1->0, 2->0, 3->0 (use monthly data to forecast until Q4) /
		' 4->1, 5->1, 6->1 (use monthly data to forecast until Q1 next year), ...
		smpl {%estsmpl} + @floor((!i-1) / 3)
		if (%x <> "pmi_manu_new") then
			copy(c=sn) Monthly\{%x}_{!i} {%x}_{!i}
		else
			copy(c=an) Monthly\{%x}_{!i} {%x}_{!i}
		endif
	next

	' 3. Calculate Nowcast Model
	call bridge(%y, %xs, %estsmpl, %forcdate, !i)
	
	' 4. Placeholder of Monthly Forecast
	call placeholder("bridge", %placedate, %forcdate)
	
	' 5. Forcasting results conducted on each (first/second/third) month of quarter
	call forcresult("bridge", %forcdate, !i)
next

' 6. Evaluation Graph
pageselect Monthly
copy(c=pointl) Quarterly\{%y} *
group placeholder placeholder_*
%graphstart = @datestr(@dateval(@word(%estsmpl,2)))
smpl {%graphstart} {%placedate}
graph realistic_eval_line.line {%y} placeholder

' 7. Forecast Evaluation
pageselect Quarterly
%firstforecast = @datestr(@dateadd(@dateval(@word(%estsmpl, 2)), 1, "Q"))
'' Forecast conducted on the first month of each quarter
for !i = 1 to 3
	freeze(forceval_!i){%y}.forceval(evalsmpl={%firstforecast} {%forcdate}) forcresult_*_!i
next

