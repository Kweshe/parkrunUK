clear all

import delimited "C:\Users\karlo\Documents\Ms Behavioral economics and data science\Programming and analytics for behabioural economist\Assignment\data&results\dataset.csv"

*****1.	Compare the overall demographic mix of the participants in terms of gender and age across different event locations. Are there important differences in the composition of participants at different events across Norfolk?    

* make two graphs for participation by gender: one showing the proportion of men and another showing the average of totalruns by gender
*Inconsistency in the database. Totalruns are sometimes higher in earlier years for a given person. Keep the max for each person
bysort key : egen total_runs=max(totalruns)

** Proportion of male per event location

gen gender_dummy = 1 if gender=="M"
replace gender_dummy = 0 if gender=="F"

sum gender_dummy

ttest gender_dummy == 0.49

*Let's keep one observation per participant for demographic analysis
duplicates drop key, force

bysort event: egen perc_male=mean(gender_dummy)

tabulate event gender

egen event_id = group(perc_male)
sort event_id
tab event perc_male


gen perc_49=0.49


*Construct confidence intervals for the percentage of male for each event

*declare 3 empty variables. 
gen sd=.
gen CI_Lower=.
gen CI_Upper=.
*declare the number of observations (unique participants) for each event location. 

bysort event_id: egen nobs=count(event_id) 


* Compute the confidence interval for each location using a loop 

forvalues i=1/11 {
	sum gender_dummy if event_id==`i'
	return list
	replace sd=r(sd) if event_id==`i'
	replace CI_Lower=perc_male-1.96*sd/sqrt(nobs)
	replace CI_Upper=perc_male+1.96*sd/sqrt(nobs)
}

duplicates drop event, force

twoway (bar perc_male event_id, barwidth(0.6) xlabel(1 "TE" 2 "BK" 3 "HK " 4 "BN" 5 "NR" 6 "MB" 7 "CT " 8 "KG" 9 "SG" 10 "FL" 11 "GL") ylabel(0 (0.2) 1) ytitle("% male") bcolor(ebg)) (bar perc_49 event_id,  barwidth(0.6) bcolor(eltblue)) (rcap CI_Upper CI_Lower event_id, color(gray)), name(participation1, replace)

*total run can can be use to appreciate particiation as well. Let's try with the mean of totalruns per gender and per  event location 
tab  event gender, sum(total_runs) nost nofreq
tab  agegroup gender

**For females
bys event : egen runs_F=mean(total_runs) if gender =="F"
bysort event : egen Female_avgruns=max(runs_F) 
format Female_avgruns %3.0fc

**For males
bys event : egen runs_M=mean(total_runs) if gender =="M"
bysort event : egen Male_avgruns=max(runs_M) 
format Male_avgruns %3.0fc
drop runs_M runs_F

egen event_location = group(Male_avgruns)
sort event_location


twoway (bar Male_avgruns event_location, barwidth(0.6) xlabel(1 "TE" 2 "BK" 3 "HK " 4 "BN" 5 "NR" 6 "MB" 7 "CT " 8 "KG" 9 "SG" 10 "FL" 11 "GL") ylabel(0 (5) 42) bcolor(ebg)) (bar Female_avgruns event_location,  barwidth(0.6) bcolor(eltblue)), name(participation2, replace)

gr combine participation1 participation2, col(1) iscale(0.5)

**Participation by age group

clear all

import delimited "C:\Users\karlo\Documents\Ms Behavioral economics and data science\Programming and analytics for behabioural economist\Assignment\data&results\dataset.csv"

**keep one observation per runner

duplicates drop key, force

drop if agegroup == "---"

** Generate a gender dummy
gen gender_dummy = 1 if gender=="M"
replace gender_dummy = 0 if gender=="F"

count if gender_dummy<=1// 43426 observations

tab agegroup

bys agegroup gender: egen totalparticipants=count(key)
gen perc_group=totalparticipants/43626
bys agegroup : egen totalfemale=count(key) if gender=="F"
bys agegroup : egen totalmale=count(key) if gender=="M"

gen propmale = (-totalmale/43626)*100
format propmale %3.1fc
gen propfemale = (totalfemale/43626)*100
format propfemale %3.1fc
list agegroup totalmale totalfemale

