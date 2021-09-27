clear all

*cd "C:\Users\wb305167\OneDrive - WBG\Research"
*cd "C:\Users\wb305167\OneDrive - WBG\python_latest\Tax-Revenue-Analysis\Tax Revenue Analysis STATA"
cd "C:\Users\wb305167\OneDrive - WBG\python_latest\Tax-Revenue-Analysis"


local v="BTN"
local w="Bhutan"

set scheme economist

import excel country_code_updated.xls, sheet("country_code") firstrow
rename Country_Name countryname
sort countryname
save country_code, replace

import excel "GDP Per Capita Constant USD Oct 2020.xlsx", sheet("Sheet1") firstrow clear
reshape long data, i(unit_id) j(time)
drop unit_id IndicatorName IndicatorCode
rename time year
rename data GDP_PC
rename CountryCode Country_Code
label var GDP_PC "GDP Per Capita Constant USD"
sort Country_Code year
save "GDP Per Capita Constant USD Oct 2020", replace

import excel "Trade in percentage of GDP Oct 2020.xlsx", sheet("Sheet1") firstrow clear
reshape long data, i(unit_id) j(time)
drop unit_id IndicatorName IndicatorCode
rename time year
rename data trade
rename CountryCode Country_Code
label var trade "Trade (% of GDP)"
sort Country_Code year
save "Trade in percentage of GDP Oct 2020", replace


import excel "Country Data Update March 2020.xlsx", sheet("revenue_for_IMF_%") firstrow clear
*gen Identifier = trim(Country_Code) + string(year)
*sort Identifier
rename Tax_Revenue_incl_SC rev
rename Tax_Revenue	tax
rename Income_Taxes	inc
rename PIT indv
rename CIT corp
rename Tax_on_Goods_and_Services goods
rename Value_Added_Tax vat
rename Excise_Taxes	excises 
rename Trade_Taxes	trade_tax
rename Social_Contributions	soc
rename Property_Tax	propr
rename Other_Taxes other_tax
sort Country_Code year

save "Country Data Update March 2020-Revenue", replace

* Code to use if directly importing STATA file from IMF https://data.imf.org/?sk=77413F1D-1525-450A-A23A-47AEED40FE78

*use "World Revenue Database IMF wide September 2020.dta", clear
*export excel using "IMF Revenue Database September 2020.xlsx", firstrow(variables) replace
import excel using "IMF Revenue Database September 2020.xlsx", sheet("Sheet1") firstrow clear


rename cname countryname

replace countryname="Cape Verde" if countryname=="Cabo Verde"
replace countryname="Congo, Dem. Rep." if countryname=="Congo, Democratic Republic of the"
replace countryname="Congo, Rep." if countryname=="Congo, Republic of"
replace countryname="Cote d'Ivoire" if countryname=="Côte d'Ivoire"
replace countryname="Egypt, Arab Rep." if countryname=="Egypt"
replace countryname="Hong Kong SAR, China" if countryname=="Hong Kong SAR"
replace countryname="Iran, Islamic Rep." if countryname=="Iran"
replace countryname="Korea, Rep." if countryname=="Korea"
replace countryname="Lao PDR" if countryname=="Lao P.D.R."
replace countryname="Macao SAR, China" if countryname=="Macao SAR"
replace countryname="Micronesia, Fed. Sts." if countryname=="Micronesia"
replace countryname="Montenegro" if countryname=="Montenegro, Rep. of"
replace countryname="Russian Federation" if countryname=="Russia"
replace countryname="Syrian Arab Republic" if countryname=="Syria"
replace countryname="Sao Tome and Principe" if countryname=="São Tomé and Príncipe"
replace countryname="Taiwan, China" if countryname=="Taiwan Province of China"
replace countryname="Venezuela, RB" if countryname=="Venezuela" 
replace countryname="Yemen, Rep." if countryname=="Yemen"
*list countryname _merge if year==2018 & _merge!=3

sort countryname
merge countryname using country_code
drop _merge
sort Country_Code year
save "IMF Revenue Database September 2020.dta", replace

rename  rev Tax_Revenue_incl_SC
rename 	tax Tax_Revenue
rename 	inc Income_Taxes
rename  indv PIT
rename  corp CIT
rename  goods Tax_on_Goods_and_Services
rename  vat Value_Added_Tax
rename 	excises  Excise_Taxes
rename 	trade Trade_Taxes
rename 	soc Social_Contributions
rename 	propr Property_Tax
rename  other_tax Other_Taxes
rename countryname Country_Name
*export excel using "IMF Revenue Database September 2020.xlsx", firstrow(variables) replace
/*
rename Tax_Revenue_incl_SC rev
rename Tax_Revenue	tax
rename Income_Taxes	inc
rename PIT indv
rename CIT corp
rename Tax_on_Goods_and_Services goods
rename Value_Added_Tax vat
rename Excise_Taxes	excises 
rename Trade_Taxes	trade
rename Social_Contributions	soc
rename Property_Tax	propr
rename Other_Taxes other_tax
rename Country_Name countryname
sort Country_Code year
*/
merge Country_Code year using "Country Data Update March 2020-Revenue", update replace
drop _merge

