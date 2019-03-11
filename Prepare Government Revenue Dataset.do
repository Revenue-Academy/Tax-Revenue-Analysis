clear all
set more off
cd "C:\Users\wb305167\OneDrive - WBG\Research

import excel "Trade in percentage of GDP.xls", sheet("Sheet1") firstrow clear
sort Country_Code year
save "Trade in percentage of GDP", replace

import excel "GDP Constant 2010 USD.xls", sheet("Sheet1") firstrow clear
sort Country_Code year
save "GDP Constant 2010 USD", replace

import excel "GDP Per Capita Constant USD.xls", sheet("Sheet1") firstrow clear
sort Country_Code year
save "GDP Per Capita Constant USD", replace

import excel country_code.xls, sheet("country_code") firstrow clear
rename Country countryname
sort Country_Code
save country_code, replace

import excel CPIA.xls, sheet("Sheet1") firstrow clear
sort Country_Code
save IDA_countries, replace

import excel "Agriculture value added WDI Oct 2017 - percent of GDP.xls", sheet("Sheet1") firstrow clear
sort Country_Code year
save "Agriculture value added WDI Oct 2017 - percent of GDP", replace

import excel "Polity Dataset Democracy.xls", sheet("Sheet1") firstrow clear
sort Country_Code year
save "Polity Dataset Democracy", replace

***
*use "CPIA Nov 2018", clear
*duplicates drop Country_Code, force
*sort Country_Code
*gen IDA="YES"
*keep Country_Code IDA
*save IDA_countries, replace
***


use country_code, clear
merge Country_Code using IDA_countries
drop if countryname==""
replace IDA="NO" if IDA!="YES"
drop _merge
sort Country_Code
save country_code, replace

import excel "Government Revenue Dataset - Downloaded Jan-2019 - updated 22-Jan", sheet("work") firstrow clear
*import excel "Government Revenue Dataset ICTDWIDER-GRD_2018.xlsx", sheet("work") firstrow clear
destring Year, replace

rename ISO Country_Code
rename Year year
rename AY Export_Taxes

foreach v of varlist Total_Revenue_incl_SC Tax_Revenue_incl_SC Tax_Revenue Total_Non_Tax_Revenue ///
					Direct_taxes Income_Taxes PIT CIT Indirect_Taxes Tax_on_Goods_and_Services ///
					Value_Added_Tax Excise_Taxes Trade_Taxes Social_Contributions Property_Tax Other_Taxes Export_Taxes {
    replace `v' = `v'*100
	replace `v' = . if `v'==0
	format `v' %2.1f
	}

keep Identifier Country Reg Inc year Country_Code GDP_LCU Total_Revenue_incl_SC Tax_Revenue_incl_SC Tax_Revenue Total_Non_Tax_Revenue ///
					Direct_taxes Income_Taxes PIT CIT Indirect_Taxes Tax_on_Goods_and_Services ///
					Value_Added_Tax Excise_Taxes Trade_Taxes Social_Contributions Property_Tax Other_Taxes Export_Taxes
					
sort Country_Code
merge Country_Code using country_code
drop if _merge!=3
drop _merge
save "Government Revenue Dataset Latest", replace

use "Government Revenue Dataset Latest", clear
sort Country_Code year

label var Tax_Revenue_incl_SC "Tax Revenue incl. SC (% of GDP)"
label var Tax_Revenue "Tax Revenue (% of GDP)"
label var Total_Revenue_incl_SC "Total Revenue incl. SC (% of GDP)"

gen PIT_SC = PIT+Social_Contributions
label var Tax_Revenue_incl_SC "Tax Revenue and SC"
label var PIT_SC "PIT and SC"

egen mean_Tax_Revenue_05_15 = mean(Tax_Revenue) if year>=2005, by(Country_Code)
gen Tax_Underperformer = 1 if mean_Tax_Revenue_05_15<15
replace Tax_Underperformer = 0 if mean_Tax_Revenue_05_15>=15

egen mean_Total_Tax_Revenue_05_15 = mean(Total_Revenue_incl_SC) if year>=2005, by(Country_Code)
gen Total_Revenue_Underperformer = 1 if mean_Total_Tax_Revenue_05_15<15
replace Total_Revenue_Underperformer = 0 if mean_Total_Tax_Revenue_05_15>=15

*use "GDP Constant USD - Jan 2019", clear
*including per capita income
merge 1:m Country_Code year using "GDP Constant 2010 USD"
drop if _merge !=3
drop _merge
label var GDP_Constant_USD "GDP Constant 2010 USD"
*save "GDP Constant 2010 USD", replace


*use "GDP Per Capita Constant USD - Jan 2019", clear
*including per capita income
merge 1:m Country_Code year using "GDP Per Capita Constant USD"
drop if _merge !=3
drop _merge
rename GDP_Per_Capita_Constant_USD GDP_PC
label var GDP_PC "GDP Per Capita Constant 2010 USD"
gen ln_GDP_PC = ln(GDP_PC)
label var ln_GDP_PC "Log of GDP Per Capita"
gen ln_GDP_PC2 = ln_GDP_PC^2
label var ln_GDP_PC2 "Log of GDP Per Capita Squared"
*save "GDP Per Capita Constant USD", replace

*use "Trade in percentage of GDP- Nov 2018", clear
*including trade
merge 1:m Country_Code year using "Trade in percentage of GDP- Nov 2018"
drop if _merge !=3
drop _merge
*save "Trade in percentage of GDP", replace


*Resource Rich dummy
gen res_dum=.
replace res_dum=1 if Resource_Rich=="YES"
replace res_dum=0 if Resource_Rich=="NO"

gen oil_gas_dum=.
replace oil_gas_dum=1 if Oil_Gas_Rich=="YES"
replace oil_gas_dum=0 if Oil_Gas_Rich=="NO"


*identifying outliers
foreach u in Total_Revenue_incl_SC Tax_Revenue_incl_SC Tax_Revenue Income_Taxes Value_Added_Tax Excise_Taxes Trade_Taxes { 
egen `u'_99 = pctile(`u'), p(99)
egen `u'_01 = pctile(`u'), p(1)
}

save "Government Revenue Dataset - augmented", replace
export excel using "Government-Revenue-Dataset-augmented.xlsx", firstrow(variables) replace
export delimited using "Government Revenue Dataset-augmented.csv", replace
