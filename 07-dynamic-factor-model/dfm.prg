subroutine dfm_vars(string %vars, string %smpl, string %pcys, string %d04s, string %strname)
	'''
	' Create variables for dynamic factor model
	'
	' Parameters
	' ----------
	' vars : variables 
	' smpl : sample 
	' pcys : list of variables transformed by @pcy
	' d04s : list of variables transformed by d(0,4)
	' strname : name of string object keeping list of variables using in dfm model
	'''
	smpl {%smpl}
	%dfm_vars = ""
	for %dfm_var {%vars}
		if @wfind(%pcys, %dfm_var) <> 0 then
			series pcy_{%dfm_var} = @pcy({%dfm_var})
			series dm_pcy_{%dfm_var} = @demean(pcy_{%dfm_var}, %smpl)
			%dfm_vars = %dfm_vars + " " + "dm_pcy_" + %dfm_var
		else 
			if @wfind(%d04s, %dfm_var) <> 0 then
				series d04_{%dfm_var} = d({%dfm_var}, 0, 4)
				series dm_d04_{%dfm_var} = @demean(d04_{%dfm_var}, %smpl)
				%dfm_vars = %dfm_vars + " " + "dm_d04_" + %dfm_var
			else
				series dm_{%dfm_var} = @demean({%dfm_var}, %smpl)
				%dfm_vars = %dfm_vars + " " + "dm_" + %dfm_var	
			endif
		endif
	next
	string {%strname} = %dfm_vars
endsub


subroutine dfm(string %y, string %bdmy, string %sample, string %xs, string %forc, string %fpref)
	'''
	' Forecast a dynamic factor model
	' Must using demeaned YoY (@pcy, dlog(0,4) data 
	' Recommended using dfm_vars function to create the input series 
	' Note that dfm generates pcy series using format `pcy_{%fpref}_dfm`
	'
	' Parameters
	' ----------
	' y : dependent variable, must be stationary and demean.
	' bdmy : before demeaned dependent variable
	' sample : before demeaned dependent variable sample
	' xs : independent variable, must be stationary and demean
	' forc : one-period forecast sample for out-of-sample dynamic forecast.
	' fpref : forecast series prefix
	'''
	
	%dfm_vars = %y + " " + %xs	
	sspace dfm
	!i = 1
	c = 0
	for %dfm_var {%dfm_vars}
		
		!j = !i+1
		!k = !i+2

		dfm.append @signal {%dfm_var} = c(!i)*s1 + e_{%dfm_var}
		dfm.append @state e_{%dfm_var} = c(!j)*e_{%dfm_var}(-1) + [var=c(!k)^2]

		' set the initial values	
		c(!i) = @stdevp({%dfm_var}) / @stdevp({%y})
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
	series pcy_{%fpref}_dfm = c(1)*sm_s1 + sm_e_{%y} + @mean({%bdmy}, %sample)
	
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
	
	series {%fpref}_dfm = @recode(@during(%recode_forc), @exp(pcy_{%fpref}_dfm + log({%fpref}(-4))), {%fpref})
endsub


