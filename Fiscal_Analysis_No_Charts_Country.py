import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from fiscal_analysis_functions1 import *
from stata_python import *
from plot_charts import *


my_dpi=200
revenue_df = pd.read_csv('Government Revenue Dataset-augmented.csv')
country_df = pd.read_csv('country_code_updated.csv')

gdp_proj_df = pd.read_csv('World_Bank_GDP_Series_with_projections.csv')


pd.set_option('display.max_rows', None)
pd.set_option('display.max_columns', 7)
pd.set_option('display.width', None)
pd.set_option('display.max_colwidth', -1)
pd.set_option('precision', 2)
"""
pd.set_option('display.max_rows', 50)
pd.set_option('display.max_columns', 100)
pd.set_option('display.width', 1000)
pd.set_option('precision', 2)
"""

default_crisis_year = 2008
start_year = 2004
end_year = 2017
Regions = ["EAP","ECA","LAC","MENA","NAM","SA","SSA","WER"]
Region_desc = ["East Asia & Pacific","Eastern Europe & Central Asia",
         "Latin America & the Caribbean","Middle East & North Africa",
         "North America","South Asia","Sub-Saharan Africa","Western Europe"]
taxes = ['Total_Revenue_excl_SC', 'Tax_Revenue', 'Income_Taxes', 'Value_Added_Tax',
                    'Excise_Taxes', 'Trade_Taxes', 'Total_Non_Tax_Revenue']

taxes_LCU = [tax_type+'_LCU' for tax_type in taxes]

#taxes_gr = [tax_types+'_gr' for tax_types in taxes]

taxes_desc = ['Total Revenue', 'Tax Revenue', 'Income Taxes', 'VAT', 'Excise Taxes', 'Trade Taxes',
                'Non Tax Revenue']
taxes_tuple = ('Total Revenue', 'Income Taxes', 'VAT', 'Excise Taxes', 'Trade Taxes',
                'Non-Tax Revenue')
#taxes_shock = [tax_type+'_Shock' for tax_type in taxes_gr]

taxes_LCU_shock = [tax_type+'_Shock' for tax_type in taxes_LCU]

revenue_df['neg_govt_expenditure'] = -revenue_df['govt_expenditure']
parameters = ['GDP_Constant_USD', 'GDP_growth_rate', 'revenue_deficit', 'neg_govt_expenditure']

param_shock = [param_types+'_shock' for param_types in parameters]

parameters = parameters + taxes
param_shock = param_shock + taxes_LCU_shock
#Country_Codes = country_df['Country_Code'].values

buoyancy_max = 30
#Country_Codes = ['IND']
markers = ['.', '^', 'x', 's', '*', 'D', 'v', '8', 'X']
colors = ['r', 'b', 'y', 'm', 'c', 'k', 'g', '0.5']

#df_country_year = revenue_df.groupby(['Country_Code', 'year']).mean()
#df_country_year=df_country_year.reset_index()
df_country_2000=revenue_df[revenue_df['year']>=start_year]
df_country_2000=df_country_2000[df_country_2000['year']<=end_year]

#df_country_2000 = pd.merge(df_country_2000, country_df, how='inner', on='Country_Code', )
df_country_codes = revenue_df.groupby(['Country_Code']).mean()
df_country_codes=df_country_codes.reset_index()
Country_Codes = df_country_codes['Country_Code'].values.tolist()
#df_shock = create_dataframe(Country_Codes, 'Country_Code')
df_shock = create_dataframe(Country_Codes, 'Country_Code')
#df_shock = gen(df_shock, 'Total_Revenue_excl_SC')
for param in parameters:
    param_crisis = param + '_value_crisis'
    param_pre_crisis = param + '_value_pre_crisis'
    param_crisis_year = param + '_crisis_year'
    param_turn_around_year = param + '_turn_around_year'
    param_recovery_year_1_2 = param + '_recovery_year_1_2'
    param_recovery_year_3_4 = param + '_recovery_year_3_4'
    param_recovery_year = param + '_recovery_year'
    param_recovery_year_1_2_str = param + '_recovery_year_1_2_str'
    param_recovery_year_3_4_str = param + '_recovery_year_3_4_str'
    param_recovery_year_str = param + '_recovery_year_str'    
    param_crisis_shock = param + '_crisis_shock'
    param_recovery_time_1_2 = param + '_recovery_time_1_2'
    param_recovery_time_3_4 = param + '_recovery_time_3_4'
    param_recovery_time = param + '_recovery_time'  

    df_shock = gen(df_shock, param_crisis, default_value="")
    df_shock = gen(df_shock, param_pre_crisis, default_value="")
    df_shock = gen(df_shock, param_crisis_year, default_value="")
    df_shock = gen(df_shock, param_turn_around_year, default_value="")
    df_shock = gen(df_shock, param_recovery_year_1_2, default_value="")   
    df_shock = gen(df_shock, param_recovery_year_3_4, default_value="")
    df_shock = gen(df_shock, param_recovery_year, default_value="")
    df_shock = gen(df_shock, param_recovery_year_1_2_str, default_value="")   
    df_shock = gen(df_shock, param_recovery_year_3_4_str, default_value="")
    df_shock = gen(df_shock, param_recovery_year_str, default_value="")    
    df_shock = gen(df_shock, param_crisis_shock, default_value="")    
    df_shock = gen(df_shock, param_recovery_time_1_2, default_value="")   
    df_shock = gen(df_shock, param_recovery_time_3_4, default_value="")
    df_shock = gen(df_shock, param_recovery_time, default_value="") 
    
