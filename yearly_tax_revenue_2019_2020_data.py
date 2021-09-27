# -*- coding: utf-8 -*-
"""
Created on Sun Feb 28 17:08:52 2021

@author: wb305167
"""
from stata_python import * 
import pandas as pd
import numpy as np

countries = ['Afghanistan', 'Angola', 'Burkina Faso', 'Burundi', 'Cabo Verde', 'Cameroon', 'Central African Republic',
             'Chad', 'Comoros', 'Congo Republic of', 'Cote d Ivore', 'Democratic Republic of Congo','Djibouti',
             'Dominica', 'Ethiopia', 'Fiji', 'Gambia', 'Grenada', 'Guinea', 'Guinea-Bissau', 'Kenya',
             'Lesotho', 'Madagascar', 'Malawi', 'Maldives', 'Mali', 'Mauritania', 'Mozambique', 'Myanmar',
             'Nepal', 'Niger', 'Pakistan', 'Papua New Guinea', 'Samoa', 'Sao Tome and Principe', 'Senegal',
             'Sierra Leone', 'St Lucia', 'St Vincent', 'Tajikistan', 'Tanzania', 'Togo', 'Tonga', 'Uganda',
             'Yemen', 'Zambia']
column_names = ['Country_Name','Tax-GDP 2019', 'Tax-GDP 2020']
df = pd.DataFrame(columns = column_names)
for i in range(len(countries)):
    df1 = pd.read_excel (r'DSSI Tax GDP data\DSSI fiscal monitoring_template_'+countries[i]+'.xlsx')
    df = pd.concat([df, pd.DataFrame([[np.nan] * df.shape[1]], columns=df.columns)], ignore_index=True)
    df.loc[i, 'Country_Name'] = df1.columns[1]
    print(df1.columns[1])
    if (df1['Country name:'].iloc[51]=='Nominal GDP'):
        nominal_GDP_2019 = df1['Unnamed: 4'].iloc[51]
        nominal_GDP_2020 = df1['Unnamed: 7'].iloc[51]
    if (df1['Country name:'].iloc[5]=='Tax revenue'):
        tax_revenue_2019 = df1['Unnamed: 4'].iloc[5]
        tax_revenue_2020 = df1['Unnamed: 7'].iloc[5]
        
    df.loc[i, 'Tax-GDP 2019']= tax_revenue_2019/nominal_GDP_2019
    df.loc[i, 'Tax-GDP 2020']= tax_revenue_2020/nominal_GDP_2020
    
#df.to_csv('DSSI Tax Revenue Data.csv', index=False)

df = replace(df, 'Country_Name', 'Cape Verde', 'Country_Name', 'Cabo Verde')
df = replace(df, 'Country_Name', 'Congo, Rep.', 'Country_Name', 'Congo, Republic of')
df = replace(df, 'Country_Name', "Cote d'Ivoire", 'Country_Name', "Côte d'Ivoire")
df = replace(df, 'Country_Name', 'Congo, Dem. Rep.', 'Country_Name', 'Congo, Democratic Republic of the')
df = replace(df, 'Country_Name', 'Gambia, The', 'Country_Name', 'Gambia')
df = replace(df, 'Country_Name', 'Sao Tome and Principe', 'Country_Name', 'São Tomé and Príncipe')
df = replace(df, 'Country_Name', 'Yemen, Rep.', 'Country_Name', 'Yemen')

df_country = pd.read_excel("country_code_updated.xls","country_code", index_col=None, header=0)
df_country = df_country.rename(columns={'Country':'countryname'})

df_country1 = df_country[['Country_Name', 'Country_Code']]

df = pd.merge(df, df_country1, on='Country_Name', how='left', indicator=True)

df.to_csv('DSSI Tax Revenue Data.csv', index=False)