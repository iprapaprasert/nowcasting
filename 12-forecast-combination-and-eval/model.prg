subroutine bridge(string %y, string %xs, string %estsmpl, string %forcdate, scalar !i)
	pageselect Quarterly
	' Sequence 1->0, 2->0, 3->0, 4->1, 5->1, 6->1 ... 
	smpl {%estsmpl} + @floor((!i-1) / 3)
	%xexp = ""
	for %x {%xs}
		%xexp = %xexp + "dlog(" + %x + "_" + @str(!i) + ")"	
	next
	!lastestdate = @dateadd(@dateval(%forcdate), -1, "Q") 
	if !lastestdate >= @dateval("2020q2") then
		%xexp = %xexp + "crisis"
	endif
	equation bridge_!i.ls dlog({%y}_!i) dlog({%y}_!i(-1)) dlog({%y}_!i(-2)) dlog({%y}_!i(-3)) {%xexp} c
	bridge_!i.forecast(g, ga, e, forcsmpl={%forcdate} {%forcdate}) {%y}_fo_bridge_!i
endsub


