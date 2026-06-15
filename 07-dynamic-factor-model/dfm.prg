subroutine dfm_specs(string %y, string %qxs, string %mxs, string %pcys, string %d04s, string %specsname)
	'''
	' Create specification for dynamic factor model
	'
	' Parameters
	' ----------
	' y : original dependent variable
	' qxs : original quarterly independent variables
	' mxs : original monthly independent variables 
	' pcys : list of variables transformed by @pcy
	' d04s : list of variables transformed by d(0,4)
	' specsname : name of string object keeping list of variables using in dfm model
	'
	' Return
	' ------
	' string object containing model specification
	'''
	%ovars = %y + " " + %qxs + " " + %mxs
	%specs = ""
	for %ovar {%ovars}
		if @wfind(%pcys, %ovar) <> 0 then
			series pcy_{%ovar} = @pcy({%ovar})
			series dm_pcy_{%ovar} = @demean(pcy_{%ovar})
			%specs = %specs + " " + "dm_pcy_" + %ovar
		else 
			if @wfind(%d04s, %ovar) <> 0 then
				series d04_{%ovar} = d({%ovar}, 0, 4)
				series dm_d04_{%ovar} = @demean(d04_{%ovar})
				%specs = %specs + " " + "dm_d04_" + %ovar
			else
				series dm_{%ovar} = @demean({%ovar})
				%specs = %specs + " " + "dm_" + %ovar	
			endif
		endif
	next
	string {%specsname} = %specs
endsub

subroutine dfm(string %specs, string %bdmy, string %forc, string %fpref, scalar !isdlog)
	'''
	' Forecast a dynamic factor model
	' Must using demeaned YoY (@pcy, dlog(0,4) data 
	' Recommended using dfm_specs function to create the specification 
	' Note that dfm generates pcy series using format:
	' 	- `dl_{%fpref}_dfm` if !isdlog=1 and
	' 	- `pcy_{%fpref}_dfm` if !isdlog=0
	'
	' Parameters
	' ----------
	' specs : model specification with depvar as the first variable followed by indepvars, 
	'         must be stationary and demean.
	' bdmy : before demeaned dependent variable
	' forc : one-period forecast sample for out-of-sample dynamic forecast.
	' fpref : forecast series prefix
	' isdlog : 1 if YoY by dlog(0,4) / 0 if YoY by @pcy
	'''
	
	%depvar = @word(%specs, 1)
	sspace dfm
	!i = 1
	c = 0
	for %dfm_var {%specs}
		
		!j = !i+1
		!k = !i+2

		dfm.append @signal {%dfm_var} = c(!i)*s1 + e_{%dfm_var}
		dfm.append @state e_{%dfm_var} = c(!j)*e_{%dfm_var}(-1) + [var=c(!k)^2]

		' set the initial values	
		c(!i) = @stdevp({%dfm_var}) / @stdevp({%depvar})
		c(!j) = 0.5
		c(!k) = @stdevp({%dfm_var})
	
		!i = !i+3
	next
	dfm.append @state s1 = c(!i)*s1(-1) + [var=0.5]
	c(!i) = 0.5
	freeze(dfm_spec) dfm.spec

	'' Estimation
	dfm.ml(showopts, m=1000, c=1e-5)
	freeze(dfm_output) dfm.output

	'' Extract state variables
	dfm.makestates(t=smooth, n=smooth_states) sm_*

	'' Generate nowcast 
	''' YoY growth rate nowcast from DFM
	if !isdlog = 1 then
		series dl_{%fpref}_dfm = c(1)*sm_s1 + sm_e_{%depvar} + @mean({%bdmy})
	else
		series pcy_{%fpref}_dfm = c(1)*sm_s1 + sm_e_{%depvar} + @mean({%bdmy})
	endif
	
	''' Convert yoy to level
	smpl @all
	
	''' Generate recode_forc
	'''' Extract year and quarter
	!yr = @val(@left(%forc, 4))
	!qtr = @val(@right(%forc, 1))

	'''' Calculate previous quarter
	if !qtr = 1 then
    		!prev_yr = !yr - 1
    		!prev_qtr = 4
	else
    		!prev_yr = !yr
    		!prev_qtr = !qtr - 1
	endif

	'''' Build the recode_forc
	%prev_forc = @str(!prev_yr) + "q" + @str(!prev_qtr)
	%recode_forc = %prev_forc + " " + %forc
	
	if !isdlog = 1 then
		series {%fpref}_forc_dfm = @recode(@during(%recode_forc), @exp(dl_{%fpref}_dfm + log({%fpref}(-4))), {%fpref})
	else
		series {%fpref}_forc_dfm = @recode(@during(%recode_forc), {%fpref}(-4)*(1 + pcy_{%fpref}_dfm/100), {%fpref})
	endif
endsub