*list Country_Code year rev tax inc indv corp pay goods genr vat excises trade_tax soc grants other_rev ///
*other_inc other_goods other_genr if Country_Code=="`v'"

sort Country_Code year

*rename trade trade_tax
save "Revenue Database September 2020.dta", replace

sort Country_Code year


* Code when using the excel file generated from STATA
* import excel "IMF Revenue Database September 2020.xlsx" firstrow(variables) clear

merge Country_Code year using "GDP Per Capita Constant USD Oct 2020"
*drop if _merge !=3
drop _merge
label var GDP_PC "GDP Per Capita Constant 2010 USD"
gen ln_GDP_PC = ln(GDP_PC)
label var ln_GDP_PC "Log of GDP Per Capita"
gen ln_GDP_PC2 = ln_GDP_PC^2
label var ln_GDP_PC2 "Log of GDP Per Capita Squared"

*use "Trade in percentage of GDP", clear

sort Country_Code year

merge Country_Code year using "Trade in percentage of GDP Oct 2020"
*drop if _merge !=3
drop _merge
*save "Trade in percentage of GDP", replace

drop if year < 1990

*Tax Potential based on best performer
*Stochastic Frontier Analysis

sort Country_Code year

gen ln_Tax_Revenue = ln(Tax_Revenue)

gen ln_rev = ln(Tax_Revenue_incl_SC)

gen ln_trade = ln(trade)

*Generating logs for Taxes
gen ln_Income_Taxes = ln(Income_Taxes) /*PIT+CIT*/
gen ln_PIT = ln(PIT)  /*PIT*/
gen ln_CIT = ln(CIT) /*CIT*/
gen ln_Value_Added_Tax = ln(Value_Added_Tax) /*VAT*/
gen ln_pay = ln(pay) /*Taxes on Payroll and Workforce revenue*/
gen ln_Property_Tax = ln(Property_Tax) /*Property tax revenue*/
gen ln_Excise_Taxes = ln(Excise_Taxes) /*Excise Tax*/
gen ln_Social_Contributions = ln(Social_Contributions) /*Social Contributions*/
gen ln_Tax_on_Goods_and_Services = ln(Tax_on_Goods_and_Services) /*Goods and Services Tax*/
gen ln_genr = ln(genr) /*General Goods and Services Tax*/  


/*
frontier ln_Tax_Revenue ln_GDP_PC ln_GDP_PC2 Trade res_dum, dist(tnormal)
predict Tax_Effort, te
summ Tax_Effort,d
*/

*When doing frontier analysis and the iterations don't converge we need to supply an initial value
reg ln_Tax_Revenue ln_GDP_PC ln_GDP_PC2 ln_trade 
matrix b0 = e(b), ln(e(rmse)^2) , .1
matrix list b0

/*Regressing the rest of the log of taxes here*/
reg ln_Income_Taxes ln_GDP_PC ln_GDP_PC2 ln_trade 
matrix b1 = e(b), ln(e(rmse)^2) , .1
matrix list b1

reg ln_PIT ln_GDP_PC ln_GDP_PC2 ln_trade 
matrix b2 = e(b), ln(e(rmse)^2) , .1
matrix list b2

reg ln_CIT ln_GDP_PC ln_GDP_PC2 ln_trade 
matrix b3 = e(b), ln(e(rmse)^2) , .1
matrix list b3

reg ln_Value_Added_Tax ln_GDP_PC ln_GDP_PC2 ln_trade 
matrix b4 = e(b), ln(e(rmse)^2) , .1
matrix list b4

reg ln_pay ln_GDP_PC ln_GDP_PC2 ln_trade 
matrix b5 = e(b), ln(e(rmse)^2) , .1
matrix list b5

reg ln_Property_Tax ln_GDP_PC ln_GDP_PC2 ln_trade 
matrix b6 = e(b), ln(e(rmse)^2) , .1
matrix list b6

reg ln_Excise_Taxes ln_GDP_PC ln_GDP_PC2 ln_trade 
matrix b7 = e(b), ln(e(rmse)^2) , .1
matrix list b7

reg ln_Tax_on_Goods_and_Services ln_GDP_PC ln_GDP_PC2 ln_trade 
matrix b8 = e(b), ln(e(rmse)^2) , .1
matrix list b8

reg ln_genr ln_GDP_PC ln_GDP_PC2 ln_trade 
matrix b9 = e(b), ln(e(rmse)^2) , .1
matrix list b9

