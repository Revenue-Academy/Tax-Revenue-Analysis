# -*- coding: utf-8 -*-
"""
Created on Tue Dec  1 14:56:09 2020

@author: wb305167
"""

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
my_dpi=300

filename = 'IMF Tax Database 2020 with frontier.xlsx'
path = 'C:/Users/wb305167/OneDrive - WBG/python_latest/Charts/'

revenue_df = pd.read_excel(path+filename,sheet_name="Sheet1", index_col=None, header=0)

revenue_df_small = revenue_df[['year', 'Country_Code', 'CountryName', 'Region_Code', 'Income_Group', 'IDA', 'ln_GDP_PC', 'rev', 'tax', 'inc', 'indv', 'corp', 'pay', 'propr', 'goods', 'vat', 'genr', 'excises', 'trade_tax', 'other_tax', 'soc', 'grants']]

#revenue_df_small = revenue_df[revenue_df['year']==2018][['Country_Code', 'CountryName', 'Region_Code', 'Income_Group', 'IDA', 'rev', 'tax', 'inc', 'indv', 'corp', 'pay', 'propr', 'goods', 'vat', 'genr', 'excises', 'trade_tax', 'soc', 'grants']]

revenue_df_small = revenue_df_small.rename(columns={'indv':'PIT', 'soc':'Social_Contributions'})
#revenue_df = pd.read_csv('Government Revenue Dataset-augmented.csv')

country = 'BLR'
year = 2017
revenue_df_2017 =  revenue_df_small[revenue_df_small['year']==year]
revenue_df_2017 =  revenue_df_2017.drop('year', axis=1)

revenue_df_2017['Region_Code_1'] = revenue_df_2017['Region_Code']
revenue_df_2017['Region_Code_1'] = np.where(revenue_df_2017['Country_Code']==country, country, revenue_df_2017['Region_Code'])

plt.style.use('fivethirtyeight')
#import seaborn as sns
#sns.set_style("dark")
plt.style.use('seaborn-whitegrid')

plt.style.use('default')

figw, figh = 16.0, 8.0
fig, ax = plt.subplots(ncols=1, nrows=1, sharex=True, sharey=True,
                         figsize=(figw, figh))
plt.subplots_adjust(left=1/figw, right=1-1/figw, bottom=1/figh, top=1-1/figh)

fig, ax = plt.subplots()


revenue_region_1_df = revenue_df_2017.groupby(['Region_Code_1'])[['rev', 'tax', 'inc', 'PIT', 'corp', 'pay', 'propr', 'goods', 'vat', 'excises', 'trade_tax', 'other_tax', 'Social_Contributions']].mean()
ax = revenue_region_1_df[['PIT', 'corp', 'vat', 'excises', 'trade_tax', 'Social_Contributions']].plot(kind="bar")
ax.set_xlabel('')
ax.set_ylabel('% of GDP')
lgd = ax.legend(['PIT', 'CIT', 'VAT', 'Excises', 'Trade Taxes', 'Soc Contr'], bbox_to_anchor=(1.0, 1.0))

filename='tax_collection_region.png'

plt.tight_layout(pad=2)

#plt.savefig('samplefigure', bbox_extra_artists=(lgd), bbox_inches='tight')

#plt.subplots_adjust(right=0.9)

plt.savefig(path+filename, dpi=my_dpi)

