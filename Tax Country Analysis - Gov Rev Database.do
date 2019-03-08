clear all

*cd "C:\Users\wb305167\OneDrive - WBG\Research"

use "Government Revenue Dataset - augmented", clear
sort Country_Code year

drop if year<1990
* removing outliers
foreach u in Total_Revenue_incl_SC Tax_Revenue_incl_SC Tax_Revenue Income_Taxes Value_Added_Tax Excise_Taxes Trade_Taxes { 
replace `u'=. if `u' > `u'_99 & `u'!=.
replace `u'=. if `u' < `u'_01 & `u'!=.
}


*Define Countries Region and neighbours

local v="ARG"
local w="Argentina"
local x="LAC"
local a = "BRA"
local a1 = "Brazil"
local b = "CHL"
local b1 = "Chile"
local c = "PER"
local c1 = "Peru"
local d = "COL"
local d1 = "Colombia"

graph bar Income_Taxes Property_Tax Value_Added_Tax Excise_Taxes Trade_Taxes Social_Contributions Other_Taxes if Country_Code=="`v'", over(year, relabel(1 "1990" 2 " " 3 " " 4 " " 5 " " 6 "1995" 7 " " 8 " " 9 " " 10 " " 11 "2000" 12 " " 13 " " 14 " " 15 " " 16 "2005" 17 " " 18 " " 19 " " 20 " " 21 "2010" 22 " " 23 " " 24 " " 25 " " 26 " " 27 "2016" 28 " ")) legend(label(1 "Income Taxes")  label(2 "Property Tax") label(3 "VAT") label(4 "Excise Taxes") label(5 "Taxes on Intl. Trade") label(6 "Social Contributions") label(7 "Other Taxes")) ylabel(5(5)35) ytitle("% of GDP") title("`w': Tax Structure") stack
graph save "`w' Tax Structure over Time", replace  
graph export "`w' Tax Structure over Time.png", replace


graph bar Tax_Revenue Social_Contributions if Country_Code=="`v'", over(year, relabel(1 "1990" 2 " " 3 " " 4 " " 5 " " 6 "1995" 7 " " 8 " " 9 " " 10 " " 11 "2000" 12 " " 13 " " 14 " " 15 " " 16 "2005" 17 " " 18 " " 19 " " 20 " " 21 "2010" 22 " " 23 " " 24 " " 25 " " 26 " " 27 "2016")) legend(label(1 "Tax Revenue") label(2 "Social Contributions")) ylabel(5(5)35) ytitle("% of GDP") title("`w': Tax Revenue and Social Contributions") stack
graph save "`w' Tax Revenue and Social Contributions", replace  
graph export "`w' Tax Revenue and Social Contributions.png", replace


*timeseries Charts Tax_Revenue for regions

egen wbregionyr = group(Region_Code year)
egen meantax2 = mean(Tax_Revenue), by(wbregionyr) 
label var meantax2 "Tax_Revenue-GDP ratio (%)"

egen oil_gasyr = group(Oil_Gas_Rich year)
egen meantax4 = mean(Total_Revenue_incl_SC), by(oil_gasyr) 
label var meantax4 "Total_Revenue_incl_SC-GDP ratio (%)"

gen Region_Code1=Region_Code
replace Region_Code1="`w'" if Country_Code=="`v'"
egen wbregion1yr = group(Region_Code1 year)
egen meantax3 = mean(Tax_Revenue_incl_SC), by(wbregion1yr) 
label var meantax3 "Tax Revenue incl. SC (% of GDP)"

gen Oil_Gas_Rich1=Oil_Gas_Rich
replace Oil_Gas_Rich1="`v'" if Country_Code=="`v'"

egen oil_gas1yr = group(Oil_Gas_Rich1 year)
egen meantax5 = mean(Total_Revenue_incl_SC), by(oil_gas1yr) 
label var meantax5 "Total Revenue incl SC (% of GDP)"

sort Region_Code year
sepscatter meantax3 year if year<=2016, separate(Region_Code1) recast(connect) missing  title("Tax Revenue Collection: `w' vs Regions")
graph save "`w' Tax Revenue and Social Contributions vs Regions", replace  
graph export "`w' Tax Revenue and Social Contributions vs Regions.png", replace

