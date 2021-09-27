# -*- coding: utf-8 -*-
"""
Created on Sat Mar 27 13:56:29 2021

@author: wb305167
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from fiscal_analysis_functions1 import *
from stata_python import *
from plot_charts import *

filename = "GDP - Constant 2010 USD - March 2021.xls"
sheetname = "Sheet1"
parameter = 'GDP_constant_USD'
df_gdp_constant_usd = convert_WDI_file(filename, sheetname, parameter)

filename = "GDP - Current LCU - March 2021.xls"
sheetname = "Sheet1"
parameter = 'GDP_current_LCU'
df_gdp_current_lcu = convert_WDI_file(filename, sheetname, parameter)

df = pd.merge(df_gdp_current_lcu, df_gdp_constant_usd, on=['Country_Code', 'year'], how="outer", indicator=True )
df.drop(['_merge'], axis=1, inplace=True)

df.to_csv('gdp_current_and_constant_march_2021.csv', index=False)

browse(df)



