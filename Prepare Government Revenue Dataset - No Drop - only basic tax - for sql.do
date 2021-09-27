clear all
set more off
*cd "C:\Users\wb305167\OneDrive - WBG\Research
cd "C:\Users\wb305167\OneDrive - WBG\python_latest\Tax-Revenue-Analysis"

import excel country_code_updated.xls, sheet("country_code") firstrow clear
rename Country_Name countryname
sort Country_Code
save country_code, replace

import excel "Country Data Update March 2020.xlsx", sheet("revenue_for_WRD") firstrow clear
gen Identifier = trim(Country_Code) + string(year)
sort Identifier
save "Country Data Update March 2020-Revenue", replace


import excel "Government Revenue Dataset - June 2020 - work", sheet("work") firstrow clear
*import excel "Government Revenue Dataset - Sept 2019 Updated Nov 2019", sheet("work") firstrow clear
*import excel "Government Revenue Dataset - Downloaded Jan-2019 - updated 22-Jan", sheet("work") firstrow clear
*import excel "Government Revenue Dataset ICTDWIDER-GRD_2018.xlsx", sheet("work") firstrow clear
destring Year, replace
*export delimited using "Government Revenue Dataset - Updated June 2020.csv", replace

rename ISO Country_Code
rename Year year
rename mergecode general
rename Source gov_data_source
drop Reg

sort Identifier

merge Identifier using "Country Data Update March 2020-Revenue", update replace

drop _merge
*Country specific Edits
* Pakistan
replace Value_Added_Tax = (Tax_on_Goods_and_Services - Excise_Taxes) if Country_Code=="PAK" & Value_Added_Tax==.

****

