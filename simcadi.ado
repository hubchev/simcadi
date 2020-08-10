*Copyright and Author: Stephan Huber (stephan.huber@wiwi.uni-regensburg.de)


cap program drop simcadi
program define simcadi
	version 11
	syntax  varlist(min=1 max=2 numeric) [using] [if] [in] ,  class(varname) ///
	[ id(varname string) wcountry(string) wvarname(name) varpartner(string) ///
	finger braycurtis cosine jaccard grubel ruzicka gower ///
	time(integer 0) cid(integer 0) timevar(varname) ///
	savecomp(string) saveresult(string) detail realvalues  ]


if !missing("`realvalues'") {
local realvalues="RV"
}
if missing("`varpartner'") {
local varpartner="j3"
}
if !missing("`detail'"){
local detail ="noisily"
}
if !missing("`in'") {
qui keep `in'
}
if !missing("`if'") {
qui keep `if'
}
if missing("`finger'") {
	if missing("`braycurtis'") {
		if missing("`cosine'") {
			if missing("`jaccard'") {
				if missing("`grubel'") {
					if missing("`ruzicka'") {
						if missing("`gower'") {
						local finger="finger"
						local braycurtis="braycurtis"
						local cosine="cosine"
						local jaccard="jaccard"
						local grubel="grubel"
						local ruzicka="ruzicka"
						local gower="gower"
						}
					}
				}
			}
		}
	}
}
if regexm("`saveresult'" , "replace") {
	tokenize "`saveresult'" , parse(",")
	local replace replace
	local saveresult `1'
}
if regexm("`savecomp'" , "replace") {
	tokenize "`savecomp'" , parse(",")
	local replace replace
	local savecomp `1'
}
tokenize `"`using'"' , parse(" ") 
local using `1'
local wdata `2'


tokenize `"`varlist'"' , parse(" ") 
local compare1 `1'
local compare2 `2'
*dis "`compare1'"
*dis "`compare2'"

*****************************		
qui {
******************************if not easy starts
if "`compare2'"==""{
dis in yellow "Q: errors11"
dis in yellow "Q: errors?"

tokenize `"`wcountry'"' , parse(" ")
local wnum = wordcount(`"`wcountry'"')
forval l =1/`wnum' {
	local w`l' ``l''
	*dis `"`w`l''"'
	}


****************************************************
*check for obvious errors before calculation starts
noisily di as txt "{hline 22}"
`detail' dis in yellow "Q: Any obvious errors?"
if "`id'"==""{
	local id i3
}
if "`wvarname'"==""{
	local wvarname weight
}
if "`timevar'"==""{
	if `time'==0{
		cap drop t
		gen t=0
		local timevar t
	}
}
if "`saveit'"==""{
	local saveit FK
}
	
*****************************
capture confirm variable `compare1'
if _rc {
   	di in red "YES: Value variable does not exist		---> `compare1'"
	error
	}
	else {
	`detail' di in yellow "Value variable exists			---> `compare1' "
}
capture confirm variable `timevar'
if _rc {
   	di in red "YES: Time variable does not exist 		---> `timevar'"
	error
	}
	else {
	`detail' di in yellow "Time variable exists			---> `timevar'"
}
capture confirm variable `id'
if _rc {
   	di in red "YES: id variable does not exist		---> `id'"
	error
	}
	else {
	`detail' di in yellow "id variable exists			---> `id'"
}
if "`wdata'"!=""{
	di in yellow "varpartner variable exists 		---> `varpartner'"
	preserve
	qui use `wdata', clear
	capture confirm variable `wvarname'
	if _rc {
	  	di in red "YES: Weight variable (in weight dataset) (`wvarname') does not exist"
		error
		}
		else {
		`detail' di in yellow "Weight variable (in weight dataset) exists	---> `wvarname'"
	}
	qui restore
}
if "`wcountry'"!=""{	
	capture count if "`id'"=="`wcountry'"
	if `r(N)'!=0 {
	   	di in red "YES: The reference id (wcountry) does not exist 	---> `wcountry'"
		error
		}
		else {
		`detail' di in yellow "The reference id (wcountry) exists	---> `id'"
	}
}
capture confirm variable `class'
if _rc {
   	di in red "YES: Categorization does not exist		---> `class'"
	error
	}
	else {
	`detail' di in yellow "Categorization exists			---> `class'"
}
capture confirm string `class'
if _rc{
   	di in yellow "Variable `class' is now a string variable."
	tostring `id', replace force
	}
if `time'==0{		
	qui capture count if `timevar'==`time' 
	if `r(N)'==0 {
		di in red "YES: Period of interest does not exist	---> `time'"
		error
		}
		else {
		`detail' di in yellow "Period of interest exists		---> `time'"
	}
}
if `cid'!=0{		
	qui capture count if `timevar'==`cid' 
	if `r(N)'==0 {
		di in red "YES: Period of interest in cid() does not exist	---> `cid'"
		error
		}
		else {
		`detail' di in yellow "Period of interest in cid() exists	---> `cid'"
	}
}
tempvar tagdub
qui duplicates tag `id' `timevar' `class', gen(`tagdub')
qui su `tagdub'
if `r(min)'==1{
	noisily dis in red "ERROR: the master data are identified by `id' `timevar' and `class', maybe specify a time period of interest."
	error
}
tempfile tradei3hs
save `tradei3hs', replace
if "`wdata'"=="" {
	if "`wcountry'"=="" {
		noisily dis in yellow "YES: You have to specify either the wcountry option, or the wdata option"
		error 102
		}
	}
	else {
		if "`wcountry'"!="" {
			noisily dis in yellow "YES: You have to specify either the wcountry option, or the wdata option"
			error 103
		}
}
****** create dataset to cross i3 hs t
*make a dateset with all id 
if "`wdata'"!="" {
	use `wdata', clear
	keep `id'
	duplicates drop `id', force
	tempfile i3w
	save `i3w', replace
	use `wdata', clear
	capture confirm variable `id'
	if _rc {
		`detail' dis in green "Variable `id' does not exists in the weight dataset"
		error
		}
		else {
		`detail' dis in green "Variable `id' exists in the weight dataset"
		}
	capture confirm variable `varpartner'
	if _rc {
		`detail' dis in green "Variable `varpartner' does not exists in the weight dataset"
		error
		}
		else {
 		`detail' dis in green "Variable `varpartner' exists in the weight dataset"
		}
}
noisily dis in green "A: No obvious errors."

