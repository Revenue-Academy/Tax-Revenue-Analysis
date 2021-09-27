# -*- coding: utf-8 -*-
"""
Created on Mon Jun 29 23:37:43 2020

@author: wb305167
"""

import pandas as pd
import numpy as np
import matplotlib as plt
import matplotlib.patches as mpatches
from fiscal_analysis_functions1 import *
from stata_python import *
from plot_charts import *

pd.set_option('display.max_rows', 50)  
pd.set_option('display.max_columns', 30)
pd.set_option('display.expand_frame_repr', False)
pd.set_option('max_colwidth', -1)
pd.set_option('max_colwidth', 800)
	
pd.set_option('display.precision', 3)

#pd.set_printoptions(precision=2)

df = pd.read_csv('nominal_monthly_tax_6_oct_2020.csv')

month_list = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug']
month_year_list = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul',
                   'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
num=0
for month in month_list:
    df['grmonth'+str(num)] = (df[month+'-20'] - df[month+'-19'])/df[month+'-19']
    num = num+1

num=0
for month in month_year_list:
    df = df.rename(columns={month+'-19':'revenue'+str(num)})
    num = num+1
for month in month_list:
    df = df.rename(columns={month+'-20':'revenue'+str(num)})
    num = num+1

num=0
for month in month_list:
    df['grmonth'+str(num)] = (df[month+'-20'] - df[month+'-19'])/df[month+'-19']
    num = num+1
    
df_long = pd.wide_to_long(df, stubnames='grmonth', i=['Country', 'Tax Type'], j='month')    
df_long = df_long.reset_index()

df_long.to_csv('nominal_monthly_tax_6_oct_2020_long.csv', index=False)    

country_name = 'Australia'
df_temp = df_long[(df_long['Country']==country_name)&(df_long['Tax Type']=='Tax Revenue')][['Country', 'Tax Type','month','grmonth']]

df_temp.plot(x='month', y='grmonth')

Region_Code = 'SA'
df_temp = df_long[(df_long['Region_Code']==Region_Code)&(df_long['Tax Type']=='Tax Revenue')][['Country', 'Region_Code', 'Tax Type','month','grmonth']]

df_temp.plot(x='month', y='grmonth')