sort Oil_Gas_Rich1 year
sepscatter meantax5 year if year<=2016, separate(Oil_Gas_Rich1) recast(connect) missing legend (lab(1 "NOT - Oil & Gas Rich") lab(2 "Oil & Gas Rich")) ylabel(15(5)35) title("Total Revenue Collection - Oil Gas Rich vs. Others")
graph save "`w' Total Revenue Oil versus Non-Oil", replace  
graph export "`w' Total Revenue Oil versus Non-Oil.png", replace


*** Tax Collection - all countries
table year Region_Code if year>=2000, c(mean Tax_Revenue_incl_SC ) f(%5.2f) column

egen meantax = mean(Tax_Revenue), by(year)
label var meantax "Overall Taxes"
egen meantaxIncome_Taxes = mean(Income_Taxes), by(year)
label var meantaxIncome_Taxes "PIT/CIT"
egen meantaxcorp = mean(CIT), by(year)
label var meantaxcorp "CIT"
egen meantaxindv = mean(PIT), by(year)
label var meantaxindv "PIT"
egen meantaxpropr = mean(Property_Tax), by(year)
label var meantaxpropr "Property Tax"
egen meantaxvat = mean(Value_Added_Tax), by(year)
label var meantaxvat "VAT"
egen meantaxexcises = mean(Excise_Taxes), by(year)
label var meantaxexcises "Excises"
egen meantaxtrade = mean(Trade_Taxes), by(year)
label var meantaxtrade "Trade Taxes"
egen meantaxother_tax = mean(Other_Taxes), by(year)
label var meantaxother_tax "Other Taxes"

sort year
*twoway (connected meantaxindv meantaxcorp meantaxpropr meantaxvat meantaxexcises meantaxtrade meantaxother_tax year if year<=2016 , yaxis(1) msymbol(Oh S T + - x) ytitle("% of GDP") ) (connected meantax year if year<=2016, yaxis(2) msymbol(o) title("Tax Structure over time"))
*without total tax
twoway (connected meantaxindv meantaxcorp meantaxpropr meantaxvat meantaxexcises meantaxtrade meantaxother_tax year if year<=2016 , yaxis(1) msymbol(Oh S T + - x) ytitle("% of GDP") title("Performance of Different Tax Types (World)"))
graph save "World - Performance of Different Taxes", replace  
graph export "World - Performance of Different Taxes.png", replace

*CIT 
twoway (connected meantaxcorp year if year<=2016 , msymbol(O) ylabel(0(1.0)5.0) ytitle("% of GDP") title("World: CIT collection over time"))
graph save "World - Performance of Corporate Income Tax", replace  
graph export "World - Performance of Corporate Income Tax.png", replace

*Country versus Region
sort Region_Code1 year
twoway (connected meantax3 year if year<=2016 & Region_Code1=="`x'", msymbol(Oh))(connected Tax_Revenue year if year<=2016 & Country_Code=="`v'"), legend(lab(1 "`x': Tax Revenue and SC") lab(2 "`w': Tax Revenue and SC")) ylabel(8(2)30) ytitle("% of GDP") title("`w' vs. `x' - Comparing Tax Collection")
graph save "`w' vs. `x' - Tax Revenue incl. Social Contributions", replace  
graph export "`w' vs. `x' - Tax Revenue incl. Social Contributions.png", replace

*Country versus Region - Taxes
gen Region_Code2=Region_Code
replace Region_Code2="`w'" if Country_Code=="`v'"
egen wbregion2yr = group(Region_Code2 year)
egen meantaxinc2 = mean(Income_Taxes), by(wbregion2yr)
egen meantaxpropr2 = mean(Property_Tax), by(wbregion2yr)
egen meantaxvat2 = mean(Value_Added_Tax), by(wbregion2yr)
egen meantaxexcises2 = mean(Excise_Taxes), by(wbregion2yr)
egen meantaxtrade2 = mean(Trade_Taxes), by(wbregion2yr)
egen meantaxother_tax2 = mean(Other_Taxes), by(wbregion2yr)
sort Region_Code2 year

*Country versus Neighbours - Taxes