#Country_Codes = ['KOR']
for country_code in Country_Codes:
    df = df_country_2000[df_country_2000['Country_Code']==country_code]
    country_name = df['Country'].values[0]   
    #df_govt_spending_region = df.pivot(index='year', columns='Country_Code', values='govt_expenditure')
    #df_revenue_region = df.pivot(index='year', columns='Country_Code', values='Total_Revenue_excl_SC')
    for param in parameters:
        print('param1: ', param)
        pre_crisis_year = pre_crisis_yr(df, start_year, end_year, default_crisis_year, param)
        print(df[df['year']==pre_crisis_year][param].values[0])
        pre_crisis_trend = find_pre_crisis_trend(df, start_year, end_year, pre_crisis_year, param)
        recovery_year, recovery_year_str = find_recovery_year(df, end_year, pre_crisis_year, pre_crisis_trend, param)
        minimum_year, turn_around_year = find_turnaround_year(df, start_year, end_year, pre_crisis_year, recovery_year, param)
        (recovery_year_1_2, recovery_year_3_4, 
         recovery_year_1_2_str, recovery_year_3_4_str) = find_recovery_year_inter(df, end_year, pre_crisis_year, minimum_year, pre_crisis_trend, param)
        param_shock_value, pre_crisis_param_value, crisis_param_value = find_negative_shock(df, pre_crisis_trend, pre_crisis_year, recovery_year, 
                       minimum_year, turn_around_year, param)
        
        print('pre_crisis_year: ', pre_crisis_year)
        print('crisis_year: ', pre_crisis_year+1)
        print('recovery_year: ', recovery_year)
        print('minimum_year: ', minimum_year)
        print('turn_around_year: ', turn_around_year)
        print('pre_crisis_trend', pre_crisis_trend)
        print('crisis shock', param_shock_value)

        df_shock = replace(df_shock, param +'_value_crisis', crisis_param_value, 'Country_Code', country_code)
        df_shock = replace(df_shock, param +'_value_pre_crisis', pre_crisis_param_value, 'Country_Code', country_code)                
        df_shock = replace(df_shock, param +'_crisis_year', pre_crisis_year+1, 'Country_Code', country_code)
        df_shock = replace(df_shock, param +'_turn_around_year', turn_around_year, 'Country_Code', country_code)       
        df_shock = replace(df_shock, param +'_recovery_year_1_2', recovery_year_1_2, 'Country_Code', country_code)
        df_shock = replace(df_shock, param +'_recovery_year_3_4', recovery_year_3_4, 'Country_Code', country_code)
        df_shock = replace(df_shock, param +'_recovery_year', recovery_year, 'Country_Code', country_code)
        df_shock = replace(df_shock, param +'_recovery_year_1_2_str', recovery_year_1_2_str, 'Country_Code', country_code)
        df_shock = replace(df_shock, param +'_recovery_year_3_4_str', recovery_year_3_4_str, 'Country_Code', country_code)
        df_shock = replace(df_shock, param +'_recovery_year_str', recovery_year_str, 'Country_Code', country_code)        
        df_shock = replace(df_shock, param +'_crisis_shock', param_shock_value, 'Country_Code', country_code)
        
        recovery_time_1_2 = np.nan
        recovery_time_3_4 = np.nan
        recovery_time = np.nan
        if (not np.isnan(minimum_year)):
            recovery_time_1_2 = recovery_year_1_2 - (pre_crisis_year+1)
            recovery_time_3_4 = recovery_year_3_4 - (pre_crisis_year+1)
            recovery_time = recovery_year - (pre_crisis_year+1)

        df_shock = replace(df_shock, param +'_recovery_time_1_2', recovery_time_1_2, 'Country_Code', country_code)
        df_shock = replace(df_shock, param +'_recovery_time_3_4', recovery_time_3_4, 'Country_Code', country_code)
        df_shock = replace(df_shock, param +'_recovery_time', recovery_time, 'Country_Code', country_code)        


df_shock.to_csv("Fiscal Shocks Unmerged.csv")
df_shock_merged = pd.merge(df_shock, country_df, how="inner", on="Country_Code")
GDP_df = revenue_df[['Country_Code', 'year', 'ln_GDP_Constant_USD', 'ln_GDP_PC']+taxes]
df_shock_merged.to_csv("fiscal_shocks.csv")
df_shock_merged = pd.read_csv("fiscal_shocks.csv")
df_shock_merged = pd.merge(df_shock_merged, GDP_df, how="left", left_on=["Country_Code", 'GDP_growth_rate_crisis_year'], right_on=["Country_Code", 'year'])

