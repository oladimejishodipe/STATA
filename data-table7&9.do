********************************************************************************
/*This file imports the cleaned-up data "IPUM14.dta" and drop observations 
for year 1960 - 1990, generate additional variables to be used in estimating 
table 7 & 9  1940 -1990 */
********************************************************************************
clear
cd "/Users/oladimeji/Desktop/laboreconomics/replication/labordata"

log using "/Users/oladimeji/Desktop/laboreconomics/replication/labordata/data-table7&9.log"

use IPUM14.dta



*********************************************************
*Drop observation for years 1960 - 1990
********************************************************* 
drop if year==1960 
drop if year==1970 
drop if year==1980 
drop if year==1990 


*********************************************************
/*Generate a variable "mobdum1950" that interacts the mobilization rates with
1950 dummy */
********************************************************* 
gen mobdum1950=dummy1950*d1844


*********************************************************
/*Generate a dummy variable "farmer" for faamer  */
********************************************************* 
gen byte farmer=(farmd==1)


*********************************************************
/*Generate a variable "mEdyrs40dumm195" that interacts the mean of education for 
men with 1950 dummy */
********************************************************* 
gen  Edyrs40=Edyrs
replace Edyrs40=0 if female==1 
gen Edyrs40dumm1950= Edyrs40*dummy1950



*********************************************************
/*Generate a variable "mag1424y1950" that interacts the men with age range of 
14 - 24 and interact with  1950 dummy */
*********************************************************
gen  mag1424=age
replace mag1424=0 if female==1 & age>=25
gen  mag1424y1950= mag1424*dummy1950


*********************************************************
/*Generate a variable "mag2534y1950" that represents the age range 
25 - 35 of men and interact with  1950 dummy */
*********************************************************
gen mag2534=age
replace  mag2534=0 if female==1 & age>14 | age<25 | age>35
gen  mag2534y1950= mag2534*dummy1950


*********************************************************
/*Generate a dummy variable "germy1950" represents German born male and 
interact with  1950 dummy */
*********************************************************
gen byte germ=(bplk==82)
replace  germ=0 if female==1 
gen   germy1950=  germ*dummy1950

*********************************************************
/*Generate a variable "dummy1950sfage" that interacts the female age
and interact with  1950 dummy */
*********************************************************

gen dummy1950sfage= dummy1950*sfage



*********************************************************
/*Generate  variables "sflwkwagedum195 & smlwkwagedum1950" 
that record the log of state mean wage of both male and female sepately
interact with 1950 dummy */
*********************************************************
sort stateicp
by stateicp: egen sfwrks=mean(fwrks) 
by stateicp: egen smwrks=mean(fwrks)

by stateicp: egen sflwkwage=mean(flwkwage) if year==1940
by stateicp: gen sflwkwage1=sflwkwage
gen sflwkwagedum1950=dummy1950*sflwkwage1

by stateicp: egen smlwkwage=mean(mlwkwage) if year==1940
by stateicp: gen smlwkwage1=smlwkwage
gen smlwkwagedum1950=dummy1950*smlwkwage1


*********************************************************
/*Generate set dummies for each birth place variable (as defined in the
"IPUM14.dta") and each age for the female already interacted woth 1950 dummies */
*********************************************************
xi i.bpl  i.dummy1950sfage

************************************************************
* Save this data as IPUM15 to be used in estimating Table 7 & 9
************************************************************
save "IPUM15", replace