twoway (connected Tax_Revenue_incl_SC year if Country_Code=="`v'", msymbol(O) ///
legend(label(1 "`w'") label(2 "`a1'") label(3 "`b1'") label(4 "`c1'") ///
label(5 "`d1'")) ylabel(5(5)40, format(%5.0f)) ytitle("% of GDP") ///
title("`v' versus neighbours: Tax Revenue over time")) ///
(connected Tax_Revenue_incl_SC year if Country_Code=="`a'", msymbol(Oh)) ///
(connected Tax_Revenue_incl_SC year if Country_Code=="`b'", msymbol(S)) ///
(connected Tax_Revenue_incl_SC year if Country_Code=="`c'", msymbol(T)) ///
(connected Tax_Revenue_incl_SC year if Country_Code=="`d'", msymbol(+))
graph save "`w' Tax Revenue vs. Neighbors", replace  
graph export "`w' Tax Revenue vs. Neighbors.png", replace

**************

graph bar meantaxinc2  meantaxvat2 meantaxexcises2 meantaxtrade2 meantaxother_tax2 meantaxpropr2 if (year==2016 & Region_Code2=="`x'")| (year==2016 & Region_Code2=="`w'"), over(Region_Code2, relabel(1 "`w'" 2 "`x'")) ytitle("% of GDP") title(" Tax Collection by Tax Type - `w' versus `x'")  legend(label(1 "Income Tax")  label(2 "VAT") label(3 "Excise Tax") label(4 "Trade Taxes") label(5 "Other Taxes") label(6 "Property Tax"))
graph save "`w' Tax Revenue Structure versus `x'", replace  
graph export "`w' Tax Revenue Structure versus `x'.png", replace


*** Tax Potential based on average performance

*Tax versus Income - all countries tax versus Income
*showing 2016 data

twoway (scatter Tax_Revenue ln_GDP_PC if year==2016, mlabsize(vsmall) mlabel(Country_Code)) (scatter Tax_Revenue ln_GDP_PC if year==2016 & Country_Code=="`v'", mcolor(red)) (lfit Tax_Revenue ln_GDP_PC if year==2016), graphregion(color(white)) bgcolor(white) ylabel(, nogrid) ytitle("Tax Revenues (% of GDP), 2016") xtitle("Log GDP per capita, 2016") title("Level of Income and Tax Revenues") legend(off)
graph save "`w' Tax Revenue and Income incl resource rich", replace  
graph export "`w' Tax Revenue and Income incl resource rich.png", replace

*Tax versus Income - all countries except resource rich and removing outlier Denmark
*showing 2016 data

*gen Custom_Country_Code1=Country_Code
gen Custom_Country_Code=Country_Code
replace Custom_Country_Code="`v' 2000" if year==2000 & Country_Code=="`v'"
replace Custom_Country_Code="`v' 2005" if year==2005 & Country_Code=="`v'"
replace Custom_Country_Code="`v' 2010" if year==2010 & Country_Code=="`v'"
replace Custom_Country_Code="`v' 2016" if year==2016 & Country_Code=="`v'"
*
*twoway (scatter Tax_Revenue ln_GDP_PC if year==2016 & res_dum==0 & Country_Code!="DNK", mlabsize(vsmall) mlabel(Custom_Country_Code)) (scatter Tax_Revenue ln_GDP_PC if year==2010 & Country_Code=="`v'", mcolor(red) mlabel(Custom_Country_Code) mlabcolor(red) mlabsize(vsmall)) 
twoway (scatter Tax_Revenue_incl_SC ln_GDP_PC if year==2016 & res_dum==0, mcolor(gs10) mlabel(Country_Code) mlabsize(vsmall) mlabcolor(gs10))(scatter Tax_Revenue ln_GDP_PC if year==2000 & Country_Code=="`v'", mlabel(Custom_Country_Code) mcolor(black) mlabcolor(black) mlabsize(vsmall)) (scatter Tax_Revenue ln_GDP_PC if year==2005 & Country_Code=="`v'", mlabel(Custom_Country_Code) mcolor(black) mlabcolor(black) mlabsize(vsmall)) (scatter Tax_Revenue ln_GDP_PC if year==2010 & Country_Code=="`v'", mlabel(Custom_Country_Code) mcolor(black) mlabcolor(black) mlabsize(vsmall)) (scatter Tax_Revenue ln_GDP_PC if year==2016 & Country_Code=="`v'", mlabel(Custom_Country_Code) mcolor(black) mlabcolor(black) mlabsize(vsmall)) (lfit Tax_Revenue ln_GDP_PC if year==2016 & res_dum==0), graphregion(color(white)) bgcolor(white) ylabel(, nogrid) ytitle("Tax Revenue (% of GDP), 2016") xtitle("Log GDP per capita, 2016") title("Level of Income and Tax Revenues (Non-Resource Rich)") legend(off)
graph save "`w' Tax Revenue incl SC as compared with its Per Capita Income", replace  
graph export "`w' Tax Revenue incl SC as compared with its Per Capita Income.png", replace

