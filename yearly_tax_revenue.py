# -*- coding: utf-8 -*-
"""
Created on Sun Feb 28 17:08:52 2021

@author: wb305167
"""
from stata_python import * 
import pandas as pd
import numpy as np

df_country = pd.read_excel("country_code_updated.xls","country_code", index_col=None, header=0)
df_country = df_country.rename(columns={'Country':'countryname'})
filename = 'GDP Per Capita Constant USD Sept 2021.xls'
sheetname='Sheet1'
df_gdp_pc = convert_WDI_file(filename, sheetname, 'GDP_PC_Constant_USD')
df_gdp_pc['ln_GDP_PC_Constant_USD'] = np.log(df_gdp_pc['GDP_PC_Constant_USD'])

filename = 'GDP Current LCU Sept 2021.xls'
df_gdp_lcu = convert_WDI_file(filename, sheetname, 'GDP_Current_LCU')

filename = 'GDP Constant 2010 USD Sept 2021.xls'
df_gdp_constant_usd = convert_WDI_file(filename, sheetname, 'GDP_Constant_USD')

df_gdp = pd.merge(df_gdp_pc, df_gdp_lcu, how='left', on=['Country_Code', 'year'])
df_gdp = pd.merge(df_gdp, df_gdp_constant_usd, how='left', on=['Country_Code', 'year'])

df_gdp.to_csv('gdp_data.csv', index=False)

df_data_update = pd.read_excel("Country Data Update March 2020.xlsx", sheet_name="revenue_for_WRD", index_col=None, header=0)
#df_data_update = pd.read_excel("Country Data Update March 2020.xlsx", sheet_name="revenue_for_IMF_%", index_col=None, header=0)

df_data_update.to_csv('tax_revenue_update_27_april_2021.csv', index=False)

df_revenue_data = pd.read_excel("Government Revenue Dataset - August-2021 - work.xlsx", sheet_name="work", index_col=None, header=0)
#df_revenue_data = pd.read_excel("IMF Revenue Database 2020.xlsx", sheet_name="Sheet1", index_col=None, header=0)
#df_revenue_data = pd.read_excel("IMF Tax Database 2020 with frontier.xlsx", sheet_name="Sheet1", index_col=None, header=0)



df_revenue_data = df_revenue_data.rename(columns={'ISO':'Country_Code',
                                             'Year': 'year'})


#relevant for UNU Wider dataset
df_revenue_data['Total_Revenue'] = np.where(df_revenue_data['Total_Revenue_excl_SC']==np.nan,df_revenue_data['Tax_Revenue']+df_revenue_data['Total_Non_Tax_Revenue'],df_revenue_data['Total_Revenue_excl_SC'])

keep_vars = ['year', 'Country_Code', 'Country', 'Tax_Revenue', 'Total_Non_Tax_Revenue', 
             'Total_Revenue','Total_Revenue_excl_SC', 'Direct_Taxes', 'Income_Taxes', 'PIT', 'CIT', 'Indirect_Taxes', 
             'Tax_on_Goods_and_Services', 'Value_Added_Tax', 'Excise_Taxes', 
             'Trade_Taxes', 'Social_Contributions', 'Property_Tax', 
             'Other_Taxes', 'Resource_Taxes', 'Non_Res_Tax_Rev_incl_SC', 
             'Non_Res_Tax_Rev_excl_SC', 'Export_Taxes', 'Import_Taxes']

# now replace 0.0% values as np.nan
df_revenue_data[keep_vars]=df_revenue_data[keep_vars].replace(0, np.nan)

keep_vars1 = ['year', 'Country_Code']
keep_vars2 = ['Total_Revenue', 'Tax_Revenue', 'Income_Taxes', 'PIT', 'CIT',  
             'Tax_on_Goods_and_Services', 'Value_Added_Tax', 'Excise_Taxes', 
             'Trade_Taxes', 'Social_Contributions', 'Property_Tax', 
             'Other_Taxes', 'Direct_Taxes', 'Indirect_Taxes', 'Total_Non_Tax_Revenue']
keep_vars2_adj = ['Tax_Revenue', 'Income_Taxes', 'PIT', 'CIT',  
             'Tax_on_G_and_S', 'Value_Added_Tax', 'Excise_Taxes', 
             'Trade_Taxes', 'Social_Contributions', 'Property_Tax', 
             'Other_Taxes']
