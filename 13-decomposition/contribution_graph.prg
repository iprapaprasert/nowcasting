subroutine contribution_graph(group contrs, string %contrsmpl)
	' Draw a contribution graph
	' %contrs: group of contribution series, last member must be contr_y
	smpl {%contrsmpl}
	!contr_y_idx = contrs.@count
	%contr_xs = ""
	for !i = 1 to !contr_y_idx - 1
		if %contr_xs = "" then
			%contr_xs = @str(!i)
		else
			%contr_xs = %contr_xs + ", " + @str(!i)
		endif
	next
	freeze(contr_graph) contrs.mixed(llast) stackedbar({%contr_xs}) line(!contr_y_idx)
endsub