twoway (scatter Tax_Revenue ln_GDP_PC if year==2016 & Tax_Revenue!=0 & res_dum==0, mlabsize(vsmall) mlabel(Country_Code)) (scatter Tax_Revenue ln_GDP_PC if year==2016 & Country_Code=="`v'", mcolor(red) mlabel(Country_Code) mlabcolor(red) mlabsize(vsmall)) (lfit Tax_Revenue ln_GDP_PC if year==2016 & res_dum==0), graphregion(color(white)) bgcolor(white) ylabel(, nogrid) ytitle("Tax Revenue (% of GDP), 2016") xtitle("Log GDP per capita, 2016") title("Level of Income and Tax Revenues") legend(off)
graph save "`w' Tax Revenue as compared with its Per Capita Income", replace  
graph export "`w' Tax Revenue as compared with its Per Capita Income.png", replace

twoway (scatter Income_Taxes ln_GDP_PC if year==2016 & Income_Taxes!=0 & res_dum==0, mlabsize(vsmall) mlabel(Country_Code)) (scatter Income_Taxes ln_GDP_PC if year==2016 & Country_Code=="`v'", mcolor(red) mlabel(Country_Code) mlabcolor(red) mlabsize(vsmall)) (qfit Income_Taxes ln_GDP_PC if year==2016 & res_dum==0), graphregion(color(white)) bgcolor(white) ylabel(, nogrid) ytitle("Income Tax Revenue (% of GDP), 2016") xtitle("Log GDP per capita, 2016") title("Level of Income and Income Tax Revenues") legend(off)
graph save "`w' Income Tax Revenue as compared with its Per Capita Income", replace  
graph export "`w' Income Tax Revenue as compared with its Per Capita Income.png", replace

twoway (scatter Value_Added_Tax ln_GDP_PC if year==2016 & Value_Added_Tax!=0 & res_dum==0, mlabsize(vsmall) mlabel(Country_Code)) (scatter Value_Added_Tax ln_GDP_PC if year==2016 & Country_Code=="`v'", mcolor(red) mlabel(Country_Code) mlabcolor(red) mlabsize(vsmall)) (lfit Value_Added_Tax ln_GDP_PC if year==2016 & res_dum==0), graphregion(color(white)) bgcolor(white) ylabel(, nogrid) ytitle("VAT Revenue (% of GDP), 2016") xtitle("Log GDP per capita, 2016") title("Level of Income and VAT Revenues") legend(off)
graph save "`w' VAT Revenue as compared with its Per Capita Income", replace  
graph export "`w' VAT Revenue as compared with its Per Capita Income.png", replace

twoway (scatter Trade_Taxes ln_GDP_PC if year==2016 & Trade_Taxes!=0 & res_dum==0, mlabsize(vsmall) mlabel(Country_Code)) (scatter Trade_Taxes ln_GDP_PC if year==2016 & Country_Code=="`v'", mcolor(red) mlabel(Country_Code) mlabcolor(red) mlabsize(vsmall)) (lfit Trade_Taxes ln_GDP_PC if year==2016 & res_dum==0), graphregion(color(white)) bgcolor(white) ylabel(, nogrid) ytitle("Trade Revenue (% of GDP), 2016") xtitle("Log GDP per capita, 2016") title("Level of Income and Trade Taxes") legend(off)
graph save "`w' Trade Taxes Revenue as compared with its Per Capita Income", replace  
graph export "`w' Trade Taxes Revenue as compared with its Per Capita Income.png", replace


*importing agriculture dataset see reshape data do file

merge 1:m Country_Code year using "Agriculture value added WDI Oct 2017 - percent of GDP"
drop if _merge !=3
drop _merge

*drop if Country_Code=="LSO"
twoway (scatter Tax_Revenue agri_share if year==2016 & Country_Code!="DNK", mlabsize(vsmall) mlabel(Country_Code)) (scatter Tax_Revenue agri_share if year==2016 & Country_Code=="`v'", mcolor(red)) (qfit Tax_Revenue agri_share if year==2016), graphregion(color(white)) bgcolor(white) ylabel(, nogrid) ytitle("Tax Revenues (% of GDP), 2016") xtitle("Agriculture Value Added (% of GDP), 2016") title("Level of Income and Tax Revenues") legend(off)

