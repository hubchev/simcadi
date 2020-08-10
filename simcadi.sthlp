{smcl}
{* *! version 17Nov2016}{...}

{title:Title}

{p 4 8}{cmd:simcadi} {hline 2} 
Calculate and manage similarity indices 
{p_end}

{marker description}{...}
{title:Description}

{pstd}
The command permits the calculation of several similariy indicators for categorically ordered variables. In particular, 
it permits the calculation of the Cosine index, and indices introduced by Finger and Kreinin (1979), 
Bray and Curtis (1957), Dice (1945), Sorenson (1948), Jaccard (1912), Grubel and Lloyd (1971), Ruzicka (1958), and Gower (1971). Moreover, it allows us to compute the development of a distribution over time. The command offers various options for an efficient handling of datasets, 
because it permits the calculation of benchmarks of comparison automatically, and the incoporation of complex weighting schemes. 


{marker syntax}{...}
{title:Syntax}

{pstd}
If you want to compare two distributions (wide format):

{p 8 15 2}
{cmd:simcadi} {it:variable_1} {it:variable_2} {ifin} {cmd:,} {cmd:class(}{it:varname}{cmd:)} [{it:options}]

		{it:variable_1} defines the variable of interest.
		{it:variable_2} defines the variable of interest to which {it:variable1} should be compared.


{pstd}
If you have different distributions in one variable and you want to compare one distributions (or an unweighted composition of various distributions) to all other distributions:

{p 8 15 2}
{cmd:simcadi} {it:variable1}  {ifin}  {cmd:,} {cmd:class(}{it:varname}{cmd:)} {cmd:id(}{it:varname}{cmd:)} {cmd:wcountry(}{it:name}{cmd:)} [{it:options}]


{pstd}
If you want to calculate for each distribution a distribution with a weighting scheme to which it should be compared:

{p 8 15 2}	
{cmd:simcadi} {it:variable1} {cmd:using} {it:filename} {ifin}  {cmd:,} {cmd:class(}{it:varname}{cmd:)} {cmd:id(}{it:varname}{cmd:)} [{it:options}]

		{cmd:using} {it:filename} sets the file which contains the weighting matrix.


{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opth class(varname)}}specifies the variable containing the categories of the distributions (e.g. the trade classification).{p_end}
{synopt :{opth id(varname)}}specifies the variable that identifies the distributions (e.g. the countries).{p_end}
{synopt :{opth wcountry(name)}}sets the distribution with which each distribution should be compared. Note: if more than one distribution is set, 
the unweighted average of the distributions is calculated to work as the distribution of comparison.{p_end}
{synopt :{opth wvarname(varname)}}specifies the name of the variable that contains the weights (only applicable if a weighting matrix is assigned){p_end}
{synopt :{opth varpartner(varname)}}specifies the name of the second variable in the weighting scheme file (e.g. the trading partner). Only applicable if a weighting matrix is assigned.{p_end}

