cd "C:\Users\wb305167\OneDrive - WBG\python_latest\Tax-Revenue-Analysis\"

import excel "MPO GDP historic and projections v2.xlsx", ///
 sheet("Sheet1") firstrow clear
 
rename (A C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF AG ///
 AH AI AJ AK AL AM AN AO AP AQ AR AS) (indicator yr1980 yr1981 ///
 yr1982 yr1983 yr1984 yr1985 yr1986 yr1987 yr1988 yr1989 yr1990 yr1991 yr1992 ///
 yr1993 yr1994 yr1995 yr1996 yr1997 yr1998 yr1999 yr2000 yr2001 yr2002 yr2003 ///
 yr2004 yr2005 yr2006 yr2007 yr2008 yr2009 yr2010 yr2011 yr2012 yr2013 yr2014 ///
 yr2015 yr2016 yr2017 yr2018 yr2019 yr2020 yr2021 yr2022)

drop in 1
drop if B=="" | B==" The" | B==" Dem" | B==" Dem. Rep" | B==" Federated States of" ///
 | B==" Islamic Rep." | B==" Rep." | B==" Republic of the" | B==" " | B==" Arab Rep."

drop B
gen Country_Code=substr(indicator, 1, 3)
gen series=substr(indicator, 4, 11)

destring yr1980, replace

reshape long yr, i(indicator) j(year)
rename yr score

drop indicator

reshape wide score, i(Country_Code year) j(series) string
rename (scoreNYGDPMKTPCD scoreNYGDPMKTPKD scoreNYGDPMKTPCN scoreNYGDPMKTPKN) ///
 (gdp_val_usd gdp_vol_usd15 gdp_val_lcu gdp_vol_lcu)
rename (scoreNVAGRTOTLCN scoreNVAGRTOTLKN scoreNVINDTOTLCN scoreNVINDTOTLKN ///
 scoreNVSRVTOTLCN scoreNVSRVTOTLKN) (agri_val_lcu agri_vol_lcu manu_val_lcu ///
 manu_vol_lcu serv_val_lcu serv_vol_lcu)

lab var gdp_val_usd "Gross Domestic Product at Market Price Value Millions USD"
lab var gdp_vol_usd15 "Gross Domestic Product at Market Price Volume Millions 2015 real USD"
lab var gdp_val_lcu "Gross Domestic Product at Market Price Value Millions LCU"
lab var gdp_vol_lcu "Gross Domestic Product at Market Price Volume Millions LCU"
lab var agri_val_lcu "Agriculture Value Millions LCU"
lab var agri_vol_lcu "Agriculture Volume Millions LCU"
lab var manu_val_lcu "Industry Value Millions LCU"
lab var manu_vol_lcu "Industry Volume Millions LCU"
lab var serv_val_lcu "Services Value Millions LCU"
lab var serv_vol_lcu "Services Volume Millions LCU"

foreach v of varlist gdp_val_usd gdp_vol_usd15 gdp_val_lcu gdp_vol_lcu agri_val_lcu agri_vol_lcu manu_val_lcu ///
 manu_vol_lcu serv_val_lcu serv_vol_lcu{
replace `v' = `v'*1000000
}

sort Country_Code year
save "World Bank MPO GDP historic and projections v2.dta", replace
export excel using "World Bank MPO GDP historic and projections", firstrow(variables) replace

* now adjust the 2015 value of constant USD to 2010 value by comparing with 
* earlier GDP series
import excel using "World_Bank_GDP_Series_Jan_2020.xlsx", sheet("Sheet1") firstrow clear
sort Country_Code year
save "World_Bank_GDP_Series_Jan_2020", replace
merge Country_Code year using "World Bank MPO GDP historic and projections v2.dta"
drop if Country_Code==""
drop if year==.
rename _merge _merge1
sort Country_Code year
save "World_Bank_GDP_Series_Jan_2020_with_projections", replace
* this saved file now has the old values and the new values
* we now only capture the 2010 records
drop if year!=2010
*list Country_Code GDP_Constant_USD gdp_vol_usd15
*replace gdp_vol_usd15 = gdp_vol_usd15*1000000
gen multiplier = (GDP_Constant_USD/gdp_vol_usd15)
drop year
sort Country_Code
save "World_Bank_GDP_Series_2010_multiplier", replace
* we now have a multiplier affixed to each country