merge 1:m Country_Code year using "Polity Dataset Democracy"
drop if _merge !=3
drop _merge

twoway (scatter Tax_Revenue democracy if year==2015, mlabsize(vsmall) mlabel(Country_Code)) (scatter Tax_Revenue democracy if year==2015 & Country_Code=="`v'", mcolor(red)) (lfit Tax_Revenue democracy if year==2015), graphregion(color(white)) bgcolor(white) ylabel(, nogrid) ytitle("Tax Revenues (% of GDP), 2015") xtitle("Democracy Index, 2015") title("Level of Income and Tax Revenues") legend(off)

/*
merge 1:m Country_Code year using "GDP Current USD - March 2017"
drop if _merge !=3
drop _merge
gen ln_GDP = ln(GDP)
label var ln_GDP "Log of GDP Current USD"

merge 1:m Country_Code year using "Population WDI - 2017-Oct Query"
drop if _merge !=3
drop _merge
gen pop_mill = population/1000000

merge 1:m Country_Code year using "Trade percent of GDP WDI - 2017-Oct Query"
drop if _merge !=3
drop _merge
*/



*merging IMF WEO database

*ren GDP_Per_Capita_Current_USD GDP_Per_Capita


*regressions and adjusting for other variables

*reg Tax_Revenue GDP_Per_Capita agri_share democracy res_dum ln_GDP pop_mill if year>=1990

reg Tax_Revenue GDP_PC agri_share democracy res_dum if year>=1990
rvfplot, yline(0)
predict Predicted_Tax_Revenue

list Tax_Revenue Predicted_Tax_Revenue if year==2016 & Country_Code=="`v'"

gen GDP_PC2 = GDP_PC^2

*twoway (scatter Income_Taxes GDP_Per_Capita if year>=1990, mlabel(Country_Code)) (qfit Income_Taxes GDP_Per_Capita if year>=1990)
reg Income_Taxes GDP_PC GDP_PC2 agri_share democracy res_dum if year>=1990 & Country_Code!="DNK" & Country_Code!="DZA"
rvfplot, yline(0)
predict Predicted_Income_Tax_Revenue

list Income_Taxes Predicted_Income_Tax_Revenue if year==2015 & Country_Code=="`v'"

*reg Value_Added_Tax GDP_Per_Capita_Current_USD agri_share democracy res_dum if year>=1990
reg Value_Added_Tax GDP_PC GDP_PC2 agri_share democracy res_dum if year>=1990 & Country_Code!="LBR" & Country_Code!="DZA" & Country_Code!="BLR"
rvfplot, yline(0) mlabel(Country_Code)
predict Predicted_VAT

list Value_Added_Tax Predicted_VAT if year==2015 & Country_Code=="`v'"

*twoway (scatter Trade_Taxes GDP_Per_Capita if year>=1990, mlabel(Country_Code)) (qfit Trade_Taxes GDP_Per_Capita if year>=1990)
reg Trade_Taxes GDP_PC GDP_PC2 agri_share democracy if year>=1990 & Country_Code!="SWZ" & Country_Code!="LBR" & Country_Code!="NAM" & Country_Code!="BWA" & Country_Code!="BIH" & Country_Code!="RUS"
rvfplot, yline(0) mlabel(Country_Code)
predict Predicted_Trade_Taxes

list Trade_Taxes Predicted_Trade_Taxes if year==2015 & Country_Code=="`v'"

*twoway (scatter Excise_Taxes GDP_Per_Capita if year>=1990, mlabel(Country_Code)) (qfit Trade_Taxes GDP_Per_Capita if year>=1990)
reg Excise_Taxes GDP_PC GDP_PC2  agri_share res_dum if year>=1990 & Country_Code!="DZA" & Country_Code!="BOL" & Country_Code!="BGR"
rvfplot, yline(0) mlabel(Country_Code)
predict Predicted_Excise_Taxes

list Excise_Taxes Predicted_Excise_Taxes if year==2015 & Country_Code=="`v'"

