subroutine threeprf(string %predictors, series target, string %smpl)
	'''Use Three-pass Regression Filter to get second-pass estimated preditive factor f_hat instead of using several predictors'''
	series f = na
	!i = 1
	' Step 1: Run a regression of each high-freq series on a target variable
	for %y {%predictors}
		smpl {%smpl}-1		
		equation {%y}_3prf1.ls {%y} c target
		'' Save each coef as the f series
		f(!i) = {%y}_3prf1.@coefs(2)
		!i = !i + 1
	next 
	' Step 2: Run high-freq series at each time t on the coef before target variable
	smpl {%smpl}
	series f_hat = na
	for !t = 1 to @obssmpl
		'' Create series t where each obs is the value of predictors at time t
		series t_!t = na
		!i = 1
		for %y {%predictors}
			t_!t(!i) = @elem({%y}, @otods(!t))
			!i = !i + 1
		next
		'' Run regression for finding a coef of f
		smpl @all
		equation t_3prf2_!t.ls t_!t c f
		'' Save the coef of f in series f_hat
		smpl {%smpl}
		f_hat(@dtoo(@otods(!t))) = t_3prf2_!t.@coefs(2)
	next
	' Step 3: Forecasting y at t+1 by using f_hat
	'' Not implemented in this subroutine, this subroutine only returns f_hat			
endsub