use "World_Bank_GDP_Series_Jan_2020_with_projections", clear

merge Country_Code using "World_Bank_GDP_Series_2010_multiplier"

gen GDP_Constant_USD_proj = gdp_vol_usd15*multiplier
rename gdp_val_lcu GDP_LCU_proj

gen GDP_Constant_USD_proj_lag=.
replace GDP_Constant_USD_proj_lag=GDP_Constant_USD_proj[_n-1] if year==year[_n-1]+1 & Country_Code==Country_Code[_n-1]
gen GDP_Const_proj_growth_rate = (GDP_Constant_USD_proj - GDP_Constant_USD_proj_lag)*100/GDP_Constant_USD_proj_lag

gen GDP_LCU_proj_lag=.
replace GDP_LCU_proj_lag=GDP_LCU_proj[_n-1] if year==year[_n-1]+1 & Country_Code==Country_Code[_n-1]
gen GDP_LCU_proj_growth_rate = (GDP_LCU_proj - GDP_LCU_proj_lag)/GDP_LCU_proj_lag

drop if year<1980
keep year Country_Code GDP_Constant_USD_proj GDP_Constant_USD_proj_lag ///
     GDP_Const_proj_growth_rate GDP_LCU_proj GDP_LCU_proj_lag GDP_LCU_proj_growth_rate

sort Country_Code year
export excel using "World_Bank_GDP_Series_with_projections", firstrow(variables) replace
save "World_Bank_GDP_Series_with_projections", replace

use country_code, clear
keep Country_Code Country
sort Country_Code
save "country_code_only.dta", replace
* this part is to drop all the data that do not have a country code 
* such as WLD, EUU, FCS,etc.
use "World_Bank_GDP_Series_with_projections", clear
sort Country_Code
merge Country_Code using "country_code_only.dta"
drop if _merge!=3
drop _merge
sort Country_Code year
save "World_Bank_GDP_Series_with_projections", replace

use country_code_only.dta, clear
sort Country
save "country_code_only.dta", replace

import excel "IMF_GDP_series_Update_WEOJun2020update.xlsx", sheet("Sheet1") firstrow clear
sort Country
merge Country using country_code_only
drop _merge
sort Country_Code
save "IMF_GDP_Series_June_2020_update", replace

import excel "IMF_GDP_Series_April_2020.xls", sheet("Sheet1") firstrow clear
sort Country
merge Country using country_code_only
sort Country_Code
drop _merge
merge Country_Code using "IMF_GDP_Series_June_2020_update"
keep if _merge==3
replace data2020=newdata2020 if newdata2020!=.
replace data2021=newdata2021 if newdata2021!=.
keep Country_Code Country data*
gen unit_id=_n

reshape long data, i(unit_id) j(time)
drop unit_id
rename time year
rename data GDP_growth_rate_IMF
sort Country_Code year
save "IMF_GDP_Series_April_2020_updated", replace

use "World_Bank_GDP_Series_with_projections", clear
merge Country_Code year using "IMF_GDP_Series_April_2020_updated"

replace GDP_Const_proj_growth_rate = GDP_growth_rate_IMF if GDP_Const_proj_growth_rate==. & GDP_growth_rate_IMF!=.
drop _merge
sort Country_Code year
save "World_Bank_GDP_Series_with_projections_incl_IMF", replace
drop Country
export excel using "World_Bank_GDP_Series_with_projections", firstrow(variables) replace