/*
reg Tax_Revenue ln_GDP_PC democracy res_dum if year==2016
reg Tax_Revenue res_dum democracy if year==2016
predict resid_tax, residuals
reg ln_GDP_PC res_dum democracy if year==2016
predict resid_lngdp, residuals
twoway (scatter resid_tax resid_lngdp if year==2016, mlabsize(vsmall) mlabel(Country_Code)) (scatter resid_tax resid_lngdp if year==2016 & Country_Code=="`v'", mcolor(red)) (lfit resid_tax resid_lngdp if year==2016), graphregion(color(white)) bgcolor(white) ylabel(, nogrid) ytitle("Tax Revenues (% of GDP), 2016", size (small)) xtitle("Log GDP per capita adjusted for democracy and resources, 2016", size (small)) title("Tax Revenues and Level of Income adjusted", size (small)) legend(off)

*avplot ln_GDP_PC, mlabsize(vsmall) mlabel(Country_Code) graphregion(color(white)) bgcolor(white) ylabel(, nogrid) ytitle("Tax Revenues (% of GDP), 2016") xtitle("Log GDP per capita, 2016") title("AVPLOT Level of Income and Tax Revenues") legend(off)
*/

*time trends

*graph bar Income_Taxes Property_Tax Value_Added_Tax Excise_Taxes Trade_Taxes Other_Taxes if Country_Code=="`v'", over(year, relabel(1 "1990" 2 " " 3 " " 4 " " 5 " " 6 "1995" 7 " " 8 " " 9 " " 10 " " 11 "2000" 12 " " 13 " " 14 " " 15 " " 16 "2005" 17 " " 18 " " 19 " " 20 " " 21 "2010" 22 " " 23 " " 24 " " 25 " " 26 "2015" 27 "2016")) legend(label(1 "Income Tax")  label(2 "Property Tax") label(3 "Tax on Goods") label(4 "Excises") label(5 "Tax on Intl. Trade") label(6 "Other Taxes")) graphregion(color(white)) bgcolor(white) ylabel(, nogrid) ytitle("(% of GDP), 2016", size (small)) title("`v' Tax Structure (1990-2016)", size (small)) legend(off) stack

*calculating Tax buoyancy and efficiency

foreach u in Tax_Revenue_incl_SC Tax_Revenue Income_Taxes PIT CIT Property_Tax Value_Added_Tax Excise_Taxes Trade_Taxes Social_Contributions { 
gen `u'_lcu=(`u'/100)*GDP_LCU
local u1=upper(substr("`v'",1,1))+substr("`v'",2,.)+" Revenue in LCU"
label var `u'_lcu "`u1'"
}

encode Country_Code , gen(cntry)
tsset cntry year
gen delta_GDP=(GDP_LCU-l.GDP_LCU)/l.GDP_LCU

foreach u in Tax_Revenue_incl_SC Tax_Revenue Income_Taxes PIT CIT Property_Tax Value_Added_Tax Excise_Taxes Trade_Taxes Social_Contributions { 
gen delta_`u'=(`u'_lcu-l.`u'_lcu)/l.`u'_lcu
gen `u'_buoyancy=delta_`u'/delta_GDP
local u1=upper(substr("`u'",1,1))+substr("`u'",2,.)+ " Taxes - Buoyancy"
label var `u'_buoyancy "`u1'"
}

label var Tax_Revenue_incl_SC_buoyancy "Tax Revenue incl. SC Buoyancy"
label var Tax_Revenue_buoyancy "Tax Buoyancy"
label var Income_Taxes_buoyancy "Income Taxes Buoyancy"
label var Value_Added_Tax_buoyancy "VAT Buoyancy"
label var Property_Tax_buoyancy "Property Taxes Buoyancy"
label var Trade_Taxes_buoyancy "Trade Taxes Buoyancy"

*renaming as the variable is too long

rename Tax_Revenue_incl_SC Tax_Rev_incl_SC
rename Tax_Revenue_incl_SC_buoyancy Tax_Rev_incl_SC_buoyancy