{synopt :{cmd: cid(#)}}calculates the Change in Distribution index (for each indicator chosen). # sets a period to which each 'id(varname)' is compared. Please consider that cid(#) also requires the option time(#). {p_end}
{synopt :{opt realvalues}}use the real values instead of the shares. Note: Applying real values follows that some indices (Gower) are defined between zero and one. (The default uses shares.){p_end}
{synopt :{opth time(#)}}sets the time period (e.g. 2012).{p_end}
{synopt :{opth timevar(varname)}}specifies the name of the time variable.{p_end}
{synopt :{opth savecomp(filename)}}stores the file with the distributions/variables that are compared (Note: The user can use this file to calculate further indices.){p_end}
{synopt :{opth saveresult(filename)}}stores the calculated indices under the name filename.{p_end}
{synopt :{cmd: detail}}offers a detailed description of the calculation process.{p_end}

{p2coldent :* {opt finger}}calculates the Finger-Kreinin index{p_end}
{p2coldent :* {opt braycurtis}}calculates the Bray-Curtis index (only allowed if the variable of interest contains positive values only){p_end}
{p2coldent :* {opt jaccard}}calculates the Jaccard index{p_end}
{p2coldent :* {opt cosine}}calculates the Cosine index{p_end}
{p2coldent :* {opt grubel}}calculates the Grubel-Lloyd index{p_end}
{p2coldent :* {opt ruzicka}}calculates the Ruzicka index{p_end}
{p2coldent :* {opt gower}}calculates the Gower index{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}* All indices are calculated if none of these options is specified{p_end}

{marker Examples}{...}
{title:Examples}

{pstd}In the following we use a dataset (example_consume) which contains the following data:{p_end}

	{center:{hline 37}}
	{center:name 	time	good	consume}
	{center:{hline 37}}
  {center: 	Adam      2   	bread        18 }
  {center: 	Adam      2   	water        17 }
  {center: 	Adam      2    	beer         19 }
  {center: 	Brittany  2   	bread        11 }
  {center: 	Brittany  2   	water        16 }
  {center: 	Brittany  2    	beer          7 }
  {center: 	Charlie   2   	bread        12 }
  {center: 	Charlie   2   	water        12 }
  {center: 	Charlie   2    	beer          1 }
  {center: 	Adam      1   	bread        18 }
  {center: 	Adam      1   	water        18 }
  {center: 	Adam      1    	beer         18 }
  {center: 	Brittany  1   	bread        15 }
  {center: 	Brittany  1   	water        13 }
  {center: 	Brittany  1    	beer          9 }
  {center:	Charlie   1   	bread        10 }
  {center: 	Charlie   1   	water        10 }
  {center: 	Charlie   1    	beer          0 }
	{center:{hline 37}}

{txt}      ({stata "simcadi_dataex":--> click to generate and save these data})


**** Example (wide format)
{p 4 10 8}{stata use example_consume, clear}{p_end}
{p 4 10 8}{stata reshape wide consume, i(good time) j(name) string}{p_end}
{p 4 10 8}{stata simcadi consumeCharlie consumeAdam, class(good) timevar(time)}{p_end}

**** Example (wide format)
{p 4 10 8}{stata use example_consume, clear}{p_end}
{p 4 10 8}{stata reshape wide consume, i(good time) j(name) string}{p_end}
{p 4 10 8}{stata simcadi consumeCharlie consumeAdam, class(good) time(2) timevar(time) cid(1) finger cosine}{p_end}

**** Example (long format) (wcountry) (savecomp)
{p 4 10 8}{stata use example_consume, clear}{p_end}
{p 4 10 8}{stata list}{p_end}
{p 4 10 8}{stata simcadi consume , class(good) id(name) wcountry(Adam) time(1) timevar(time) savecomp(filename, replace) detail realvalues}{p_end}
{p 4 10 8}{stata list}{p_end}
{p 4 10 8}{stata use filename, clear}{p_end}
{p 4 10 8}{stata list}{p_end}

**** Example (wcountry --- extended)
{p 4 10 8}{stata use example_consume, clear}{p_end}
{p 4 10 8}{stata simcadi consume , class(good) id(name) wcountry(Adam Brittany Charlie) time(1) timevar(time) detail }{p_end}

**** Example (wdata)
{p 4 10 8}{stata use example_consume, clear}{p_end}
{p 4 10 8}{stata keep name}{p_end}
{p 4 10 8}{stata duplicates drop name, force}{p_end}
{p 4 10 8}{stata save Charlie, replace}{p_end}
{p 4 10 8}{stata ren name name2}{p_end}
{p 4 10 8}{stata cross using Charlie}{p_end}
{p 4 10 8}{stata gen weight=0}{p_end}
{p 4 10 8}{stata replace weight=1 if name2=="Adam"}{p_end}
{p 4 10 8}{stata order name name2 weight}{p_end}
{p 4 10 8}{stata sort name name2 weight}{p_end}
{p 4 10 8}{stata save weight_exa_cons, replace}{p_end}

{p 4 10 8}{stata use example_consume, clear}{p_end}
{p 4 10 8}{stata simcadi consume using weight_exa_cons, class(good) id(name) time(1) timevar(time) varpartner(name2) detail}{p_end}

**** Example (wdata --- complex weighting scheme)
{p 4 10 8}{stata use weight_exa_cons, clear}{p_end}
{p 4 10 8}{stata replace weight=1 if name=="Brittany"}{p_end}
{p 4 10 8}{stata replace weight=2 if (name=="Adam" & name2=="Charlie")}{p_end}
{p 4 10 8}{stata replace weight=2 if (name=="Charlie" & name2=="Adam")}{p_end}
{p 4 10 8}{stata replace weight=1 if (name=="Charlie" & name2=="Charlie")}{p_end}
{p 4 10 8}{stata save weight_exa_cons2, replace}{p_end}

{p 4 10 8}{stata use example_consume, clear}{p_end}
{p 4 10 8}{stata simcadi consume using weight_exa_cons2, class(good) id(name) time(1) timevar(time) varpartner(name2) detail}{p_end}


{marker references}{...}
{title:References}

- Huber S. (2016): simcadi: Similarity Indices for Categorical Distributions. See: http://ssrn.com/abstract=2870834

{marker author}{...}
{title:Author}

Stephan Huber 
stephan.huber@wiwi.uni-regensburg.de