******************************************************** 			
**************************** Q: Which index is calculated?
`detail'  di as txt "{hline 22}"
`detail'  dis in yellow "Q: Which index should be calculated?"
if "`cosine'"!=""{
	`detail'  dis in green "A: The Cosine Index."
}
if "`braycurtis'"!=""{
	`detail'  dis in green "A: The Bray-Curtis Index."
}
if "`gower'"!=""{
	`detail'  dis in green "A: The Gower Index."
}
if "`jaccard'"!=""{
	`detail'  dis in green "A: The Jaccard Index."
}
if "`grubel'"!=""{
	`detail'  dis in green "A: The Grubel-Lloyd Index."
}
if "`finger'"!=""{
	`detail'  dis in green "A: The Finger-Kreinin Index."
}
if "`ruzicka'"!=""{
	`detail'  dis in green "A: The Ruzicka Index."
}



if "`realvalues'"=="rv"{
	`detail'  dis in green "Note: The Indicator(s) are calculated using the real values."
	if !missing("`finger'") {
		`detail'  dis in red "Note: Using real values, the Finger-Kreinin index does not range from 0 to 1!"
	}
}	
if "`realvalues'"==""{
	`detail'  dis in green "A: The indicator(s) are calculated using shares."
}	
	



use `tradei3hs', clear
keep if (`timevar'==`time'| `timevar'==`cid')
if "`wdata'"!="" {
	merge m:1 `id' using `i3w', nogen keep(match)
}
bysort `id': gen nvals = _n == 1  
count if nvals
local i3count `r(N)'
`detail' dis in yellow "`i3count' = # of distinct values of `id'"
drop nvals
fillin `id' `class' `timevar'
replace `compare1'=0 if `compare1'==.
egen totexport_i3=total(`compare1'), by(`id' `timevar')
if !missing("`realvalues'"){
	gen s_ikt=`compare1'
	}
	else{
	gen s_ikt=`compare1'/totexport_i3
}
keep `id' `timevar' `class' s_ikt 
tempfile test_s_ikt
save `test_s_ikt', replace


************************************************
use `test_s_ikt', clear
keep `id' 
duplicates drop `id', force
tempfile test_i3
save `test_i3' , replace
ren `id' `varpartner'
cross using `test_i3' 
tempfile weiwei
save `weiwei', replace

use `test_s_ikt', clear
keep `id' 
duplicates drop `id', force
tempfile testfk_i3
save `testfk_i3', replace

use `test_s_ikt', clear
keep `timevar'
duplicates drop `timevar', force
tempfile testfk_t
save `testfk_t', replace

use `test_s_ikt', clear
keep `class'
duplicates drop `class', force
tempfile testfk_hs
save `testfk_hs', replace

if `cid'!=0 {
	use `test_s_ikt', clear
	keep if `timevar'==`cid'
	replace `timevar'=`time'
	gen s_ikt`cid'=s_ikt
	keep `id' `class' s_ikt`cid' `timevar'
	tempfile test_s_ikt95
	save `test_s_ikt95', replace
}

use `test_s_ikt', clear
ren `id' `varpartner'
ren s_ikt s_jkt 
tempfile test_s_jkt 
save `test_s_jkt', replace

	
****** user spatial weight
********************************************************************************
****** weight dataset
noisily di as txt "{hline 22}"
noisily dis in yellow "Q: Did the user specify a weight dataset?"
if "`wdata'"!=""{
	noisily dis in green "A: YES ---> `wdata' "
	noisily di as txt "{hline 22}"
	**********
	use `weiwei', clear
	merge m:1 `id' `varpartner' using `wdata', nogen keep(match)
	drop if `wvarname'==.
	******* do weights add up to one
	noisily di as txt "{hline 22}"
	noisily dis in yellow "Q: Do the weights add up to one for each `id' (in the raw weight data)"
	egen weightsum=total(`wvarname'), by(`id')
	su weightsum
	if float(`r(mean)')!=1 {                       // new this version
		noisily dis in yellow "A: NO, we need to adjust the weight..."
		replace `wvarname'=`wvarname'/weightsum
		egen weightsum2=total(`wvarname'), by(`id')
		drop if `wvarname'==.
		su weightsum2
		if float(`r(mean)')==1 { 
			noisily dis in green "   ...weights successfully adjusted"
			noisily di as txt "{hline 22}"
			cap drop weightsum weightsum2
			}
			else {
				noisily dis in red "   ...weights not successfully adjusted"
				error
			}
		}
		else {
		noisily dis in green "A: YES"
		noisily di as txt "{hline 22}"
		}
	tempfile dataweight
	save dataweight, replace
	save `dataweight', replace
}
if "`wdata'"==""{
	noisily dis in green "A: NO. The exports should be compared to the equally weighted average of the following countries (`wcountry')."
	noisily dis in yellow "Automatic calculation of the weighting scheme..."
	use `weiwei', clear
	drop if (`id'==j3 & `id'!= "`wcountry'")
	gen helpw=0
	forval l =1/`wnum' {
		replace helpw=1 if j3=="`w`l''"
		}
	egen sumw=total(helpw), by(`id')
	gen `wvarname'= helpw/sumw
	keep `id' j3 `wvarname'
	tempfile dataweight
	save `dataweight', replace
	noisily dis in green "...DONE"
	noisily di as txt "{hline 22}"
	save dataweight, replace
	save `dataweight', replace
}

	
******* calculate reference country
`detail'  dis in yellow "Calculation of the s_i*kt..."
use `weiwei', clear
cross using `testfk_t'
cross using `testfk_hs'
bys `class': gen nvals = _n == 1 
count if nvals
`detail'  dis in yellow "		`r(N)' = # of distinct values of `class'"
drop nvals
gen Nvals = _N
count if Nvals
`detail'  dis in yellow "		`r(N)' = # of observations in the bilateral dataset"
drop Nvals
merge m:1 `varpartner' `timevar' `class' using `test_s_jkt', nogen 
merge m:1 `id' `varpartner' using `dataweight', nogen 



`detail'  dis in yellow "Merge the weighting scheme with trade data..."
`detail'  di as txt "{hline 22}"
`detail'  dis in yellow "Q: Are all countries in the weighting scheme matched successfully?"
`detail'  dis in yellow "Note: If this is not the case, the weights do not add up to one for each `id'"
cap drop weightsum
replace `wvarname'=0 if `wvarname'==.
*drop if `wvarname'==.
egen weightsum=total(`wvarname'), by(`id' `timevar' `class')
su weightsum
if float(`r(mean)')!=1 {
	`detail' noisily dis in red "A: NO, we need to adjust the `wvarname'..."
	replace `wvarname'=`wvarname'/weightsum
	cap drop weightsum
	egen weightsum=total(`wvarname'), by(`id' `timevar' `class')
	sum weightsum
	if float(`r(mean)')==1 { 
			`detail' noisily dis in green "   ...weights successfully adjusted"
			noisily di as txt "{hline 22}"
			}
			else {
			`detail' noisily dis in red "   ...weights not successfully adjusted"
			error
			}
	}
	else {
		`detail'  dis in green "A: YES"
		`detail'  di as txt "{hline 22}"
}
gen s_j3kt=s_jkt*`wvarname'
collapse (sum) s_j3kt, by(`id' `class' `timevar')
*noisily dis in yellow "...calculation of the s_k* was sucessfull"
*noisily di as txt "{hline 22}"
merge m:1 `id' `timevar' `class' using `test_s_ikt', nogen keep(match)
tempfile basic_calc
save `basic_calc', replace
*save basic_calc, replace

if !missing("`savecomp'") {
	ren s_j3kt comp2
	ren s_ikt comp1
	noisily save "`savecomp'", `replace'
	}
	else {
	noisily dis in yellow "File of comparison is not saved"
}
******** if not easy ends
}


dis in yellow "Q: errors?2"
if "`compare2'"!=""{