bysort agegroup : egen prop_female=max(propfemale) 
format prop_female %3.1fc
bysort agegroup : egen prop_male=max(propmale) 
format prop_male %3.1fc
drop propmale propfemale
duplicates drop agegroup, force

generate zero = 0
describe agegroup
encode agegroup, gen(age_group)

***Pyramid
twoway (bar prop_male age_group, horizontal barwidth(0.8) bcolor(ebg) xvarlab(Males)) (bar prop_female age_group, horizontal barwidth(0.8) bcolor(gray) xvarlab(Females)) sc age_group zero, mlabel(agegroup) mlabcolor(gs5) ytitle("Age group") plotregion(style(none)) ysca(noline) ylabel(none) xsca(noline titlegap(-3.5)) xlabel(-8 "8%" -6 "6%" -4 "4%" -2 "2%" 0 "0%" 8 "8%" 6 "6%" 4 "4%" 2 "2%", tlength(0) grid gmin gmax) legend(pos(5) ring(0) col(1) label(1 "Males") label(2 "Females")) legend(size(small)) legend(order(1 2)) title("Male and Female runners by age group")



tab agegroup
************************************************

**Q2: 2.	Compare average performance across months. Are there any seasonality effects in performance across the year?  


clear all
import delimited "C:\Users\karlo\Documents\Ms Behavioral economics and data science\Programming and analytics for behabioural economist\Assignment\data&results\dataset.csv"

***Change date format
describe date
gen date_v2 = date(date, "YMD")
format date_v2 %td

gen month=month(date_v2)

gen year=year(date_v2)

tab agegroup
**restrict the sample to work only with participants aged 15 to 44 years old

keep if agegroup == "15-17" | agegroup == "18-19" | agegroup == "20-24" | agegroup == "25-29" | agegroup == "30-34" | agegroup == "35-39" | agegroup == "40-44"
tab agegroup

*Two variables are used to map performance by month: time and the proportion of agegrade below 60%.

*****Proportion of performance that are under Local Class Level (agegrade<60): Dummy to classify performance

gen performance_dummy = 1 if agegrade<60
replace performance_dummy = 0 if agegrade>=60
bysort month: egen perc_below=mean(performance_dummy)
gen percbelow60=perc_below*100
format percbelow60 %3.1fc


*Construct confidence intervals for each month

*declare 3 empty variables. 
gen sd=.
gen CI_Lower=.
gen CI_Upper=.
*declare the number of observations (unique participants) for each event location. 
bysort month: egen nobs=count(month) 


* Compute the confidence interval for each location using a loop 

forvalues i=1/12 {
	sum performance_dummy if month==`i'
	return list
	replace sd=r(sd) if month==`i'
	replace CI_Lower=perc_below-1.96*sd/sqrt(nobs)
	replace CI_Upper=perc_below+1.96*sd/sqrt(nobs)
}

**** Prepare data for the "time againts month" graph

*generate numeric id for each participant that starts at 1
egen id_runners=group(key)
sort id_runners

*** Format time/ First group MM:SS second group HH:MM:SS. Format each separatly then combine
describe time
gen duration1 = clock(time, "ms")
format duration1 %tcHH:MM:SS

gen duration2 = clock(time, "hms")
format duration2 %tcHH:MM:SS
replace duration1 = duration2 if missing(duration1)
drop duration2

*generate average time per participant and per month

bys id_runners month: egen avgtime=mean(duration1)
format avgtime %tcHH:MM:SS

duplicates drop id_runners, force

*global
bys month: egen avgtimeglobal=mean(duration1) 
format avgtimeglobal %tcMM:SS

**For female
bys month : egen time_F=mean(duration1) if gender =="F"
format time_F %tcHH:MM:SS
bysort month : egen meantime_Female=max(time_F) 
format meantime_Female %tcMM:SS

**for male
bys month : egen time_M=mean(duration1) if gender =="M"
format time_M %tcMM:SS
bysort month : egen meantime_Male=max(time_M)
format meantime_Male %tcMM:SS
drop time_F time_M
duplicates drop month, force

*plot average time by months and gender