df_shock_merged.columns=df_shock_merged.columns.str.replace('neg_govt_expenditure','govt_expenditure')
#df_shock_merged = df_shock_merged.rename(columns={'neg_govt_expenditure':'govt_expenditure'})
df_shock_merged['govt_expenditure_crisis_shock'] = -df_shock_merged['govt_expenditure_crisis_shock']
df_shock_merged['govt_expenditure_value_crisis'] = -df_shock_merged['govt_expenditure_value_crisis']
df_shock_merged['govt_expenditure_value_pre_crisis'] = -df_shock_merged['govt_expenditure_value_pre_crisis']
df_shock_merged = df_shock_merged.rename(columns={'Unnamed: 0':'Sno'})
df_shock_merged.to_csv("fiscal_shocks.csv", index=False)
df_shock_region = df_shock_merged.groupby(['Region_Code']).mean()
df_shock_region.to_csv("Fiscal Shock Region.csv", index=False)

df_shock_region = df_shock_merged.groupby(['Income_Group']).mean()
df_shock_region.to_csv("Fiscal Shock Income Group.csv", index=False)


"""
#df_shock_merged['ln_GDP_Constant_USD_value_pre_crisis'] = np.log(df_shock_merged['GDP_Constant_USD_value_pre_crisis'].astype(float))

ax = plot_scatter_chart_df(df_shock_merged, 'ln_GDP_PC', 'revenue_deficit_recovery_year_1_2',
                           label_category = 'Country_Code', y_decimal=0, x_decimal=1,color=colors[1], marker=markers[1])
ax = plot_scatter_chart_df(df_shock_merged, 'ln_GDP_Constant_USD', 'revenue_deficit_crisis_shock',
                           label_category = 'Country_Code', x_gap=1,
                           x_decimal=0, y_gap=4, y_decimal=0, color=colors[1],
                           marker=markers[1])
ax = plot_scatter_chart_df(df_shock_merged, 'ln_GDP_Constant_USD', 'revenue_deficit_crisis_shock',
                           label_category = 'Country_Code', color=colors[1],
                           marker=markers[1])
ax = plot_scatter_chart_df(df_shock_merged, 'ln_GDP_Constant_USD', 'Total_Revenue_excl_SC_turn_around_year',
                           label_category = 'Country_Code', color=colors[1], marker=markers[1])
plot_scatter_chart_df(df_shock_merged, 'ln_GDP_Constant_USD', 'neg_govt_expenditure_crisis_shock',
                           label_category = 'Country_Code', color=colors[0], marker=markers[0])

plot_scatter_chart_df(df_shock_merged, 'ln_GDP_Constant_USD', 'GDP_growth_rate_crisis_shock',
                           label_category = 'Country_Code', color=colors[0], marker=markers[0])
plot_scatter_chart_df(df_shock_merged, 'ln_GDP_PC', 'GDP_growth_rate_crisis_shock',
                           label_category = 'Country_Code', color=colors[0], marker=markers[0])

plot_line_chart_df(df_country_2000, 'year', 'GDP_growth_rate', 'Country_Code', 'IND')

df_shock_merged[['year', 'Country', 'Country_Code', 'Total_Revenue_excl_SC_recovery_year_1_2', 'Total_Revenue_excl_SC_recovery_year_3_4', 'Total_Revenue_excl_SC_recovery_year']].to_csv("Recovery Total Tax.csv")
"""
"""
Country_Codes = df_country_codes['Country_Code'].values.tolist()
#Country_Codes=['UZB']
for country_code in Country_Codes:
    tol = 30
    #df1 = df_country_2000[(df_country_2000['Country_Code']==country_code)]
    df1 = df_country_2000[(df_country_2000['Country_Code']==country_code)]
    for param in taxes:
        #print(df1[['year', param, param+'_bu']])
        df2 = df1[df1[param+'_bu']<=buoyancy_max]
        mean_bu = (df2[(df2['year']<crisis_year) | (df2['year']>turn_around_year+1)][param+'_bu'].dropna()).values.mean()
        mean_bu_crisis = (df2[(df2['year']>=crisis_year) & (df2['year']<=turn_around_year+1)][param+'_bu'].dropna()).values.mean()
        print('Country: ', country_code, param, 'mean buoyancy: ', mean_bu, 'mean buoyancy crisis: ', mean_bu_crisis)
        

#x_ticks = np.linspace(start_year,end_year,end_year-start_year+1)

ax = plot_line_chart_df(df_country_2000, 'year', 'GDP_LCU',
                        'Country_Code', 'ATG', x_line=2008)
plot_line_chart_df(df_country_2000, 'year', 'Value_Added_Tax_LCU',
                        'Country_Code', 'ATG', x_line=2008)
plot_line_chart_df(df_country_2000, 'year', 'Total_Revenue_excl_SC_LCU',
                        'Country_Code', 'IDN')

plot_line_chart_df(df_country_2000, 'year', 'GDP_LCU',
                        'Country_Code', 'IND', ax=ax)

plot_line_chart_df(df_country_2000, 'year', 'GDP_LCU',
                        'Region_Code', 'EAP')

"""