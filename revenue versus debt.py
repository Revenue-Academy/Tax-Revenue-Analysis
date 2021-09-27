# -*- coding: utf-8 -*-
"""
Created on Thu Sep 24 22:05:58 2020

@author: wb305167
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

pd.set_option('display.max_rows', 50)  
pd.set_option('display.max_columns', None)
pd.set_option('max_colwidth', 50)
pd.set_option('display.precision', 2)
pd.set_option('display.expand_frame_repr', False)

filename = "Debt as percentage of GDP - WDI Sept 2020.xlsx"
sheetname = "work"

data = pd.read_excel(filename,sheetname, index_col=None, header=0)