twoway (scatter meantime_Female month, connect(l) lwidth(medium) msymbol(smcircle) msize(large) lcolor(ebg) mcolor(ebg) lpattern(dash) xlabel(1 "Jan" 2 "Feb" 3 "Mar" 4 "Apr" 5 "May" 6 "June" 7 "July" 8 "Aug" 9 "Sep" 10 "Oct" 11 "Nov" 12 "Dec")) (scatter meantime_Male month, connect(l) msymbol(smcircle) lcolor(navy) mcolor(navy) lwidth(medium) msize(large) lpattern(dash)) (scatter avgtimeglobal month, connect(l) msymbol(o) lcolor(gs11) mcolor(gs11) lwidth(medium) msize(large)), title("Performance by gender") ytitle("time") name(performance1, replace)

** Plot proportion of agegrade below 60% per month
twoway (bar perc_below month, barwidth(0.4) xlabel(1 "Jan" 2 "Feb" 3 "Mar" 4 "Apr" 5 "May" 6 "June" 7 "July" 8 "Aug" 9 "Sep" 10 "Oct" 11 "Nov" 12 "Dec") ylabel(0(0.1)0.8) bcolor(eltblue)) (rcap CI_Upper CI_Lower month, color(gray)), title("Proportion of agegrade below Local class level")  name(performance2, replace)


gr combine performance1 performance2, col(2) iscale(0.5)


*****************************************************************************************************************************************************************************************************************************************************************************************
*******
* model: You will need to think carefully about how to account for the fact that the same individuals appear in the data more than once

clear all
import delimited "C:\Users\karlo\Documents\Ms Behavioral economics and data science\Programming and analytics for behabioural economist\Assignment\data&results\dataset.csv"

***Change date format
gen date_v2 = date(date, "YMD")
format date_v2 %td

gen month=month(date_v2)

gen year=year(date_v2)

**restrict the sample to work only with participants aged 15 to 44 years old

keep if agegroup == "15-17" | agegroup == "18-19" | agegroup == "20-24" | agegroup == "25-29" | agegroup == "30-34" | agegroup == "35-39" | agegroup == "40-44"
tab agegroup

*** Format time: Convert to seconds

gen duration1 = clock(time, "ms")
format duration1 %tcHH:MM:SS

gen duration2 = clock(time, "hms")
format duration2 %tcHH:MM:SS

replace duration1 = duration2 if missing(duration1)
drop duration2 club note group genderrank 

gen hours = hhC(duration1)
gen minutes = mmC(duration1)
gen seconds = ssC(duration1)
gen totsecs = 3600*hours + 60*minutes + seconds

sum totsecs, det
sum duration1, det
mean totsecs
tab month, stat (mean totsecs)

**********
*generate numeric id for each participant starting with 1 
egen id_runners=group(key)
sort id_runners
describe key
describe id_runners

*dummies for event location and month of the year
egen id_event=group(event)
tab year, generate(y)
tab month, gen(m)
ssc install outreg2

table month event, stat (mean totsecs)


*a regression with absorbed fixed effects

areg totsecs i.month i.id_event, a(id_runners) robust

****Model 1: 
areg totsecs i.month, a(id_runners)
outreg2 using "C:\Users\karlo\Documents\Ms Behavioral economics and data science\Programming and analytics for behabioural economist\Assignment\data&results\Table_assignment.rtf", ctitle("Model 1") dec(3) replace keep(2.month 3.month 4.month 5.month 6.month 7.month 8.month 9.month 10.month 11.month 12.month)

testparm i.month
areg, coefleg


****Model 2: Control for location and age group
** Let's convert agegroup into a numerical variable with encode

encode agegroup, gen(age)

areg totsecs i.month i.id_event i.age, a(id_runners)
outreg2 using "C:\Users\karlo\Documents\Ms Behavioral economics and data science\Programming and analytics for behabioural economist\Assignment\data&results\Table_assignment.rtf", ctitle("Model 2") dec(3) append keep(1.month 2.month 3.month 4.month 5.month 6.month 7.month 8.month 9.month 10.month 11.month 12.month)

testparm i.id_event
testparm i.age
testparm i.month

**robust standard error, control for heteroskedasticity