reg ln_Social_Contributions ln_GDP_PC ln_GDP_PC2 ln_trade 
matrix b10 = e(b), ln(e(rmse)^2) , .1
matrix list b10

*Frontier for Total Tax revenue     
frontier ln_Tax_Revenue ln_GDP_PC ln_GDP_PC2 ln_trade, dist(hnormal) from(b0, copy)
predict Tax_Effort, te
summ Tax_Effort, d
label var Tax_Effort "Tax Effort"

*Frontier for Income Taxes
frontier ln_Income_Taxes  ln_GDP_PC ln_GDP_PC2 ln_trade, dist(hnormal) from(b1, copy)
predict Tax_Effort_Income_Taxes, te
summ Tax_Effort_Income_Taxes, d
label var Tax_Effort_Income_Taxes "Tax Effort Income Taxes"

*Frontier for PIT
frontier ln_PIT ln_GDP_PC ln_GDP_PC2 ln_trade, dist(hnormal) from(b2, copy)
predict Tax_Effort_PIT, te
summ Tax_Effort_PIT, d
label var Tax_Effort_PIT "Tax Effort PIT"

*Frontier for CIT
frontier ln_CIT ln_GDP_PC ln_GDP_PC2 ln_trade, dist(hnormal) from(b3, copy)
predict Tax_Effort_CIT, te
summ Tax_Effort_CIT, d
label var Tax_Effort_CIT "Tax Effort CIT"

*Frontier for VAT
frontier ln_Value_Added_Tax ln_GDP_PC ln_GDP_PC2 ln_trade, dist(hnormal) from(b4, copy)
predict Tax_Effort_Value_Added_Tax, te
summ Tax_Effort_Value_Added_Tax, d
label var Tax_Effort_Value_Added_Tax "Tax Effort VAT"

*Frontier for Payroll taxes
frontier ln_pay ln_GDP_PC ln_GDP_PC2 ln_trade, dist(hnormal) from(b5, copy)
predict Tax_Effort_pay, te
summ Tax_Effort_pay, d
label var Tax_Effort_pay "Tax Effort Payroll Taxes"

*Frontier for Property Taxes
frontier ln_Property_Tax ln_GDP_PC ln_GDP_PC2 ln_trade, dist(hnormal) from(b6, copy)
predict Tax_Effort_Property_Tax, te
summ Tax_Effort_Property_Tax, d
label var Tax_Effort_Property_Tax "Tax Effort Poperty Taxes"

*Frontier for Excise Tax
frontier ln_Excise_Taxes ln_GDP_PC ln_GDP_PC2 ln_trade, dist(hnormal) from(b7, copy)
predict Tax_Effort_Excise_Taxes, te
summ Tax_Effort_Excise_Taxes, d
label var Tax_Effort_Excise_Taxes "Tax Effort Excise Tax"

*Frontier for Goods and Services Tax
frontier ln_Tax_on_Goods_and_Services ln_GDP_PC ln_GDP_PC2 ln_trade, dist(hnormal) from(b8, copy)
predict Tax_Effort_Tax_on_G_and_S, te
summ Tax_Effort_Tax_on_G_and_S, d
label var Tax_Effort_Tax_on_G_and_S "Tax Effort Goods and Services Tax"

*Frontier for General Goods and Services Tax
frontier ln_genr ln_GDP_PC ln_GDP_PC2 ln_trade, dist(hnormal) from(b9, copy)
predict Tax_Effort_genr, te
summ Tax_Effort_genr, d
label var Tax_Effort_genr "Tax Effort General Goods and Services Tax"

*Frontier for Social Contributions
frontier ln_Social_Contributions ln_GDP_PC ln_GDP_PC2 ln_trade, dist(hnormal) from(b10, copy)
predict Tax_Effort_Social_Contributions, te
summ Tax_Effort_Social_Contributions, d
label var Tax_Effort_Social_Contributions "Tax Effort Social Contributions"


* scatter plot tax effort versus tax revenue
*drop pos
gen pos=3
replace pos = 9 if Country_Code == "MMR"
replace pos = 12 if Country_Code == "TCD"
replace pos = 9 if Country_Code == "COM"
replace pos = 6 if Country_Code == "SDN"
replace pos = 6 if Country_Code == "COD"
replace pos = 6 if Country_Code == "CAF"
replace pos = 4 if Country_Code == "AFG"
replace pos = 9 if Country_Code == "BEN"
replace pos = 12 if Country_Code == "GMB"
replace pos = 12 if Country_Code == "LKA"
replace pos = 12 if Country_Code == "GHA"
replace pos = 12 if Country_Code == "CMR"
replace pos = 2 if Country_Code == "HTI"
replace pos = 6 if Country_Code == "ETH"
replace pos = 4 if Country_Code == "NER"
replace pos = 4 if Country_Code == "SLE"
replace pos = 1 if Country_Code == "GIN"
replace pos = 4 if Country_Code == "ZWE"
replace pos = 6 if Country_Code == "KEN"
replace pos = 4 if Country_Code == "BLR"
replace pos = 4 if Country_Code == "BFA"
replace pos = 12 if Country_Code == "BIH"
replace pos = 4 if Country_Code == "TON"
replace pos = 2 if Country_Code == "CPV"
replace pos = 4 if Country_Code == "KHM"
replace pos = 6 if Country_Code == "SEN"
replace pos = 12 if Country_Code == "WSM"
replace pos = 9 if Country_Code == "MNG"

