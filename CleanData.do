******************************************************************
* This file imports original census data saved on my drive
* This is where I did most of the data cleaning
******************************************************************
clear
cd "/Users/oladimeji/Desktop/laboreconomics/replication/labordata"

log using "/Users/oladimeji/Desktop/laboreconomics/replication/labordata/cleandata.log"

use IPUM13.dta


******************************************************************************
/*
This code classifies the 47 states into three categories:
"1" for states which fall  under low mobilization 
"2" for states which fall under medium mobilization 
"3" for states which high under high mobilization 
*/
***************************************************************************
generate mobstate=.
replace mobstate=1 if stateicp==44
replace mobstate=1 if stateicp==36
replace mobstate=1 if stateicp==37
replace mobstate=1 if stateicp==47
replace mobstate=1 if stateicp==48
replace mobstate=1 if stateicp==25
replace mobstate=1 if stateicp==45
replace mobstate=1 if stateicp==41
replace mobstate=1 if stateicp==42
replace mobstate=1 if stateicp==46
replace mobstate=1 if stateicp==40
replace mobstate=1 if stateicp==54
replace mobstate=1 if stateicp==51
replace mobstate=1 if stateicp==22
replace mobstate=1 if stateicp==23
replace mobstate=1 if stateicp==31
replace mobstate=2 if stateicp==34
replace mobstate=2 if stateicp==49
replace mobstate=2 if stateicp==35
replace mobstate=2 if stateicp==33
replace mobstate=2 if stateicp==52
replace mobstate=2 if stateicp==11
replace mobstate=2 if stateicp==06
replace mobstate=2 if stateicp==21
replace mobstate=2 if stateicp==43
replace mobstate=2 if stateicp==66
replace mobstate=2 if stateicp==56
replace mobstate=2 if stateicp==24
replace mobstate=2 if stateicp==13
replace mobstate=2 if stateicp==68
replace mobstate=2 if stateicp==53
replace mobstate=3 if stateicp==32
replace mobstate=3 if stateicp==64
replace mobstate=3 if stateicp==01
replace mobstate=3 if stateicp==61
replace mobstate=3 if stateicp==62
replace mobstate=3 if stateicp==12
replace mobstate=3 if stateicp==63
replace mobstate=3 if stateicp==71
replace mobstate=3 if stateicp==73
replace mobstate=3 if stateicp==14
replace mobstate=3 if stateicp==67
replace mobstate=3 if stateicp==04
replace mobstate=3 if stateicp==72
replace mobstate=3 if stateicp==05
replace mobstate=3 if stateicp==03
replace mobstate=3 if stateicp==02
*********************************************************


******************************************************************************
/* Generate dummy variable "dummy1950" for year 1950. If year = 1950, record "1"
otherwise, recoord 0  */
gen byte dummy1950=(year==1950)
*******************************************************************************


********************************************************
/* Generate a variable "sfage" for that contain only female age, anywhere 
male age appears record as missing (.)  */
gen sfage=age

replace sfage=. if sex==1
*********************************************************

******************************************************************************
/* Generate two dummy variables "female" and "male"

For female dummy, if gender is female record "1", otherwise record "0" 
For male dummy, if gender is male record "1", otherwise record "0" 
*/

gen byte female=(sex==2)
gen byte male=(sex==1)
*******************************************************

*******************************************************
/*Generate two variables to record age of men and age of women 

Male -  Mage

Female - Fage
*/

gen byte Mage=age

replace Mage=. if sex==2

gen byte Fage=age

replace Fage=. if sex==1
*******************************************************

*******************************************************
/* slwt is the number of persons in the general population represented
 by each sample-line person in 1940 and 1950. slwt=> 0. So we want to drop 
individual whose slwt is 0
*/ 
keep if slwt>0
*******************************************************

***********************************************************************
/* The excel file - mobilization rates on convas is not coded by states, I decided to
merge the author file "state-dems-s-4.dta". This file contains the mobilization
rates by states and it is already coded by state. It was easy for me to merge*/

sort stateicp

merge stateicp using stateicp.dta

keep if _merge==3

drop _merge
***********************************************************************

********************************************************
/* Removing from the samples individuals are less than 14  and holder than 64
*/
drop if age<14 
drop if age>64
*******************************************************

*******************************************************
*Removing from  the samples individuals who lived in Institutional Group Quarters

drop if gqtyped>=100 & gqtyped<=500
*******************************************************


*******************************************************
/*Dropping the missing values (coded 999999) and individuals who failed to report their 
earnings - N/A (coded 999998) */

drop if incwage==999999|incwage==999998

*******************************************************


******************************************************************************
/*Dropping the States of Nevada, Hawaii & Alaska and Washington DC. 
*/ 

drop if stateicp==81|stateicp==82|stateicp==65|stateicp==98|stateicp==99
drop if region>=91
******************************************************************************


