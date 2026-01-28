include contribution_graph
	
subroutine contribution(string %contrsmpl, equation eqn)
	smpl {%contrsmpl}
	series contr_y = 0
	%displayname_y = @word(eqn.@varlist, 1)
	contr_y.displayname {%displayname_y}
	for !i = 2 to @wcount(eqn.@varlist)
		%x = @word(eqn.@varlist, !i)
		if !i <> @wcount(eqn.@varlist) then
			series contr_x!i = eqn.@coefs(!i - 1) * {%x} * 100
		else 'constant
			series contr_x!i = eqn.@coefs(!i - 1) * 1 * 100
		endif
		contr_x!i.displayname {%x}
		contr_y = contr_y + contr_x!i
	next
	group contrs contr_x* contr_y
	call contribution_graph(contrs, %contrsmpl)
endsub