*drop Tax_Effort_percent
gen Tax_Effort_percent = Tax_Effort*100
label var Tax_Effort_percent "Tax Effort (%)"

quietly summ Tax_Effort_percent, d
local Tax_Effort_Median=r(p50)

quietly summ Tax_Revenue, d
local Tax_Revenue_Median=r(p50)

twoway (scatter tax Tax_Effort_percent if year == 2018 & IDA=="YES", mlabel(Country_Code) mcolor(%30) mlabcolor(black) msize(small) mlabsize(tiny) mlabv(pos) yline(15.0) xline(`Tax_Effort_Median') title("Tax Revenue and Tax Effort for IDA Countries (2018)", size(medium)) ylabel(0(10)40 15) ylabel(,labsize(small)) xlabel(,labsize(small)) xtitle(,size(small)) ytitle(,size(small)) legend(off))

graph export "charts/Tax Revenue and Tax Effort - IDA.png", replace

*twoway (scatter tax Tax_Effort_percent if year == 2018, mlabel (Country_Code) msize(small) title("Tax Revenue")) (scatter tax Tax_Effort if IDA=="YES" & year == 2018, mlabel(Country_Code) mlabcolor(black) msize(small) mlabsize(small) mcolor(red) legend(off) ytitle("(% of GDP)"))

/*
gen Tax_Capacity = Tax_Revenue/Tax_Effort for *Total Tax Revenue*
*/
gen Tax_Capacity = Tax_Revenue/Tax_Effort
label var Tax_Capacity "Tax Capacity (% of GDP)"
gen Tax_Gap = Tax_Capacity - Tax_Revenue
label var Tax_Gap "Tax Gap (% of GDP)"

*Tax_Capacity for Income Taxes
gen Tax_Capacity_Income_Taxes = Income_Taxes/Tax_Effort_Income_Taxes
label var Tax_Capacity_Income_Taxes "Tax Capacity Income Taxes (% of GDP)"
gen Tax_Gap_Income_Taxes = Tax_Capacity_Income_Taxes - Income_Taxes
label var Tax_Gap_Income_Taxes "Tax Gap Income Taxes (% of GDP)"

*Tax_Capacity for PIT
gen Tax_Capacity_PIT = PIT/Tax_Effort_PIT
label var Tax_Capacity_PIT "Tax Capacity PIT (% of GDP)"
gen Tax_Gap_PIT = Tax_Capacity_PIT - PIT
label var Tax_Gap_PIT "Tax Gap PIT (% of GDP)"

*Tax_Capacity for CIT
gen Tax_Capacity_CIT = CIT/Tax_Effort_CIT
label var Tax_Capacity_CIT "Tax Capacity CIT (% of GDP)"
gen Tax_Gap_CIT = Tax_Capacity_CIT - CIT
label var Tax_Gap_CIT "Tax Gap CIT (% of GDP)"

*Tax_Capacity for VAT
gen Tax_Capacity_Value_Added_Tax = Value_Added_Tax/Tax_Effort_Value_Added_Tax
label var Tax_Capacity_Value_Added_Tax "Tax Capacity VAT (% of GDP)"
gen Tax_Gap_Value_Added_Tax = Tax_Capacity_Value_Added_Tax - Value_Added_Tax
label var Tax_Gap_Value_Added_Tax "Tax Gap VAT (% of GDP)"

*Tax_Capacity for Payroll taxes
gen Tax_Capacity_pay = pay/Tax_Effort_pay
label var Tax_Capacity_pay "Tax Capacity Payroll Taxes (% of GDP)"
gen Tax_Gap_pay = Tax_Capacity_pay - pay
label var Tax_Gap_pay "Tax Gap Payroll Taxes (% of GDP)"

*Tax_Capacity for Property Taxes
gen Tax_Capacity_Property_Tax = Property_Tax/Tax_Effort_Property_Tax
label var Tax_Capacity_Property_Tax "Tax Capacity Property Taxes (% of GDP)"
gen Tax_Gap_Property_Tax = Tax_Capacity_Property_Tax - Property_Tax
label var Tax_Gap_Property_Tax "Tax Gap Property Taxes (% of GDP)"

*Tax_Capacity for Excise Tax
gen Tax_Capacity_Excise_Taxes = Excise_Taxes/Tax_Effort_Excise_Taxes
label var Tax_Capacity_Excise_Taxes "Tax Capacity Excise Tax (% of GDP)"
gen Tax_Gap_Excise_Taxes = Tax_Capacity_Excise_Taxes - Excise_Taxes
label var Tax_Gap_Excise_Taxes "Tax Gap Excise Tax (% of GDP)"

*Tax_Capacity for Goods and Services Tax
gen Tax_Capacity_Tax_on_G_and_S = Tax_on_Goods_and_Services/Tax_Effort_Tax_on_G_and_S
label var Tax_Capacity_Tax_on_G_and_S "Tax Capacity Goods and Services Tax (% of GDP)"
gen Tax_Gap_Tax_on_G_and_S = Tax_Capacity_Tax_on_G_and_S - Tax_on_Goods_and_Services
label var Tax_Gap_Tax_on_G_and_S "Tax Gap Goods and Services Tax (% of GDP)"

*Tax_Capacity for General Goods and Services Tax
gen Tax_Capacity_genr = genr/Tax_Effort_genr
label var Tax_Capacity_genr "Tax Capacity General Goods and Services Tax (% of GDP)"
gen Tax_Gap_genr = Tax_Capacity_genr - genr
label var Tax_Gap_genr "Tax Gap General Goods and Services Tax (% of GDP)"

*Tax_Capacity for Social Contributions
gen Tax_Capacity_Excise_Taxes = Excise_Taxes/Tax_Effort_Excise_Taxes
label var Tax_Capacity_Excise_Taxes "Tax Capacity Excise Tax (% of GDP)"
gen Tax_Gap_Excise_Taxes = Tax_Capacity_Excise_Taxes - Excise_Taxes
label var Tax_Gap_Excise_Taxes "Tax Gap Excise Tax (% of GDP)"


sort Country_Code year

* Once the databas is set up, you could just start the run from here
* just remove the comments from the four lines below

*save "IMF Revenue Database September 2020 Full Analysis.dta", replace
*use "IMF Revenue Database September 2020 Full Analysis.dta", clear
*local v="UKR"
*local w="Ukraine"

list Country_Code year  Tax_Effort Tax_Capacity tax Tax_Gap if Country_Code=="`v'"
list Country_Code year rev tax Income_Taxes PIT CIT pay Tax_on_Goods_and_Services genr Value_Added_Tax Excise_Taxes trade_tax soc grants other_rev if Country_Code=="`v'"
*other_Income_Taxes other_Tax_on_Goods_and_Services other_genr if Country_Code=="`v'"
/*
local x="LAC"
local a = "BRA"
local a1 = "Brazil"
local b = "ESP"
local b1 = "Spain"
local c = "CHL"
local c1 = "Chile"
local d = "COL"
local d1 = "Colombia"
*/
*twoway capacity for Tax Revenue
twoway (line Tax_Capacity  year if Country_Code=="`v'" & year>=1995) (connected tax  year if Country_Code=="`v'" & year>=1995), legend(lab(1 "Tax Capacity") lab(2 "Tax Revenue")) ytitle("% of GDP") title("`w': Tax Capacity and Performance", size(medium)) xlabel(1995 2000 2005 2010 2014 2018)
graph export "charts/`w' Tax Capacity.png", replace

*twoway capacity repeated for rest of the taxes
twoway (line Tax_Capacity_Income_Taxes  year if Country_Code=="`v'" & year>=1995) (connected Income_Taxes  year if Country_Code=="`v'" & year>=1995), legend(lab(1 "Tax Capacity Income_Taxesome Taxes") lab(2 "Income_Taxesome Taxes")) ytitle("% of GDP") title("`w': Tax Capacity and Performance Income Taxes", size(medium)) xlabel(1995 2000 2005 2010 2014 2018)
graph export "charts/`w' Tax Capacity Income Taxes.png", replace

twoway (line Tax_Capacity_PIT  year if Country_Code=="`v'" & year>=1995) (connected PIT  year if Country_Code=="`v'" & year>=1995), legend(lab(1 "Tax Capacity PIT") lab(2 "PIT")) ytitle("% of GDP") title("`w': Tax Capacity and Performance PIT", size(medium)) xlabel(1995 2000 2005 2010 2014 2018)
graph export "charts/`w' Tax Capacity PIT.png", replace

twoway (line Tax_Capacity_CIT  year if Country_Code=="`v'" & year>=1995) (connected CIT  year if Country_Code=="`v'" & year>=1995), legend(lab(1 "Tax Capacity CIT") lab(2 "CIT")) ytitle("% of GDP") title("`w': Tax Capacity and Performance CIT", size(medium)) xlabel(1995 2000 2005 2010 2014 2018)
graph export "charts/`w' Tax Capacity CIT.png", replace

twoway (line Tax_Capacity_Value_Added_Tax  year if Country_Code=="`v'" & year>=1995) (connected Value_Added_Tax  year if Country_Code=="`v'" & year>=1995), legend(lab(1 "Tax Capacity VAT") lab(2 "VAT")) ytitle("% of GDP") title("`w': Tax Capacity and Performance VAT", size(medium)) xlabel(1995 2000 2005 2010 2014 2018)
graph export "charts/`w' Tax Capacity VAT.png", replace

twoway (line Tax_Capacity_Excise_Taxes  year if Country_Code=="`v'" & year>=1995) (connected Excise_Taxes  year if Country_Code=="`v'" & year>=1995), legend(lab(1 "Tax Capacity Excise Tax") lab(2 "Excise Tax")) ytitle("% of GDP") title("`w': Tax Capacity and Performance Excise Tax, size(medium)") xlabel(1995 2000 2005 2010 2014 2018)
graph export "charts/`w' Tax Capacity Excise Tax.png", replace

*Twoway Tax Effort for Tax Revenue
twoway (line Tax_Effort  year if Country_Code=="`v'" & year>=1995), title("`w': Tax Effort") xlabel(1995 2000 2005 2010 2014 2018)
graph export "charts/`w' Tax Effort.png", replace

*Twoway Tax Effort for rest of the other taxes
twoway (line Tax_Effort_Income_Taxes  year if Country_Code=="`v'" & year>=1995), title("`w': Tax Effort Income Taxes") xlabel(1995 2000 2005 2010 2014 2018)
graph export "charts/`w' Tax Effort Income Taxes.png", replace

twoway (line Tax_Effort_PIT  year if Country_Code=="`v'" & year>=1995), title("`w': Tax Effort PIT") xlabel(1995 2000 2005 2010 2014 2018)
graph export "charts/`w' Tax Effort PIT.png", replace

twoway (line Tax_Effort_CIT  year if Country_Code=="`v'" & year>=1995), title("`w': Tax Effort CIT") xlabel(1995 2000 2005 2010 2014 2018)
graph export "charts/`w' Tax Effort CIT.png", replace

twoway (line Tax_Effort_Value_Added_Tax  year if Country_Code=="`v'" & year>=1995), title("`w': Tax Effort VAT") xlabel(1995 2000 2005 2010 2014 2018)
graph export "charts/`w' Tax Effort VAT.png", replace

twoway (line Tax_Effort_pay  year if Country_Code=="`v'" & year>=1995), title("`w': Tax Effort Payroll taxes") xlabel(1995 2000 2005 2010 2014 2018)
graph export "charts/`w' Tax Effort Payroll taxes.png", replace

twoway (line Tax_Effort_Property_Tax  year if Country_Code=="`v'" & year>=1995), title("`w': Tax Effort Property Taxes") xlabel(1995 2000 2005 2010 2014 2018)
graph export "charts/`w' Tax Effort Property Taxes.png", replace

twoway (line Tax_Effort_Excise_Taxes  year if Country_Code=="`v'" & year>=1995), title("`w': Tax Effort Excise Tax") xlabel(1995 2000 2005 2010 2014 2018)
graph export "charts/`w' Tax Effort Excise Tax.png", replace

twoway (line Tax_Effort_Tax_on_G_and_S  year if Country_Code=="`v'" & year>=1995), title("`w': Tax Effort Goods and Services Tax") xlabel(1995 2000 2005 2010 2014 2018)
graph export "charts/`w' Tax Effort Goods and Services Tax.png", replace

twoway (line Tax_Effort_genr  year if Country_Code=="`v'" & year>=1995), title("`w': Tax Effort General Goods and Services Tax") xlabel(1995 2000 2005 2010 2014 2018)
graph export "charts/`w' Tax Effort General Goods and Services Tax.png", replace

sort Country_Code year
*local v="BLR"
*local w="Belarus"
*Tax Gap for Tax Revenue
twoway (line Tax_Gap  year if Country_Code=="`v'" & year>=1995), title("`w': Tax Gap") xlabel(1995 2000 2005 2010 2014 2018)
graph export "charts/`w' Tax Gap.png", replace
 

*Tax Gap for rest of the taxes
twoway (line Tax_Gap_Income_Taxes  year if Country_Code=="`v'" & year>=1995), title("`w': Tax Gap Income Taxes") xlabel(1995 2000 2005 2010 2014 2018)
graph export "charts/`w' Tax Gap Income Taxes.png", replace

twoway (line Tax_Gap_PIT  year if Country_Code=="`v'" & year>=1995), title("`w': Tax Gap PIT") xlabel(1995 2000 2005 2010 2014 2018)
graph export "charts/`w' Tax Gap PIT.png", replace

twoway (line Tax_Gap_CIT  year if Country_Code=="`v'" & year>=1995), title("`w': Tax Gap CIT") xlabel(1995 2000 2005 2010 2014 2018)
graph export "charts/`w' Tax Gap CIT.png", replace

twoway (line Tax_Gap_Value_Added_Tax  year if Country_Code=="`v'" & year>=1995), title("`w': Tax Gap VAT") xlabel(1995 2000 2005 2010 2014 2018)
graph export "charts/`w' Tax Gap VAT.png", replace

twoway (line Tax_Gap_Excise_Taxes  year if Country_Code=="`v'" & year>=1995), title("`w': Tax Gap Excise Tax") xlabel(1995 2000 2005 2010 2014 2018)
graph export "charts/`w' Tax Gap Excise Tax.png", replace

*Tax Revenue Graph to Compare with Average and Best Perfomer
*local v="BLR"
list Country_Code year  Tax_Effort Tax_Capacity tax Tax_Gap if Country_Code=="`v'"

gen ln_GDP_PC_bin = trunc(ln_GDP_PC*10)
egen max_Tax_Revenue = max(Tax_Revenue) if year==2018, by(ln_GDP_PC_bin)
replace max_Tax_Revenue = max_Tax_Revenue+5
sort ln_GDP_PC

twoway (scatter Tax_Revenue ln_GDP_PC if year == 2018, mlabel (Country_Code) msize(small) title("`w' Tax Revenue")) (scatter Tax_Revenue ln_GDP_PC if Country_Code=="`v'" & year == 2018, mlabel (Country_Code) mlabcolor(black) msize(small) mlabsize(small) mcolor(red)) (lowess max_Tax_Revenue ln_GDP_PC if year == 2018, lpattern(dash) lwidth(thin) lcolor(black) msymbol(i)) (lfit Tax_Revenue ln_GDP_PC if year==2018, lcolor(black) lwidth(thin)), legend(off) ytitle("(% of GDP)")

graph export "charts/`w' Tax Revenue.png", replace

*Tax Graphs for rest of the taxes

*1
*local v="BLR"
list Country_Code year  Tax_Effort_Income_Taxes Tax_Capacity_Income_Taxes Income_Taxes Tax_Gap_Income_Taxes if Country_Code=="`v'"

*gen ln_GDP_PC_bin = trunc(ln_GDP_PC*10)

egen max_Income_Taxes = max(Income_Taxes) if year==2018, by(ln_GDP_PC_bin)
replace max_Income_Taxes = max_Income_Taxes+2
sort ln_GDP_PC
twoway (scatter Income_Taxes ln_GDP_PC if year == 2018, mlabel (Country_Code) msize(small) title("`w' Income Taxes")) (scatter Income_Taxes ln_GDP_PC if Country_Code=="`v'" & year == 2018, mlabel (Country_Code) mlabcolor(black) msize(small) mcolor(red)) (lowess max_Income_Taxes ln_GDP_PC if year == 2018, lpattern(dash) lwidth(thin) lcolor(black) msymbol(i)) (lfit Income_Taxes ln_GDP_PC if year==2018, lcolor(black) lwidth(thin)), legend(off) ytitle("(% of GDP)")

graph export "charts/`w' Income Taxes.png", replace
*2
*local v="BLR"
list Country_Code year  Tax_Effort_PIT Tax_Capacity_PIT PIT Tax_Gap_PIT if Country_Code=="`v'"

*gen ln_GDP_PC_bin = trunc(ln_GDP_PC*10)
egen max_PIT = max(PIT) if year==2018, by(ln_GDP_PC_bin)
replace max_PIT = max_PIT+2
sort ln_GDP_PC
twoway (scatter PIT ln_GDP_PC if year == 2018, mlabel (Country_Code) msize(small) title("`w' PIT")) (scatter PIT ln_GDP_PC if Country_Code=="`v'" & year == 2018, mlabel (Country_Code) mlabcolor(black) msize(small) mcolor(red)) (lowess max_PIT ln_GDP_PC if year == 2018, lpattern(dash) lwidth(thin) lcolor(black) msymbol(i)) (lfit PIT ln_GDP_PC if year==2018, lcolor(black) lwidth(thin)), legend(off) ytitle("(% of GDP)")

graph export "charts/`w' PIT.png", replace
*3
*local v="BLR"
list Country_Code year  Tax_Effort_CIT Tax_Capacity_CIT CIT Tax_Gap_CIT if Country_Code=="`v'"

*gen ln_GDP_PC_bin = trunc(ln_GDP_PC*10)
egen max_CIT = max(CIT) if year==2018, by(ln_GDP_PC_bin)
replace max_CIT = max_CIT+2
sort ln_GDP_PC
twoway (scatter CIT ln_GDP_PC if year == 2018, mlabel (Country_Code) msize(small) title("`w' CIT")) (scatter CIT ln_GDP_PC if Country_Code=="`v'" & year == 2018, mlabel (Country_Code) mlabcolor(black) msize(small) mcolor(red)) (lowess max_CIT ln_GDP_PC if year == 2018, lpattern(dash) lwidth(thin) lcolor(black) msymbol(i)) (lfit CIT ln_GDP_PC if year==2018, lcolor(black) lwidth(thin)), legend(off) ytitle("(% of GDP)")

graph export "charts/`w' CIT.png", replace
*4
*local v="BLR"
list Country_Code year  Tax_Effort_Value_Added_Tax Tax_Capacity_Value_Added_Tax Value_Added_Tax Tax_Gap_Value_Added_Tax if Country_Code=="`v'"

*gen ln_GDP_PC_bin = trunc(ln_GDP_PC*10)
egen max_Value_Added_Tax = max(Value_Added_Tax) if year==2018, by(ln_GDP_PC_bin)
replace max_Value_Added_Tax = max_Value_Added_Tax+2
sort ln_GDP_PC
twoway (scatter Value_Added_Tax ln_GDP_PC if year == 2018, mlabel (Country_Code) msize(small) title("`w' VAT")) (scatter Value_Added_Tax ln_GDP_PC if Country_Code=="`v'" & year == 2018, mlabel (Country_Code) mlabcolor(black) msize(small) mcolor(red)) (lowess max_Value_Added_Tax ln_GDP_PC if year == 2018, lpattern(dash) lwidth(thin) lcolor(black) msymbol(i)) (lfit Value_Added_Tax ln_GDP_PC if year==2018, lcolor(black) lwidth(thin)), legend(off) ytitle("(% of GDP)")

graph export "charts/`w' VAT.png", replace

*local v="MYS"
*local w="Malaysia"
list Country_Code year  Tax_Effort_Value_Added_Tax Tax_Capacity_Value_Added_Tax Value_Added_Tax Tax_Gap_Value_Added_Tax if Country_Code=="`v'"

*gen ln_GDP_PC_bin = trunc(ln_GDP_PC*10)
egen max_Tax_on_Goods_and_Services = max(Tax_on_Goods_and_Services) if year==2018, by(ln_GDP_PC_bin)
replace max_Tax_on_Goods_and_Services = max_Tax_on_Goods_and_Services+2
sort ln_GDP_PC
twoway (scatter Tax_on_Goods_and_Services ln_GDP_PC if year == 2018, mlabel (Country_Code) msize(small) title("`w' Taxes on Goods and Services", size(medium))) (scatter Tax_on_Goods_and_Services ln_GDP_PC if Country_Code=="`v'" & year == 2018, mlabel (Country_Code) mlabcolor(black) msize(small) mcolor(red)) (lowess max_Tax_on_Goods_and_Services ln_GDP_PC if year == 2018, lpattern(dash) lwidth(thin) lcolor(black) msymbol(i)) (lfit Tax_on_Goods_and_Services ln_GDP_PC if year==2018, lcolor(black) lwidth(thin)), legend(off) ytitle("(% of GDP)")

graph export "charts/`w' GST.png", replace

*7
*local v="BLR"
list Country_Code year  Tax_Effort_Excise_Taxes Tax_Capacity_Excise_Taxes Excise_Taxes Tax_Gap_Excise_Taxes if Country_Code=="`v'"

*gen ln_GDP_PC_bin = trunc(ln_GDP_PC*10)
egen max_Excise_Taxes= max(Excise_Taxes) if year==2018, by(ln_GDP_PC_bin)
replace max_Excise_Taxes = max_Excise_Taxes+2
sort ln_GDP_PC
twoway (scatter Excise_Taxes ln_GDP_PC if year == 2018, mlabel (Country_Code) msize(small) title("`w' Excise Tax")) (scatter Excise_Taxes ln_GDP_PC if Country_Code=="`v'" & year == 2018, mlabel (Country_Code) mlabcolor(black) msize(small) mcolor(red)) (lowess max_Excise_Taxes ln_GDP_PC if year == 2018, lpattern(dash) lwidth(thin) lcolor(black) msymbol(i)) (lfit Excise_Taxes ln_GDP_PC if year==2018, lcolor(black) lwidth(thin)), legend(off) ytitle("(% of GDP)")

graph export "charts/`w' Excise Tax.png", replace

sort Country_Code year
twoway (line Tax_Gap_Excise_Taxes  year if Country_Code=="`v'" & year>=1995), title("`w': Tax Gap Excise Tax") xlabel(1995 2000 2005 2010 2014 2018)
graph export "charts/`w' Tax Gap Composition.png", replace

save "IMF Revenue Database September 2020 - frontier.dta", replace
export excel using "IMF Tax Database 2020 with frontier.xlsx", firstrow(variables) replace