********************************************************
/* Generate two variables that record the mean years of schooling for  male and female 
* -- Male = "Mhgedu"
* -- Female =  "Fhgedu"
*/
gen hgedu=max(int(higraded/10)-3,0)

assert hgedu>=0 & hgedu<=20

gen Mhgedu=hgedu

replace Mhgedu=. if sex==2

gen Fhgedu=hgedu

replace Fhgedu=. if sex==1

********************************************************

*******************************************************************************
/*Generate a variable "aweight" for the sampling weights*
* perwt indicates how many persons in the U.S. population are represented
by a given person in an IPUMS sample.

*slwt is already defined above. Perwt is used as weight in 1940 and slwt for 1950
*/

gen aweight=perwt
replace aweight=slwt if year==1950
*******************************************************************************

********************************************************************************
/*Generage dummy variable "farmd" for whose occupation is farming for for period 
between 1940 - 1990
*/

gen byte farmd=.
replace farmd=(occ==098 | occ==099 | occ==844 | occ==866  |occ==888) if  year==1940
replace farmd=(occ==100 | occ==123 | occ==810 | occ==820  | occ==830 | occ==840) if year==1950
replace farmd= (occ==200 | occ==222 | occ==901 | occ==902  | occ==903  | occ==905) if year==1960
replace farmd=(occ>=801 & occ<=846) if year==1970
replace farmd=(occ>=473 & occ<=479) if year==1980
replace farmd=(occ>=473 & occ<=479) if year==1990
********************************************************************************


*********************************************************
/*Generate extra dummies:

* parttime - dummy if you work less than 35hrs per week
* NonWhite - dummy if you are not White
* White - dummmy if you White
* married - dummy if you are married */
* Parttime1 - parttime dummy for only year 1950
* NonWhite1 - dummy for non-white for only year 1950

gen byte parttime=(hrswork1<35)
gen byte NonWhite  = race!=1
gen byte White= 1-NonWhite
gen byte married = (marst<3)

gen Parttime1=parttime*(year==1950)
gen NonWhite1=NonWhite*(year==1950 )

*********************************************************

********************************************************************************
/* Generate a variable that sum "Femweeks" weighted weekly worked by the female
by state and year and replace it with its weighted mean 
*/

egen Femweeks=sum((sex==2)*wkswork1*aweight),by(stateicp year)
egen Femweight=sum((sex==2)*aweight),by(stateicp year)
replace Femweeks=Femweeks/Femweight
********************************************************************************


*********************************************************
/*Generate a variable "bp" for individual born in United States */

gen bp=bpl
replace bp=999 if (bpl>56)
*drop if bp==999
*********************************************************



********************************************************************************

/*Reclassifying birthplace of individuals born outside the united states into 
continent, sub-continent,except Japan and German*/

gen bplk=.
replace bplk=80 if (bpl>=400 & bpl<=499) /*"other europe"*/
replace bplk=81 if (bpl>=500 & bpl<=599) /*" other asian"*/
replace bplk=82 if bpl==453 /*"Germany"*/
replace bplk=83 if (bpl==434 | bpl==439) /*"Italy"*/
replace bplk=84 if bpl==501 /*"Japan"*/
replace bplk=85 if bpl==600 /*"Africa"*/
replace bplk=86 if (bpl>=200 & bpl<=300) /*"Latin America"*/

********************************************************************************


*********************************************************
/* Generate a variable "Edyrs"  for record the average education

NonWhite1Edyr - interact the non-white dummy in 1950 with average education */

gen Edyrs=max(int(higraded/10)-3,0)

gen NonWhite1Edyrs= NonWhite1*Edyrs

*********************************************************

*********************************************************
/* Generate variables for quartic in experience " Exp1 - Exp4"*/

gen Exp1=max(age-Edyrs-7,0)
gen Exp2=(Exp1^2)/100
gen Exp3=(Exp1^3)/1000
gen Exp4=(Exp1^4)/10000

*********************************************************
*Generating new variables for that record only experience in year 1950*

gen Exp11=Exp1*(year==1950)
gen Exp21=Exp2*(year==1950 )
gen Exp31=Exp3*(year==1950 )
gen Exp41=Exp4*(year==1950 )


******************************************************************************************************************
*Generate average of weeks worked from the intervalled weeks worked  (wkswork2)
generate wkswork3=6.5*(wkswork2==1) + 20*(wkswork2==2) + 33*(wkswork2==3)+ 43.5*(wkswork2==4) + 48.5*(wkswork2==5) + 51*(wkswork2==6)

*Replacing the missing values (1960 & 1970) in the weeks worked (wkswork1) with the computed week worked (wkswork3)
replace wkswork1=wkswork3 if missing(wkswork1)

