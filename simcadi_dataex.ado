

program simcadi_dataex
	qui{
	clear
	set obs 9
	gen lfd=_n
	gen name = ""
	replace name="Adam" if lfd<4
	replace name="Brittany" if (lfd<7 & name=="")
	replace name="Charlie" if ( name=="")
	gen time=1
	bysort name: gen lfdn=_n
	gen good="bread"
	*replace good="cheese" if lfdn==2
	replace good="water" if lfdn==2
	replace good="beer" if lfdn==3

	gen consume=.
	replace consume=10
	replace consume=consume+5 if name=="Adam"
	replace consume=consume+3 if name=="Brittany"
	replace consume=consume if name=="Charlie"

	replace consume=consume+3 if (name=="Adam" & good=="bread")
	replace consume=consume+3 if (name=="Adam" & good=="beer")
	replace consume=consume+3 if (name=="Adam" & good=="water")
	replace consume=consume+2 if (name=="Brittany" & good=="bread")
	replace consume=consume-4 if (name=="Brittany" & good=="beer")
	replace consume=consume if (name=="Charlie" & good=="bread")
	replace consume=consume-10 if (name=="Charlie" & good=="beer")


	tempfile test1
	save `test1', replace
	replace time=2
	replace consume=consume-1 if (name=="Adam" & good=="water")
	replace consume=consume+1 if (name=="Adam" & good=="beer")
	replace consume=consume-4 if (name=="Brittany" & good=="bread")
	replace consume=consume+3 if (name=="Brittany" & good=="water")
	replace consume=consume-2 if (name=="Brittany" & good=="beer")
	replace consume=consume+2 if (name=="Charlie" & good=="bread")
	replace consume=consume+2 if (name=="Charlie" & good=="water")
	replace consume=consume+1 if (name=="Charlie" & good=="beer")
	append using `test1'
	drop lfd*
	save example_consume, replace
	}
end