keep `compare1' `compare2' `class' `timevar'

if !missing("`realvalues'"){
	ren `compare1' s_ikt
	ren `compare2' s_j3kt
	}
	else{
	ren `compare1' s_ikt
	ren `compare2' s_j3kt
	egen toti=total(s_ikt) , by(`timevar')
	replace s_ikt=s_ikt/toti
	egen totj=total(s_j3kt), by(`timevar')
	replace s_j3kt=s_j3kt/totj
	drop toti totj
}

if `cid'!=0 {
	preserve
	keep if `timevar'==`cid'
	replace `timevar'=`time'
	gen s_ikt`cid'=s_ikt
	keep `id' `class' s_ikt`cid' `timevar'
	tempfile test_s_ikt95
	save `test_s_ikt95', replace
	restore
}

if `time'!=0{
	drop if `timevar'!=`time'
	}
tempfile basic_calc
save basic_calc, replace
save `basic_calc', replace
}


`detail' noisily dis in yellow "Calculation of the indices..."
************************************************************************************************
if "`gower'"!=""{
	use `basic_calc', clear
	`detail' dis in yellow "Calculation of the Gower index..."
	gen xik_xjk=abs(s_ikt-s_j3kt)
	egen maxi=max(s_ikt), by(`id' `timevar')
	egen mini=min(s_ikt), by(`id' `timevar')
	gen spread=maxi-mini
	su spread
	if `r(min)'<=0{
		dis in red "Warning: The Gower Index cannot be calculated properly. Please check your data and the prerequisites of the Gower Index."
		}
	gen count=1
	collapse (sum) xik_xjk count (firstnm) spread, by(`id' `timevar')
	gen `gower'`realvalues'`class'=1/count*(xik_xjk/spread)
	keep `gower'`realvalues'`class' `id' `timevar'
	if "`compare2'"!=""{
		gen id=_n
		}
	tempfile gower_result
	save `gower_result', replace
	`detail'  dis in green "...DONE"
	if `cid'!=0 {
		`detail'  dis in yellow "Calculation of the CID index..."
		use `basic_calc', clear
		merge m:1 `id' `timevar' `class' using `test_s_ikt95', nogen keep(match)
		gen xik_xjk=abs(s_ikt-s_ikt`cid')
		egen maxi=max(s_ikt), by(`id' `timevar')
		egen mini=max(s_ikt), by(`id' `timevar')
		gen spread=maxi-mini
		gen count=1
		collapse (sum) xik_xjk count (firstnm) spread, by(`id' `timevar')
		gen CID`gower'`realvalues'`class'=1/count*(xik_xjk/spread)
		keep CID`gower'`realvalues'`class' `id' `timevar'
		merge 1:1 `id' `timevar' using `braycurtis_result', nogen 
		cap keep if `timevar'==`time'
		save `gower_result', replace
		`detail'  dis in green "...DONE"
		}
	if "`compare2'"==""{
		use `basic_calc', clear
		keep `id' `timevar'
		duplicates drop `id' `timevar', force
		merge 1:1 `id' `timevar' using `gower_result', nogen keep(match)	
		save `gower_result', replace
		}
	}
************************************************************************************************
if "`braycurtis'"!=""{
	use `basic_calc', clear
	`detail' dis in yellow "Calculation of the Bray-Curtis index..."
	gen xik_xjk=abs(s_ikt-s_j3kt)
	gen xik_2_xjk=(s_ikt+s_j3kt)
	collapse (sum) xik_xjk xik_2_xjk, by(`id' `timevar')
	gen `braycurtis'`realvalues'`class'=1-(xik_xjk/xik_2_xjk)
	keep `braycurtis'`realvalues'`class' `id' `timevar'
	if "`compare2'"!=""{
		gen id=_n
		}
	tempfile braycurtis_result
	save `braycurtis_result', replace
	`detail'  dis in green "...DONE"
	if `cid'!=0 {
		`detail'  dis in yellow "Calculation of the CID index..."
		use `basic_calc', clear
		merge m:1 `id' `timevar' `class' using `test_s_ikt95', nogen keep(match)	
		gen xik_xjk=abs(s_ikt-s_ikt`cid')
		gen xik_2_xjk=(s_ikt+s_ikt`cid')
		collapse (sum) xik_xjk xik_2_xjk, by(`id' `timevar')
		gen `braycurtis'`realvalues'`class'=1-(xik_xjk/xik_2_xjk)
		keep `braycurtis'`realvalues'`class' `id' `timevar'
		replace `braycurtis'`realvalues'`class'=1-`braycurtis'`realvalues'`class'
		ren `braycurtis'`realvalues'`class' CID`braycurtis'`realvalues'`class'
		merge 1:1 `id' `timevar' using `braycurtis_result', nogen 
		cap keep if `timevar'==`time'
		save `braycurtis_result', replace
		`detail'  dis in green "...DONE"
		}
	if "`compare2'"==""{
		use `basic_calc', clear
		keep `id' `timevar'
		duplicates drop `id' `timevar', force
		merge 1:1 `id' `timevar' using `braycurtis_result', nogen keep(match)	
		save `braycurtis_result', replace
		}
	}
************************************************************************************************
if "`cosine'"!=""{
	use `basic_calc', clear
	`detail'  dis in yellow "Calculation of the Cosine index..."
	gen cos1=s_ikt*s_j3kt
	gen cos2=s_ikt*s_ikt
	gen cos3=s_j3kt*s_j3kt
	collapse (sum)  cos1 cos2 cos3, by(`timevar' `id')
	gen cos4=(cos2*cos3)^.5
	gen `cosine'`realvalues'`class'=cos1/cos4
	keep `cosine'`realvalues'`class' `id' `timevar'
	if "`compare2'"!=""{
		gen id=_n
		}
	tempfile cosine_result
	save `cosine_result', replace
	`detail'  dis in green "...DONE"
	if `cid'!=0 {
		`detail'  dis in yellow "Calculation of the CID index..."
		use `basic_calc', clear
		merge m:1 `id' `timevar' `class' using `test_s_ikt95', nogen keep(match)	
		gen cos1=s_ikt*s_ikt`cid'
		gen cos2=s_ikt*s_ikt
		gen cos3=s_ikt`cid'*s_ikt`cid'
		collapse (sum)  cos1 cos2 cos3, by(`timevar' `id')
		gen cos4=(cos2*cos3)^.5
		gen CID`cosine'`realvalues'`class'=cos1/cos4
		keep CID`cosine'`realvalues'`class' `id' `timevar'
		replace CID`cosine'`realvalues'`class'=1-CID`cosine'`realvalues'`class'
		merge 1:1 `id' `timevar' using `cosine_result', nogen 
		cap keep if `timevar'==`time'
		save `cosine_result', replace
		`detail'  dis in green "...DONE"
	}
	if "`compare2'"==""{
		use `basic_calc', clear
		keep `id' `timevar'
		duplicates drop `id' `timevar', force
		merge 1:1 `id' `timevar' using `cosine_result', nogen keep(match)	
		save `cosine_result', replace
		}
}
************************************************************************************************
if "`jaccard'"!=""{
	use `basic_calc', clear
	`detail'  dis in yellow "Calculation of the Jaccard index..."
	gen jac1=s_ikt*s_j3kt
	gen jac2=s_ikt*s_ikt
	gen jac3=s_j3kt*s_j3kt
	collapse (sum)  jac1 jac2 jac3, by(`timevar' `id')
	gen `jaccard'`realvalues'`class'=(jac1)/(jac2+jac3-jac1)
	keep `jaccard'`realvalues'`class' `timevar' `id'
	if "`compare2'"!=""{
		gen id=_n
		}
	tempfile jac_result
	save `jac_result', replace
	`detail'  dis in green "...DONE"
	if `cid'!=0 {
		`detail'  dis in yellow "Calculation of the CID index..."
		use `basic_calc', clear
		merge m:1 `id' `timevar' `class' using `test_s_ikt95', nogen keep(match)	
		gen jac1=s_ikt*s_ikt`cid'
		gen jac2=s_ikt*s_ikt
		gen jac3=s_ikt`cid'*s_ikt`cid'
		collapse (sum)  jac1 jac2 jac3, by(`timevar' `id')
		gen CID`jaccard'`realvalues'`class'=(jac1)/(jac2+jac3-jac1)
		keep CID`jaccard'`realvalues'`class' `timevar' `id'
		replace CID`jaccard'`realvalues'`class'=1-CID`jaccard'`realvalues'`class'
		merge 1:1 `id' `timevar' using `jac_result', nogen keep(match)
		save `jac_result', replace
		`detail'  dis in green "...DONE"
	}
	if "`compare2'"==""{
		use `basic_calc', clear
		keep `id' `timevar'
		duplicates drop `id' `timevar', force
		merge 1:1 `id' `timevar' using `jac_result', nogen keep(match)	
		save `jac_result', replace
		}
}
************************************************************************************************
if "`grubel'"!=""{
	use `basic_calc', clear
	`detail'  dis in yellow "Calculation of the Grubel-Lloyd index..."
	gen g1=((s_ikt+s_j3kt)-abs(s_ikt-s_j3kt))/(s_ikt+s_j3kt)
	gen knum=1
	replace knum=0 if g1==.
	collapse (sum)  g1 knum, by(`timevar' `id')
	gen `grubel'`realvalues'`class'=(1/knum)*g1
	keep `grubel'`realvalues'`class' `timevar' `id'
	if "`compare2'"!=""{
		gen id=_n
		}
	tempfile gli_result
	save `gli_result', replace
	`detail'  dis in green "...DONE"
	if `cid'!=0 {
		`detail'  dis in yellow "Calculation of the CID index..."
		use `basic_calc', clear
		merge m:1 `id' `timevar' `class' using `test_s_ikt95', nogen keep(match)	
		gen g1=((s_ikt+s_ikt`cid')-abs(s_ikt-s_ikt`cid'))/(s_ikt+s_ikt`cid')
		gen knum=1
		collapse (sum)  g1 knum, by(`timevar' `id')
		gen CID`grubel'`realvalues'`class'=(1/knum)*g1
		keep CID`grubel'`realvalues'`class' `timevar' `id'
		replace CID`grubel'`realvalues'`class'=1-CID`grubel'`realvalues'`class'
		merge 1:1 `id' `timevar' using `gli_result', nogen keep(match)	
		save `gli_result', replace
		`detail'  dis in green "...DONE"
	}
	if "`compare2'"==""{
		use `basic_calc', clear
		keep `id' `timevar'
		duplicates drop `id' `timevar', force
		merge 1:1 `id' `timevar' using `gli_result', nogen keep(match)	
		save `gli_result', replace
		}
}

************************************************************************************************
if "`ruzicka'"!=""{
	use `basic_calc', clear
	`detail'  dis in yellow "Calculation of the Ruzicka index..."
	gen g1=min(s_ikt,s_j3kt)
	gen g2=max(s_ikt,s_j3kt)
	collapse (sum)  g1 g2, by(`timevar' `id')
	gen `ruzicka'`realvalues'`class'=g1/g2
	keep `ruzicka'`realvalues'`class' `timevar' `id'
	if "`compare2'"!=""{
		gen id=_n
		}
	tempfile ruz_result
	save `ruz_result', replace
	`detail'  dis in green "...DONE"
	if `cid'!=0 {
		`detail'  dis in yellow "Calculation of the CID index..."
		use `basic_calc', clear
		merge m:1 `id' `timevar' `class' using `test_s_ikt95', nogen keep(match)	
		gen g1=min(s_ikt,s_ikt`cid')
		gen g2=max(s_ikt,s_ikt`cid')
		collapse (sum)  g1 g2, by(`timevar' `id')
		gen CID`ruzicka'`realvalues'`class'=g1/g2
		keep CID`ruzicka'`realvalues'`class' `timevar' `id'
		replace CID`ruzicka'`realvalues'`class'=1-CID`ruzicka'`realvalues'`class'
		merge 1:1 `id' `timevar' using `ruz_result', nogen keep(match)	
		save `ruz_result', replace
		`detail'  dis in green "...DONE"
	}
	if "`compare2'"==""{
		use `basic_calc', clear
		keep `id' `timevar'
		duplicates drop `id' `timevar', force
		merge 1:1 `id' `timevar' using `ruz_result', nogen keep(match)	
		save `ruz_result', replace
		}
}


************************************************************************************************
	if "`finger'"!=""{
		`detail'  dis in yellow "Calculation of the Finger-Kreinin index..."
		use `basic_calc', clear
		gen `finger'`realvalues'`class'=min(s_ikt,s_j3kt)
		`detail'  dis in green "...DONE"
		if `cid'!=0 {
			`detail'  dis in yellow "Calculation of the CID index..."
			merge m:1 `id' `timevar' `class' using `test_s_ikt95', nogen keep(match)	
			gen CID`finger'`realvalues'`class'=min(s_ikt,s_ikt`cid')
			collapse (sum) CID`finger'`realvalues'`class' `finger'`realvalues'`class', by(`id' `timevar')
			replace CID`finger'`realvalues'`class'=1-CID`finger'`realvalues'`class'
			`detail'  dis in green "...DONE"
			}
		else {
			collapse (sum)  `finger'`realvalues'`class', by(`id' `timevar')
			}
		if "`compare2'"!=""{
			gen id=_n
			}	
		tempfile finger_result
		save `finger_result', replace
		save fk, replace
	}
	use `basic_calc', clear
		
	noisily dis in yellow "Merge the results..."
	if "`compare2'"==""{
		keep `id' `timevar'
		duplicates drop `id' `timevar', force
		drop if (`timevar'==`cid' & `cid' !=0 & `timevar'!=0)
		cap merge 1:1 `id' `timevar' using `finger_result', nogen 
		cap merge 1:1 `id' `timevar' using `dice_result', nogen 
		cap merge 1:1 `id' `timevar' using `jac_result', nogen 
		cap merge 1:1 `id' `timevar' using `braycurtis_result', nogen 
		cap merge 1:1 `id' `timevar' using `gower_result', nogen 
		cap merge 1:1 `id' `timevar' using `cosine_result', nogen 
		cap merge 1:1 `id' `timevar' using `gli_result', nogen 
		cap merge 1:1 `id' `timevar' using `ruz_result', nogen 
		if  (`cid' ==0 & `timevar'==0) {
			drop `timevar' 
			}
		noisily dis in green "...DONE"
		noisily  di as txt "{hline 22}"
		}
		else{
		use `basic_calc', clear
		keep `timevar'
		duplicates drop `timevar', force
		gen id=_n
		
		cap merge 1:1 id `id' `timevar' using `finger_result', nogen keep(match)
		cap merge 1:1 id `id' `timevar' using `dice_result', nogen keep(match)
		cap merge 1:1 id `id' `timevar' using `jac_result', nogen keep(match)
		cap merge 1:1 id `id' `timevar' using `braycurtis_result', nogen keep(match)
		cap merge 1:1 id `id' `timevar' using `gower_result', nogen keep(match)
		cap merge 1:1 id `id' `timevar' using `cosine_result', nogen keep(match)
		cap merge 1:1 id `id' `timevar' using `gli_result', nogen keep(match)
		cap merge 1:1 id `id' `timevar' using `ruz_result', nogen keep(match)
		gen compare2="`compare1'"+ " with " + "`compare2'"
		label var compare2 "compare"
		drop id		
		}
		
	
	
	
if !missing("`saveresult'") {
		noisily save "`saveresult'", `replace'
		}
		else {
		noisily dis "Results were not saved"
		}
		
		

	}
end



