********************************************************************************
*This file used the clean data saved in the directory as "IPUM14"
********************************************************************************


clear
cd "/Users/oladimeji/Desktop/laboreconomics/replication/labordata"
log using "/Users/oladimeji/Desktop/laboreconomics/replication/labordata/Fig6.log"
use IPUM14.dta


********************************************************************************
*Drop all variables in the "cleaned-up data except year, stateicp and the female weekly wage
* Drop all all years except year == 1940
********************************************************************************
drop urban-fwkwage1959 sample-region
drop if year==1950 |year==1960 | year==1990  | year==1970 | year==1980
drop  if flwkwagek==.

********************************************************************************
*Compute the mean of the female weekly wage for each state, and save it with "flwkwagek1940"
* Then save the data file with "IPUMmean1940"
********************************************************************************
collapse (mean) flwkwagek, by(stateicp)
gen flwkwagek1940 = flwkwagek
drop  flwkwagek
save "IPUMmean1940", replace



********************************************************************************
*TImport the cleaned-up data againn"IPUM14"
********************************************************************************


clear
cd "/Users/oladimeji/Desktop/laboreconomics/replication/labordata"
use IPUM14.dta

********************************************************************************
*Drop all variables in the "cleaned-up data except year, stateicp and the female weekly wage
* Drop all all years except year == 1950
********************************************************************************
drop urban-fwkwage1959 sample-region
drop if year==1940 |year==1960 | year==1990  | year==1970 | year==1980
drop if flwkwagek==.

********************************************************************************
*Compute the mean of the female weekly wage for each state, and save it with "flwkwagek1950"
* Then save the data file with "IPUMmean1950"
********************************************************************************
collapse (mean) flwkwagek, by(stateicp)
gen flwkwagek1950 = flwkwagek
drop  flwkwagek
save "IPUMmean1950", replace


********************************************************************************
*Clear the  variale window and import the above saved data file and merge them with 
*file with mobilizatio rate data and save the file with "Fig6"
********************************************************************************
clear 
use IPUMmean1940.dta

sort stateicp

merge stateicp using  IPUMmean1950.dta

drop  _merge



sort stateicp

merge stateicp using stateicp.dta

drop age13441-year
drop  _merge


sort stateicp

merge stateicp using stateicpd.dta

drop  _merge

gen Dlogwage= ((flwkwagek1950 - flwkwagek1940)/flwkwagek1940)
save "Fig6", replace


********************************************************************************
*Import the data name "Fig6.data and plot the graph 
********************************************************************************
use Fig6.dta

twoway (lfit Dlogwage d1844) (scatter Dlogwage d1844, msymbol(none) mlabel(stateicd)), ytitle(Change in mean log weekly wage) xtitle(Percent of Eligible Males ages 18 - 44 Mobilized) legend(off)


