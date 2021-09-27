# -*- coding: utf-8 -*-
"""
Created on Mon Jun 29 23:37:43 2020

@author: wb305167
"""

import pandas as pd
import numpy as np
import matplotlib as plt
import matplotlib.patches as mpatches
#from fiscal_analysis_functions1 import *
#from stata_python import *
#from plot_charts import *




pd.set_option('display.max_rows', 10)  
pd.set_option('display.max_columns', 7)
pd.set_option('display.expand_frame_repr', False)
#pd.set_option('max_colwidth', -1)
pd.set_option('max_colwidth', 20)
pd.set_option('display.precision', 2)

#pd.set_printoptions(precision=2)

#df = pd.read_csv('nominal_monthly_tax_6_oct_2020.csv')

df_curr_USD = pd.read_excel("GDP Current USD - Nov 2020.xlsx","Sheet1", index_col=None, header=0)
df_curr_USD = df_curr_USD[['year','Country_Code', 'GDP_Curr_USD']]
df_curr_LCU = pd.read_excel("GDP Current LCU - Nov 2020.xlsx","Sheet1", index_col=None, header=0)
df_curr_LCU = df_curr_LCU[['year','Country_Code', 'GDP_Curr_LCU']]
df_conv_factor = pd.merge(df_curr_USD, df_curr_LCU, how="inner", on=['year', 'Country_Code'])
df_conv_factor['LCU_USD_ex_rate'] = df_conv_factor['GDP_Curr_USD']/df_conv_factor['GDP_Curr_LCU']

df_conv_factor.to_csv('Exchange Rates.csv', index=False) 

df_conv_factor = df_conv_factor[df_conv_factor['year']==2019]

# Data File created in STATA Quarterly GDP Jan 2021
datafilename = 'Quarterly_GDP_jan_2020.xlsx'
df_quarterly_GDP = pd.read_excel(datafilename,"Sheet1", index_col=None, header=0)
df_quarterly_GDP = df_quarterly_GDP[['Country_Code', 'gdp_2019Q1', 'gdp_2019Q2', 'gdp_2019Q3',
                                     'gdp_2019Q4', 'gdp_2020Q1', 'gdp_2020Q2',
                                     'gdp_2020Q3']]
df_quarterly_GDP['gdp_2019H1'] = df_quarterly_GDP['gdp_2019Q1']+df_quarterly_GDP['gdp_2019Q2']
df_quarterly_GDP['gdp_2019H2'] = df_quarterly_GDP['gdp_2019Q3']+df_quarterly_GDP['gdp_2019Q4']
df_quarterly_GDP['gdp_2020H1'] = df_quarterly_GDP['gdp_2020Q1']+df_quarterly_GDP['gdp_2020Q2']

df_quarterly_GDP['gdp_2019'] = df_quarterly_GDP['gdp_2019H1']+df_quarterly_GDP['gdp_2019H2']

"""
df_quarterly_GDP = df_quarterly_GDP.rename(columns={'data_2019Q1':'gdp_2019Q1', 
                                                   'data_2019Q2':'gdp_2019Q2',
                                                   'data_2019Q3':'gdp_2019Q3',
                                     'data_2019Q4':'gdp_2019Q4', 
                                     'data_2020Q1':'gdp_2020Q1', 
                                     'data_2020Q2':'gdp_2020Q2',
                                     'data_2020Q3':'gdp_2020Q3'})
"""


datafilename = "Tax Collection 2020-2019 - Real - 17-Feb-2021.xlsx"
df = pd.read_excel(datafilename,"Nominal", index_col=None, header=0)

df = df.fillna(0)

df['tax_2019Q1'] = df['Jan-19']+df['Feb-19']+df['Mar-19']
df['tax_2019Q2'] = df['Apr-19']+df['May-19']+df['Jun-19']
df['tax_2019Q3'] = df['Jul-19']+df['Aug-19']+df['Sep-19']
df['tax_2019Q4'] = df['Oct-19']+df['Nov-19']+df['Dec-19']
df['tax_2020Q1'] = df['Jan-20']+df['Feb-20']+df['Mar-20']
df['tax_2020Q2'] = df['Apr-20']+df['May-20']+df['Jun-20']
df['tax_2020Q3'] = df['Jul-20']+df['Aug-20']+df['Sep-20']

df['tax_2019H1'] = df['tax_2019Q1']+df['tax_2019Q2']
df['tax_2019H2'] = df['tax_2019Q3']+df['tax_2019Q4']
df['tax_2020H1'] = df['tax_2020Q1']+df['tax_2020Q2']

df['tax_2019'] = df['tax_2019H1']+df['tax_2019H2']


df = pd.merge(df, df_quarterly_GDP, how="inner", on="Country_Code")

df['factor']=1
df['factor'] = np.where(df['Units(LCU)'] == 'thousand lcu',1000,df['factor'])
df['factor'] = np.where(df['Units(LCU)'] == 'mill lcu',1000000,df['factor'])
df['factor'] = np.where(df['Units(LCU)'] == 'bill lcu',1000000000,df['factor'])  

df['tax_gdp_2019Q1'] = ((df['tax_2019Q1']*df['factor'])/(df['gdp_2019Q1']*1000000))*100
df['tax_gdp_2019Q2'] = ((df['tax_2019Q2']*df['factor'])/(df['gdp_2019Q2']*1000000))*100
df['tax_gdp_2019Q3'] = ((df['tax_2019Q3']*df['factor'])/(df['gdp_2019Q3']*1000000))*100
df['tax_gdp_2019Q4'] = ((df['tax_2019Q4']*df['factor'])/(df['gdp_2019Q4']*1000000))*100
df['tax_gdp_2020Q1'] = ((df['tax_2020Q1']*df['factor'])/(df['gdp_2020Q1']*1000000))*100
df['tax_gdp_2020Q2'] = ((df['tax_2020Q2']*df['factor'])/(df['gdp_2020Q2']*1000000))*100
df['tax_gdp_2020Q3'] = ((df['tax_2020Q3']*df['factor'])/(df['gdp_2020Q3']*1000000))*100