keep_vars3 = ['Tax_Capacity_'+i for i in keep_vars2]
keep_vars4 = ['Tax_Gap_'+i for i in keep_vars2]
keep_vars5 = ['ln_GDP_PC_bin']
keep_vars6 = ['max_'+i for i in keep_vars2]

keep_vars_main = (keep_vars1 + keep_vars2)
keep_vars_frontier = (keep_vars3 + keep_vars4 + keep_vars5 + keep_vars6)

df_data_update['Total_Revenue'] = np.where(df_data_update['Total_Revenue_excl_SC']==np.nan,df_data_update['Tax_Revenue']+df_data_update['Total_Non_Tax_Revenue'],df_data_update['Total_Revenue_excl_SC'])
df_data_update = df_data_update[keep_vars_main]

#df_revenue_data = stata_merge(df_revenue_data, df_data_update, 'year', 'Country_Code')

df_revenue_data1 = stata_merge_update_all_fields_full(df_revenue_data, df_data_update, 'year', 'Country_Code')

#df_revenue_data_frontier = df_revenue_data1[keep_vars_frontier]

df_revenue_data1 = df_revenue_data1[keep_vars_main]

"""
df_revenue_data1 =  stata_merge_update_all_fields_full(df_revenue_data, df_data_update, 'year', 'Country_Code', 
                                       merge_type='left', overwrite=True,
                                       indicator=False)
"""    
#df_revenue_data = replace(df_revenue_data, 'Total_Non_Tax_Revenue', 1.0, 'Country_Code', 'ASM')

#df_revenue_data['Value_Added_Tax'] = np.where((df_revenue_data['Country_Code']=="PAK") & (df_revenue_data['Value_Added_Tax'].isnull()), df_revenue_data['Tax_on_Goods_and_Services']-df_revenue_data['Excise_Taxes'], df_revenue_data['Value_Added_Tax'])      

df_revenue_data1['Value_Added_Tax'] = np.where((df_revenue_data1['Country_Code']=="PAK") & (df_revenue_data1['Value_Added_Tax'].isnull()), df_revenue_data1['Tax_on_Goods_and_Services']-df_revenue_data1['Excise_Taxes'], df_revenue_data1['Value_Added_Tax'])      

df_revenue_data1[df_revenue_data1==0.0] = np.nan

#df_revenue_data2 = stata_merge(df_revenue_data1, df_country, 'Country_Code')

df = pd.merge(df_gdp_lcu, df_gdp_constant_usd, on=['Country_Code', 'year'], how="outer", indicator=True )
df.drop(['_merge'], axis=1, inplace=True)
df['year'] = df['year'].astype(np.int64)

df_revenue_data1 = pd.merge(df_revenue_data1, df, on=['Country_Code', 'year'], how="left", indicator=True )
df_revenue_data1.drop(['_merge'], axis=1, inplace=True)

df_revenue_data1['Tax_Revenue_real_USD'] = df_revenue_data1['Tax_Revenue']*df_revenue_data1['GDP_Constant_USD']

df_revenue_data1['Tax_Revenue_current_LCU'] = df_revenue_data1['Tax_Revenue']*df_revenue_data1['GDP_Current_LCU']

df_revenue_data1 = df_revenue_data1.sort_values(by=['Country_Code', 'year'])

df_revenue_data1['Tax_Revenue_real_USD_lag'] = df_revenue_data1.groupby(['Country_Code'])['Tax_Revenue_real_USD'].shift(1)
 
df_revenue_data1['gr_Tax_Revenue'] = (df_revenue_data1['Tax_Revenue_real_USD']/df_revenue_data1['Tax_Revenue_real_USD_lag'])-1

df_revenue_data1.drop(['Tax_Revenue_real_USD_lag'], axis=1, inplace=True)
df_revenue_data1['outlier'] = 0
df_revenue_data1.to_csv('tax_revenue_24_sept_2021.csv', index=False)

#df_revenue_data_frontier.to_csv('tax_revenue_frontier_16_aug_2021.csv', index=False)

#df_revenue_data2 = pd.merge(df_revenue_data1, df_country[['Country_Code', 'Region_Code', 'IDA_IBRD']], on='Country_Code', how='left')
#df_revenue_data2[(df_revenue_data2['year']==2018) | (df_revenue_data2['year']==2019)][['Country_Name', 'year', 'Country_Code', 'Region_Code', 'IDA_IBRD', 'Tax_Revenue']].to_csv('tax_revenue_2019.csv', index=False)