foreach u in Tax_Rev_incl_SC Tax_Revenue Income_Taxes Property_Tax Value_Added_Tax Excise_Taxes Trade_Taxes { 
egen buoy_cnt_`u'_gt_1=count(`u'_buoyancy) if `u'_buoyancy>=1 & `u'_buoyancy!=. , by(Country_Code)
replace buoy_cnt_`u'_gt_1=0 if buoy_cnt_`u'_gt_1==. & `u'_buoyancy!=.
}
gen tot_yrs=2016-1990

su buoy_cnt_Tax_Revenue_gt_1 if Country_Code=="`v'"
su buoy_cnt_Income_Taxes_gt_1 if Country_Code=="`v'"
*su buoy_cnt_genr_gt_1 if Country_Code=="`v'"
*su buoy_cnt_trade_gt_1 if Country_Code=="`v'"

*tostring tot_yrs, replace 
*tostring buoy_cnt_tax_lt_1, replace
local l=`r(N)'-`r(max)'
local text1="Years Buoyancy is < 1 : "+ "`l'"
local text2="Years Buoyancy is > 1 : "+ "`r(max)'"

*di "`text2'"

*gen tax_buoy_5_yr_avg= (F2.tax_buoyancy+F1.tax_buoyancy+tax_buoyancy+l1.tax_buoyancy+l2.tax_buoyancy)/5
*gen tax_buoy_3_yr_avg= (F1.tax_buoyancy+tax_buoyancy+l1.tax_buoyancy)/3

*sort Country_Code year
*twoway (lowess tax_buoyancy year if year<=2016 & Country_Code=="`v'", bwidth(0.2) msymbol(X)), title("Tax Buoyancy `v' (smoothed)")



twoway (connected Tax_Revenue_buoyancy year if year<=2016 & Country_Code=="`v'", yline(0) yline(1, lp(dash)) msymbol(X) ytitle("Multiples of % change in GDP", size(small)) ), graphregion(color(white)) bgcolor(white) ylabel(, nogrid labsize(small)) xtitle(, size(small)) xlabel(, labsize(small)) text(3.0 2010 "`text1'", color(black) size(vsmall)) text(2.0 2010  "`text2'", color(black) size(vsmall)) title("Buoyancy of Overall Taxes in `v'", size(small))
graph save "`w' Tax Buoyancy", replace  
graph export "`w' Tax Buoyancy.png", replace

*twoway (connected tax_buoyancy Income_Taxes_buoyancy genr_buoyancy trade_buoyancy year if year<=2016 & Country_Code=="`v'", yline(0) yline(1, lp(dash)) msymbol(Oh S T + - x)), title("Tax Buoyancy `v'", size(small))

*twoway (connected tax_buoyancy year if year<=2016 & Country_Code=="`v'", msymbol(X) yline(0) yline(1, lp(dash)) ytitle("Multiples of GDP", size(small)) ylabel(-1.0(1.0)4.0)), graphregion(color(white)) bgcolor(white) ylabel(, nogrid labsize(small)) xtitle(, size(small)) xlabel(, labsize(small)) text(3.2 2011 "`text1'", color(black) size(vsmall)) text(3.0 2011  "`text2'", color(black) size(vsmall)) title("Buoyancy of Income Taxes in `v'", size(small))

twoway (connected Income_Taxes_buoyancy year if year<=2016 & Country_Code=="`v'", msymbol(X) yline(0) yline(1, lp(dash)) ytitle("Multiples of % change in GDP", size(small))), graphregion(color(white)) bgcolor(white) ylabel(, nogrid labsize(small)) xtitle(, size(small)) xlabel(, labsize(small)) text(10.0 2011 "`text1'", color(black) size(vsmall)) text(8.0 2011  "`text2'", color(black) size(vsmall)) title("Buoyancy of Income Taxes in `v'", size(small))
graph save "`w' Income Tax Buoyancy", replace  
graph export "`w' Income Tax Buoyancy.png", replace

twoway (connected Value_Added_Tax_buoyancy year if year<=2016 & Country_Code=="`v'", msymbol(X) yline(0) yline(1, lp(dash)) ytitle("Multiples of % change in GDP", size(small))), graphregion(color(white)) bgcolor(white) ylabel(, nogrid labsize(small)) xtitle(, size(small)) xlabel(, labsize(small)) text(3.0 2011 "`text1'", color(black) size(vsmall)) text(2.0 2011  "`text2'", color(black) size(vsmall)) title("Buoyancy of VAT in `v'", size(small))
graph save "`w' VAT Buoyancy", replace  
graph export "`w' VAT Buoyancy.png", replace

twoway (connected Trade_Taxes_buoyancy year if year<=2016 & Country_Code=="`v'", msymbol(X) yline(0) yline(1, lp(dash)) ytitle("Multiples of % change in GDP", size(small))), graphregion(color(white)) bgcolor(white) ylabel(, nogrid labsize(small)) xtitle(, size(small)) xlabel(, labsize(small)) text(10.0 2011 "`text1'", color(black) size(vsmall)) text(6.0 2011  "`text2'", color(black) size(vsmall)) title("Buoyancy of Trade Taxes in `v'", size(small))
graph save "`w' Trade Tax Buoyancy", replace  
graph export "`w' Trade Tax Buoyancy.png", replace

rename Tax_Rev_incl_SC Tax_Revenue_incl_SC 

/*
* TAX EFFICIENCY when data for tax rates are available

merge 1:m Country_Code year using "`v' Tax Rate Data"
drop if _merge!=3
drop _merge
keep if Country_Code=="`v'"

gen gst_eff=(Value_Added_Tax/GST_Rate)*100
gen Income_Taxes_eff=(Income_Taxes/Composite_Income_Tax_Rate)*100

twoway (connected gst_eff year if year<=2016 & Country_Code=="`v'",  msymbol(X) ytitle("(%)", size(small)) ), graphregion(color(white)) bgcolor(white) ylabel(, nogrid labsize(small)) xtitle(, size(small)) xlabel(, labsize(small)) text(17 2010 "100% is full efficiency", color(black) size(small)) title("Tax Efficiency - Goods and Services Taxes", size(small))
twoway (connected inc_eff year if year<=2016 & Country_Code=="`v'",  msymbol(X) ytitle("(%)", size(small)) ), graphregion(color(white)) bgcolor(white) ylabel(, nogrid labsize(small)) xtitle(, size(small)) xlabel(, labsize(small)) text(8.0 2010 "100% is full efficiency", color(black) size(small)) title("Tax Efficiency - Income Taxes", size(small))

*/


*Tax Potential based on best performer
*Stochastic Frontier Analysis

sort Country_Code year

gen ln_Tax_Revenue = ln(Tax_Revenue)

gen ln_Tax_Revenue_incl_SC = ln(Tax_Revenue_incl_SC)

gen ln_Trade = ln(Trade)


* prep for frontier analysis
egen Country_ID=group(Country_Code), label
xtset Country_ID year

/*
frontier ln_Tax_Revenue ln_GDP_PC ln_GDP_PC2 Trade res_dum, dist(tnormal)
predict Tax_Effort, te
summ Tax_Effort,d
*/

*When doing frontier analysis and the iterations don't converge we need to supply an initial value
reg ln_Tax_Revenue_incl_SC ln_GDP_PC ln_GDP_PC2 ln_Trade
matrix b0 = e(b), ln(e(rmse)^2) , .1
matrix list b0

frontier ln_Tax_Revenue_incl_SC ln_GDP_PC ln_GDP_PC2 ln_Trade, dist(hnormal) from(b0, copy)
predict Tax_Effort, te
summ Tax_Effort, d

label var Tax_Effort "Tax Effort"

/*
gen Tax_Capacity = Tax_Revenue/Tax_Effort
*/

gen Tax_Capacity = Tax_Revenue_incl_SC/Tax_Effort

label var Tax_Capacity "Tax Capacity (% of GDP)"

gen Tax_Gap = Tax_Capacity - Tax_Revenue_incl_SC

label var Tax_Gap "Tax Gap (% of GDP)"

sort Country_Code year

twoway (line Tax_Capacity  year if Country_Code=="`v'") (connected Tax_Revenue_incl_SC  year if Country_Code=="`v'"), legend(lab(1 "Tax Capacity") lab(2 "Tax Revenue incl. SC")) ylabel(5(5)40) ytitle("% of GDP") title("`w': Tax Capacity and Performance")
graph save "`w' Tax Capacity", replace  
graph export "`w' Tax Capacity.png", replace

twoway (line Tax_Effort  year if Country_Code=="`v'"), title("`w': Tax Effort")
graph save "`w' Tax Effort", replace  
graph export "`w' Tax Effort.png", replace

twoway (line Tax_Gap  year if Country_Code=="`v'"), title("`w': Tax Gap")
graph save "`w' Tax Gap", replace  
graph export "`w' Tax Gap.png", replace

list Country_Code year Tax_Capacity Tax_Revenue_incl_SC Tax_Gap if Country_Code=="`v'"