*Generate average of hours worked from the intervalled hours worked  (hrsswork2)
generate hrswork3=7.5*(hrswork2==1) + 22*(hrswork2==2) + 32*(hrswork2==3)+ 37*(hrswork2==4) + 40*(hrswork2==5) + 44.5*(hrswork2==6) + 54*(hrswork2==7) + 70*(hrswork2==8) 

*Replacing the missing values (1960 & 1970) in the hours worked (hrswork1) with the computed hours worked (hrswork3)
replace hrswork1=hrswork3 if missing(hrswork1)


*********************************************************
/* The labor force force employed. Drop not in this category of 
"at work", "public emergency" and "has job but not working"*/

keep if empstatd>=10 & empstatd<=12

*********************************************************


*********************************************************
*drop unpaid family workers, Self-employed this year or no wagelyr last year*
drop if classwkrd==29
drop if (classwkrd>=10 & classwkrd<14)
*********************************************************


*********************************************************
*Drop individuals with zero worr  hours, missing or not reported, and zero earnings*

drop if hrswork1==0 | hrswork1>98
drop if incwage==0

*********************************************************


********************************************************************************
*Generate max wages for the top-codes and the the geneerating the CPI (BLS website)
gen mxwage = (year==1940)*5001 + (year==1950)*10000 + (year==1960)*25000
gen cpi = (year==1940)*0.14 + (year==1950)*0.235 + (year==1960)*0.293 + (year==1970)*0.373 + (year==1980)*0.81 + (year==1990)

*********************************************************
*Multiply the top-code income by 1.5
replace incwage=incwage*1.5 if incwage>=mxwage

*********************************************************

*********************************************************
*Full-time work dummy*
gen byte ftwrk = wkswork1>=40 & hrswork1>=35
replace ftwrk = wkswork1>=40 if year==1940

*********************************************************


********************************************************************************
/*Computation of weekly wages and removing self-employed individuals who earned 
$.5 - $250 in 1990 dollar amount and dropping out individual that show missing income*/

gen wkwage = incwage/wkswork1 if ftwrk
replace wkwage=. if !ftwrk & classwkrd ==14 & (wkwage > (.50*cpi*35) | wkwage < (250*cpi*35))
drop if missing(wkwage)

********************************************************************************


********************************************************************************

/*Computation of hours wages and removing self-employed individuals who earned 
$.5 - $250 in 1990 dollar amount and dropping out individual that show missing income.
Here, 1940 observations is considered as full-time and restriction of 35 hrs per 
is imposed week.*/

gen hrwage=incwage/(wkswork1*hrswork1)
replace hrwage=incwage/(wkswork1*35) if year==1940
drop if hrwage==.

gen hrwks=. if classwkrd ==14 & (hrwage > (.50*cpi) | hrwage < (250*cpi))
drop if missing(hrwage)

********************************************************************************


***********************************************************************
/*Generate two variables to record weeks worked by male - "mwrks" and 

female - "fwrks" */

gen mwrks=wkswork1

replace mwrks=. if sex==2

gen fwrks=wkswork1

replace fwrks=. if sex==1
***********************************************************************

*********************************************************
/* Generate two variables to record log of weekly wage and log of hour wage*/

gen lhrwage=ln(hrwage)
gen lwkwage=ln(wkwage)


*********************************************************

*********************************************************
/*Generate two variables to record log of hour wage for male and female

Male - mlhrwage
Female - flhrwage=

*/

gen mlhrwage=lhrwage*male
replace mlhrwage=. if mlhrwage==0 & female==1

gen flhrwage=lhrwage*female
replace flhrwage=. if flhrwage==0 & male==1
*********************************************************

*********************************************************
/*Generate two variables to record log of weekly wage for male and female

Male - mlwkwage
Female - flwkwage

*/

gen mlwkwage=lwkwage*male
replace mlwkwage=. if mlwkwage==0 & female==1

gen flwkwage=lwkwage*female
replace flwkwage=. if flwkwage==0 & male==1
*********************************************************

*********************************************************
/*Generate a variable to record log of weekly wage  female in 1959 dollar amount

Female - flwkwagek
*/

gen fwkwage=wkwage*female
replace fwkwage=. if fwkwage==0 & male==1

gen fwkwage1959= (fwkwage/29.4)*100
gen flwkwagek= ln(fwkwage1959)

********************************************************

**************************************************************************
/*Generate a variable "fdummy1950Edyrs" to record female average education 
interacted with th year 1950 dummy.
*/
gen dummy1950Edyrs=dummy1950*Edyrs

gen fdummy1950Edyrs=dummy1950*Edyrs
replace fdummy1950Edyrs=.  if sex==1

**************************************************************************

**************************************************************************
*Generate Weight for each state included in the sample for male and female

sort stateicp
egen mwpop=sum(aweight*male), by(stateicp)
egen fwpop=sum(aweight*female), by(stateicp)

**************************************************************************


************************************************************
* Save this data as IPUM14 to be used in the estimation
save "IPUM14", replace
*********************************************************





