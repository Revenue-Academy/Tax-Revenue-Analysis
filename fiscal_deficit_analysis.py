# -*- coding: utf-8 -*-
"""
Created on Fri Jan 29 12:44:05 2021

@author: wb305167
"""
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

import os,sys
sys.path.insert(1, os.path.join(sys.path[0], '..'))

from stata_python import *


pd.set_option('display.max_rows', 50)  
pd.set_option('display.max_columns', 10)
pd.set_option('display.expand_frame_repr', False)
#pd.set_option('max_colwidth', -1)
pd.set_option('max_colwidth', 40)
pd.set_option('display.precision', 2)


datafilename = "WEOOct2020all.xlsx"
df = pd.read_excel(datafilename,"WEOOct2020all", index_col=None, header=0)

df = df.rename(columns={'Subject Descriptor': 'Parameter'})
df = df.rename(columns={'WEO Subject Code': 'Parameter_Code'})

for i in range(1980,2026):
    df = df.rename(columns={i:'data'+str(i)})

df = pd.wide_to_long(df, stubnames='data', i=['ISO', 'Parameter', 'Units'], j='year')
df = df.reset_index()

df = df[['ISO', 'year', 'Country', 'Parameter', 'Parameter_Code', 'Units', 'Scale', 
         'Estimates Start After', 'data']]

datafilename = "country_code_updated.xls"
df_country = pd.read_excel(datafilename,"country_code", index_col=None, header=0)

df = df.rename(columns={'Country': 'Country1'})
df = df.rename(columns={'ISO': 'Country_Code'})


"""
PCPI    Inflation, average consumer prices
PPPEX   Implied PPP conversion rate  National currency per current intern
GGX     General government total expenditure  National currency
GGR     General government revenue  National currency
NGDP	  Gross domestic product, current prices	National currency	Billions
NGDPD   Gross domestic product, current prices	 U.S. dollars Billions

"""
df = df.pivot(index=['Country_Code','year'], columns='Parameter_Code', values='data')
df = df.reset_index()
cols = [x for x in df.columns.values if x not in ['Country_Code', 'year']]
df[cols] = df[cols].apply(pd.to_numeric, errors='coerce')
df = pd.merge(df, df_country, on='Country_Code', how="inner", indicator=True)

df.to_csv('WEOOct2020_long.csv')

df1 = df[['Country_Code', 'year', 'NGDP', 'NGDPD', 'GGR', 'GGX', 'PCPI', 'PPPEX']]

df2 = egen(df1, 'PCPI_2020', 'PCPI', 'Country_Code', 'value_of', 'year', 2020)

df2['PCPI_2020_multiplier'] = df2['PCPI_2020']/df2['PCPI']

df2['GGR_in_2020_LCU'] = df2['GGR']*df2['PCPI_2020_multiplier']
df2['GGX_in_2020_LCU'] = df2['GGX']*df2['PCPI_2020_multiplier']
df2['EX_RATE'] = df2['NGDP']/df2['NGDPD']

df2['GGR_in_2020_USD'] = df2['GGR_in_2020_LCU']/df2['EX_RATE']
df2['GGX_in_2020_USD'] = df2['GGX_in_2020_LCU']/df2['EX_RATE']

df2['Fiscal_Deficit_in_2020_USD'] = df2['GGX_in_2020_USD'] - df2['GGR_in_2020_USD']

df3 = df2[df2['year']>=2014].copy()

df4 = egen(df3, 'Avg_Fiscal_Deficit_Pre_2019', 'Fiscal_Deficit_in_2020_USD', 'Country_Code', 'mean', 'year', 2019, '<')

df4['Excess_Fiscal_Deficit'] = np.where(df4['year']<=2019,0,
                                        (df4['Fiscal_Deficit_in_2020_USD'] 
                                         - df4['Avg_Fiscal_Deficit_Pre_2019']))

df4[df4['Country_Code']=='IND'][['year', 'Fiscal_Deficit_in_2020_USD']].plot.scatter(x='year', y='Fiscal_Deficit_in_2020_USD')

# estimating the excess just for 2020 and 2021
df4 = egen(df4, 'Excess_Fiscal_Deficit_2020', 'Excess_Fiscal_Deficit', 'Country_Code', 'value_of', 'year', 2020)
df4 = egen(df4, 'Excess_Fiscal_Deficit_2021', 'Excess_Fiscal_Deficit', 'Country_Code', 'value_of', 'year', 2021)
df4['Excess_Fiscal_Deficit_2020_2021'] = df4['Excess_Fiscal_Deficit_2020']+df4['Excess_Fiscal_Deficit_2021']

df4 = pd.merge(df4, df_country, on='Country_Code', how='inner')
df4.to_csv('Excess Fiscal Deficit.csv', index=False)

df5 = df4[df4['Country_Code']!='SSD']
df5 = df5[df5['Country_Code']!='SDN']
df5 = df5[df5['Country_Code']!='ZWE']

# we only need one record as the amount is repeated
df5 = df5[df5['year']==2020]

df6 = df5.groupby(by='IBRD_IDA')['Excess_Fiscal_Deficit_2020_2021'].sum()
df6

"""
Country_Code = 'ZAF'
df4[df4['Country_Code']==Country_Code][['year', 'Country_Code', 'Fiscal_Deficit_in_2020_USD', 'Avg_Fiscal_Deficit_Pre_2019', 'Excess_Fiscal_Deficit']]



fig,ax = plt.subplots()
df5[df5['Country_Code']==Country_Code][['year', 'Fiscal_Deficit_in_2020_USD']].plot.line(ax=ax, x='year', y='Fiscal_Deficit_in_2020_USD')

# we drop the year 2019 as strangely it shows a COVID response
# in many countries though COVID only happened in 2020

x = df5[(df5['Country_Code']==Country_Code)&(df5['year']<2019)]['year']
y = df5[(df5['Country_Code']==Country_Code)&(df5['year']<2019)]['Fiscal_Deficit_in_2020_USD']

import numpy.polynomial.polynomial as poly
x_new = np.linspace(2013, 2025, num=11)
coefs = poly.polyfit(x, y, 1)
ffit = poly.polyval(x_new, coefs)
plt.plot(x_new, ffit)
"""