foreach v of varlist Total_Revenue_incl_SC Total_Revenue_excl_SC Tax_Revenue_incl_SC Tax_Revenue Total_Non_Tax_Revenue ///
					Direct_taxes Income_Taxes PIT CIT Indirect_Taxes Tax_on_Goods_and_Services ///
					Value_Added_Tax Excise_Taxes Trade_Taxes Social_Contributions Property_Tax ///
					Other_Taxes Export_Taxes Resource_Taxes	Non_Res_Tax_Rev_incl_SC	Non_Res_Tax_Rev_excl_SC ///
					Direct_excl_SC_incl_Res	Direct_excl_SC_excl_Res	Import_Taxes Grants {
    *replace `v' = `v'*100
	replace `v' = . if `v'==0
	*format `v' %2.2f
	}

keep if year==2018
	
keep 	year Country_Code Country Total_Revenue_incl_SC ///
		Total_Revenue_excl_SC Tax_Revenue_incl_SC Tax_Revenue Total_Non_Tax_Revenue ///
		Direct_taxes Income_Taxes PIT CIT Indirect_Taxes Tax_on_Goods_and_Services ///
		Value_Added_Tax Excise_Taxes Trade_Taxes Social_Contributions Property_Tax Other_Taxes Export_Taxes ///
		Resource_Taxes	Non_Res_Tax_Rev_incl_SC	Non_Res_Tax_Rev_excl_SC Direct_excl_SC_incl_Res	///
		Direct_excl_SC_excl_Res	Import_Taxes Grants
					
sort Country_Code
merge Country_Code using country_code
*drop if _merge!=3
drop _merge

generate order = 1 if Income_Group=="Low_Income"
replace order = 2 if Income_Group=="Lower_Middle_Income"
replace order = 3 if Income_Group=="Upper_Middle_Income"
replace order = 4 if Income_Group=="High_Income"

gen PITtoTTR_18 = (PIT/Tax_Revenue)*100
gen CITtoTTR_18 = (CIT/Tax_Revenue)*100
gen Value_Added_TaxtoTTR_18 = (Value_Added_Tax/Tax_Revenue)*100
gen Excise_TaxestoTTR_18 = (Excise_Taxes/Tax_Revenue)*100
gen Trade_TaxestoTTR_18 =  (Trade_Taxes/Tax_Revenue)*100
gen Other_TaxestoTTR_18 = (Other_Taxes/Tax_Revenue)*100


egen mean_PITtoTTR_18=mean(PITtoTTR_18), by(Income_Group)
egen mean_CITtoTTR_18=mean(CITtoTTR_18), by(Income_Group)
egen mean_Value_Added_TaxtoTTR_18=mean(Value_Added_TaxtoTTR_18), by(Income_Group)
egen mean_Excise_TaxestoTTR_18=mean(Excise_TaxestoTTR_18), by(Income_Group)
egen mean_Trade_TaxestoTTR_18=mean(Trade_TaxestoTTR_18), by(Income_Group)
egen mean_Other_TaxestoTTR_18=mean(Other_TaxestoTTR_18), by(Income_Group)


local y_title = "{bf:% of Tax Revenue}"
local title = "{bf:Tax Structure (% of tax revenue) 2018}"
*local sub_title = "(by Country Income, Year 2018)"
local footer = "Data Source: WB (using UNU-WIDER World Revenue Database)"
splitvallabels Income_Group, length(12)

#delimit ;
graph bar mean_PITtoTTR_18 mean_CITtoTTR_18 mean_Value_Added_TaxtoTTR_18 mean_Excise_TaxestoTTR_18 mean_Trade_TaxestoTTR_18 mean_Other_TaxestoTTR_18,
over(Income_Group, relabel(`r(relabel)') label(labsize(small)) gap(*.4) sort(order))
graphregion(color(white)) ytitle(`y_title', size(medium)) ylabel(0(5)40,labsize(small) nogrid)
legend(label(1 "PIT") label(2 "CIT") label(3 "VAT") label(4 "Excise Taxes") label(5 "Trade Taxes") label(6 "Other Taxes")
rows(1) size(small) symysize(vsmall) symxsize(vsmall))
title(`title', size(medium)) subtitle(`sub_title', size (small))
text(-8 15.0 "`footer'", size(small)) bar(1, color(32 56 100*1))
bar(2, color(32 56 100*0.9)) bar(3, color(32 56 100*0.8)) bar(4, color(32 56 100*0.7)) bar(5, color(32 56 100*0.6)) bar(6, color(32 56 100*0.5)) outergap(.005) ;

#delimit cr

/*
#delimit ;
graph bar mean_PITtoTTR_18 mean_CITtoTTR_18 mean_Value_Added_TaxtoTTR_18 mean_Excise_TaxestoTTR_18 mean_Trade_TaxestoTTR_18 mean_Other_TaxestoTTR_18,
over(Income_Group, relabel(`r(relabel)') label(labsize(vsmall)) gap(*.4) sort(order))
graphregion(color(white)) ytitle(`y_title', size(small)) ylabel(0(5)40,labsize(small) nogrid)
legend(label(1 "PIT") label(2 "CIT") label(3 "VAT") label(4 "Excise Taxes") label(5 "Trade Taxes") label(6 "Other Taxes")
rows(1) size(vsmall) symysize(vsmall) symxsize(vsmall))
title(`title', size(small)) subtitle(`sub_title', size (vsmall))
text(-7 4.0 "`footer'", size(tiny)) bar(1, color(0 0 255*1))
bar(2, color(0 0 255*.8)) bar(3, color(0 0 255*.7)) bar(4, color(0 0 255*.6)) bar(5, color(0 0 255*.5)) bar(6, color(0 0 255*.4)) outergap(.005) ;

#delimit cr
*/
*bar(2, color(0 191 255*.8)) bar(3, color(0 191 255*.7)) bar(4, color(0 191 255*.6)) bar(5, color(0 191 255*.5)) bar(6, color(0 191 255*.4)) outergap(.005) ;

save "Government Revenue Dataset Latest", replace

foreach v of varlist Total_Revenue_incl_SC Total_Revenue_excl_SC Tax_Revenue_incl_SC Tax_Revenue Total_Non_Tax_Revenue ///
					Direct_taxes Income_Taxes PIT CIT Indirect_Taxes Tax_on_Goods_and_Services ///
					Value_Added_Tax Excise_Taxes Trade_Taxes Social_Contributions Property_Tax ///
					Other_Taxes Export_Taxes Resource_Taxes	Non_Res_Tax_Rev_incl_SC	Non_Res_Tax_Rev_excl_SC ///
					Direct_excl_SC_incl_Res	Direct_excl_SC_excl_Res	Import_Taxes Grants {
    
	replace `v' = "NULL" if `v'==.
	*format `v' %2.2f
}
export delimited using "tax_revenue1.csv", replace
