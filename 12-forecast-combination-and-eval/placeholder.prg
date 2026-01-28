subroutine placeholder(string %eqn, string %placedate, string %forcdate)
	pageselect Quarterly
	%foseriesname = %y + "_fo_" + %eqn + "_" + @str(!i)
	!fo = @elem({%foseriesname}, %forcdate)
	pageselect Monthly
	%seriesname = "placeholder_" + %eqn	
	if @isobject(%seriesname) = 0 then
		series {%seriesname} = na
	endif
	{%seriesname}(@dtoo(%placedate)) = !fo
endsub