areg totsecs i.month i.id_event i.age, a(id_runners) robust
outreg2 using "C:\Users\karlo\Documents\Ms Behavioral economics and data science\Programming and analytics for behabioural economist\Assignment\data&results\Table_assignment.rtf", ctitle("Model 2 robust") dec(3) append keep(1.month 2.month 3.month 4.month 5.month 6.month 7.month 8.month 9.month 10.month 11.month 12.month)

tab event


****3.	Do the performance data suggest reference-dependent behaviour?  For example, are participants more likely to finish just under a full-minute time (e.g. 23:50-23:59 compared to 24:00-24:09)? Do males show more refence-dependent behaviour than females?

***Histogram

sum duration1
hist duration1, percent bin(50)

hist duration1, freq bin(70) barwidth(0.2) color(ltblue) name(hist1) xlabel(0(10)60

hist duration1, freq bin(100) barwidth(0.1) color(ltblue) xline(1440000)

hist duration1, freq bin(100) barwidth(0.1) color(ltblue) name(hist3) xline(1440000)

*** Delete extreme values
keep if totsecs <= 3000
***1344 observations deleted
format duration1 %tcMM:SS

sum duration1


twoway (hist duration1 if gender=="M", freq bin(180) barwidth(0.01) color(ltblue) xline(1200000(60000)1980000) xtitle("Time, red lines indicate one-minut increments from 20 to 33 minutes")) (hist duration1 if gender=="F", freq bin(180) barwidth(0.01) color(gs13) xline(1440000)), title(Distribution of finishing time by gender) legend(order(1 "Male" 2 "Female")) name(Distrib2, replace)

hist duration1, freq bin(180) barwidth(0.01) color(ebg) xline(1200000(60000)1980000) xtitle("Time, red lines indicate one-minut increments from 20 to 33 minutes") title(Distribution of finishing time) name(Distrib1, replace)


gr combine Distrib1 Distrib2, col(1) iscale(0.5)

***Model bunching 10 seconds before and after round time

sum minutes


**From 14 to 50 minutes//bunching region: 10 seconds before i // 10 seconds after i 

forvalues i=14/50 {
gen bunching`i' = 1 if minutes==`i'  & duration1>= ((`i'*60000)+(50000)) & duration1<= ((`i'+1)*60000)
replace bunching`i' = 1 if minutes==`i' & duration1> ((`i')*60000) & duration1<= ((`i')*60000)+(10000)
replace bunching`i' = 1 if minutes==`i' & duration1 == ((`i')*60000)
replace bunching`i' = 0 if bunching`i' ==.
}

egen bunchings=rowtotal(bunching*)


forvalues i=14/50 {
	drop bunching`i'
}

sum bunchings

*Create a new categorical variable for which each category represents a sub-interval of time that goes from 50 seconds before round minute and 10 seconds after
forvalues i=14/50 {
gen interval`i' = `i'+1  if minutes==`i'  & duration1> ((`i'*60000)+(10000)) & duration1<= ((`i'+1)*60000)
replace interval`i' = `i'  if minutes==`i' & duration1> ((`i')*60000) & duration1<= ((`i')*60000)+(10000)
replace interval`i' = `i'  if minutes==`i' & duration1 == ((`i')*60000)
} 

****Group all sub-ranges in one column
egen clusters=rowtotal(interval*)

forvalues i=14/50 {
	drop interval`i'
}

tab  clusters gender, sum(bunchings) nost nofreq

** Generate a gender dummy
gen gender_dummy = 1 if gender=="M"
replace gender_dummy = 0 if gender=="F"

******Logistic regression bunchings on gender
logit bunchings gender_dummy
outreg2 using "C:\Users\karlo\Documents\Ms Behavioral economics and data science\Programming and analytics for behabioural economist\Assignment\data&results\Table_assignment5.rtf", ctitle("Model 1") dec(3) replace
***marginal effect of gender /outreg2 does not work for margins/Added manually
margins, dydx(gender_dummy ) 
outreg2 using "C:\Users\karlo\Documents\Ms Behavioral economics and data science\Programming and analytics for behabioural economist\Assignment\data&results\Table_assignment5.rtf", ctitle("Marginal effect") dec(3) append

****intercept
di exp(-0.6177218)/(1+exp(-0.6177218))

***************Around which exact time we have evidence of bunching?
*Number of finishing time in each clusters

bysort clusters: egen finishers=count(clusters) 

** proportion of finishing time around round minute for each cluster
bysort clusters: egen perc_bunch=mean(bunchings)
format perc_bunch %3.2fc

***** Excess finishers/ For each cluster which represents an exact time, diff betwenn one third and proportion of finishers in the bunching region

gen perc_excess =  perc_bunch - 0.3333333
format perc_excess %3.2fc

***
gen excess = 1 if perc_excess > 0
replace excess = 0 if perc_excess <= 0

sum excess


******
*** Test if mean bunchings is significantly diff from zero Ha: mean > 0.33
ttest bunchings = 0.33
********
ttest bunchings = 0.33 if clusters == 15 
ttest bunchings = 0.33 if clusters == 16
ttest bunchings = 0.33 if clusters == 17
ttest bunchings = 0.33 if clusters == 18
ttest bunchings = 0.33 if clusters == 19
ttest bunchings = 0.33 if clusters == 20
ttest bunchings = 0.33 if clusters == 21
ttest bunchings = 0.33 if clusters == 22
ttest bunchings = 0.33 if clusters == 23
ttest bunchings = 0.33 if clusters == 24
ttest bunchings = 0.33 if clusters == 25
ttest bunchings = 0.33 if clusters == 26
ttest bunchings = 0.33 if clusters == 27
ttest bunchings = 0.33 if clusters == 28
ttest bunchings = 0.33 if clusters == 29
ttest bunchings = 0.33 if clusters == 30
ttest bunchings = 0.33 if clusters == 31
ttest bunchings = 0.33 if clusters == 32
ttest bunchings = 0.33 if clusters == 33
ttest bunchings = 0.33 if clusters == 34
ttest bunchings = 0.33 if clusters == 35
ttest bunchings = 0.33 if clusters == 36
ttest bunchings = 0.33 if clusters == 37
ttest bunchings = 0.33 if clusters == 38
ttest bunchings = 0.33 if clusters == 39
ttest bunchings = 0.33 if clusters == 40
ttest bunchings = 0.33 if clusters == 41
ttest bunchings = 0.33 if clusters == 42
ttest bunchings = 0.33 if clusters == 43
ttest bunchings = 0.33 if clusters == 44
ttest bunchings = 0.33 if clusters == 45
ttest bunchings = 0.33 if clusters == 46
ttest bunchings = 0.33 if clusters == 47
ttest bunchings = 0.33 if clusters == 48
ttest bunchings = 0.33 if clusters == 49
ttest bunchings = 0.33 if clusters == 50


******************
*** Identifiy significant bunching for males

ttest bunchings = 0.33 if clusters == 15 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 16 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 17 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 18 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 19 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 20 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 21 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 22 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 23 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 24 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 25 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 26 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 27 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 28 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 29 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 30 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 31 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 32 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 33 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 34 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 35 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 36 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 37 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 38 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 39 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 40 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 41 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 42 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 43 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 44 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 45 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 46 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 47 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 48 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 49 & gender_dummy == 1
ttest bunchings = 0.33 if clusters == 50 & gender_dummy == 1

*********************************************************
*** Identifiy significant bunching for females

ttest bunchings = 0.33 if clusters == 15 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 16 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 17 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 18 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 19 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 20 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 21 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 22 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 23 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 24 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 25 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 26 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 27 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 28 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 29 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 30 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 31 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 32 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 33 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 34 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 35 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 36 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 37 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 38 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 39 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 40 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 41 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 42 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 43 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 44 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 45 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 46 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 47 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 48 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 49 & gender_dummy == 0
ttest bunchings = 0.33 if clusters == 50 & gender_dummy == 0


******************************
*Construct confidence intervals for each cluster

gen sd=.
gen CI_Lower=.
gen CI_Upper=.

* Compute the confidence interval for each location using a loop 

forvalues i=14/50 {
	sum bunchings if clusters==`i'
	return list
	replace sd=r(sd) if clusters==`i'
	replace CI_Lower=perc_bunch-1.96*sd/sqrt(finishers)
	replace CI_Upper=perc_bunch+1.96*sd/sqrt(finishers)
}

**** Table: Keep on observation for each cluster of finishing time

duplicates drop clusters, force

tab  minutes gender, sum(bunchings) nost nofreq

list clusters finishers perc_bunch perc_excess







