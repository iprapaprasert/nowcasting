subroutine forcresult(string %eqn, string %forcdate, scalar !i)
	' Calculate the location of month !i is the quarter
	' Sequence 1->1, 2->2, 3->3, 4->1, 5->2, 6->3
	!loc = @mod(!i-1, 3) + 1
	pageselect Quarterly
	%foseriesname = %y + "_fo_" + %eqn + "_" + @str(!i)
	!fo = @elem({%foseriesname}, %forcdate)
	%seriesname = "forcresult_" + %eqn + "_" + @str(!loc)	
	if @isobject(%seriesname) = 0 then
		series {%seriesname} = na
	endif
	{%seriesname}(@dtoo(%forcdate)) = !fo
endsub