df['tax_gdp_2019H1'] = ((df['tax_2019H1']*df['factor'])/(df['gdp_2019H1']*1000000))*100
df['tax_gdp_2019H2'] = ((df['tax_2019H2']*df['factor'])/(df['gdp_2019H2']*1000000))*100
df['tax_gdp_2020H1'] = ((df['tax_2020H1']*df['factor'])/(df['gdp_2020H1']*1000000))*100
   
df['tax_gdp_2019'] = ((df['tax_2019']*df['factor'])/(df['gdp_2019']*1000000))*100

df.to_csv('real_monthly_tax_to_GDP_17_feb_2021_quarterly.csv', index=False)

df_LAC = pd.read_excel(datafilename,"LAC", index_col=None, header=0)

df_inflation = pd.read_excel(datafilename,"Inflation", index_col=None, header=0)

df_inflation['Inflation_per_2020'] = df_inflation['Inflation_2020']/100

df_inflation = df_inflation[['Country_Code','Inflation_per_2020']]

df = pd.merge(df, df_inflation, how="inner", on="Country_Code")

df = pd.merge(df, df_conv_factor, how="inner", on=['Country_Code'])

month_list_2020 = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep']
month_list_2019 = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul',
                   'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

for month in month_list_2019:
    df[month+'-19_real'] = df[month+'-19']*(1+df['Inflation_per_2020'])
  
num=1
for month in month_list_2020:
    df['grmonth'+str(num+12)] = (df[month+'-20'] - df[month+'-19_real'])/df[month+'-19_real']
    num = num+1
        
num=1
for month in month_list_2019:
    df = df.rename(columns={month+'-19':'revenue'+str(num)})
    num = num+1
for month in month_list_2020:
    df = df.rename(columns={month+'-20':'revenue'+str(num)})
    num = num+1
    
filter_col1 = ['Country', 'Country_Code', 'Region_Code', 'Income_Group', 'IDA',
       'Tax_Type', 'Units(LCU)', 'LCU_USD_ex_rate']
#df.to_csv('df.csv')
filter_col2 = [col for col in df.columns if col.startswith(('revenue','grmonth'))]

filter_cols = filter_col1 + filter_col2

df = df[filter_cols]
df['revenue_diff_percent_LAC']=np.nan

#concat/attach files one below the other

frames = [df, df_LAC]
df = pd.concat(frames)

#df.to_csv('concatenated.csv', index=False)  

df_LAC = df_LAC[['Country_Code', 'Tax_Type', 'revenue_diff_percent_LAC']]

#df_long['revenue_prev_yr_USD'] = df_long.groupby(['Country_Code']).mean()

df.drop('revenue_diff_percent_LAC', axis=1, inplace=True)
   
df_long = pd.wide_to_long(df, stubnames=['revenue','grmonth'], i=['Country', 'Tax_Type'], j='month')    
df_long = df_long.reset_index()

df_long['revenue_USD'] = df_long['revenue']*df_long['LCU_USD_ex_rate']

df_long['revenue_prev_yr'] = df_long.groupby(['Country_Code', 'Tax_Type'])['revenue'].shift(12)

df_long['revenue_prev_yr_USD'] = df_long.groupby(['Country_Code', 'Tax_Type'])['revenue_USD'].shift(12)

df_long['revenue_diff'] = df_long['revenue'] - df_long['revenue_prev_yr']

df_long['revenue_diff_USD'] = df_long['revenue_USD'] - df_long['revenue_prev_yr_USD']

df_long['year'] = np.where(df_long['month']<=12,2019,2020)

df_long['outlier'] = 0

import calendar
d = dict(enumerate(calendar.month_abbr))
d[0]='Dec'
df_long['cal_month'] = ((df_long['month']%12)).map(d)

# merge in the total revenue growth percentage into the main database
df_long = pd.merge(df_long, df_LAC, how="left", on=['Country_Code', 'Tax_Type'])

df_long.to_csv('real_monthly_tax_17_feb_2021_long.csv', index=False)  

"""
df_long_grp = df_long.groupby(['Country_Code', 'Tax_Type'])[['revenue_prev_yr','revenue_diff']].sum()
df_long_grp = df_long_grp.reset_index()
df_long_grp = df_long_grp.rename(columns={'revenue_prev_yr':'tot_revenue_prev_yr', 'revenue_diff':'tot_revenue_diff'})
df_long_grp['revenue_diff_percent'] = df_long_grp['tot_revenue_diff']/df_long_grp['tot_revenue_prev_yr']
df_long=pd.merge(df_long, df_long_grp, how="inner", on=['Country_Code', 'Tax_Type'])


country_name = 'Australia'
df_temp = df_long[(df_long['Country']==country_name)&(df_long['Tax Type']=='Tax Revenue')][['Country', 'Tax Type','month','grmonth']]

df_temp.plot(x='month', y='grmonth')

Region_Code = 'SA'
df_temp = df_long[(df_long['Region_Code']==Region_Code)&(df_long['Tax Type']=='Tax Revenue')][['Country', 'Region_Code', 'Tax Type','month','grmonth']]

df_temp.plot(x='month', y='grmonth')
"""