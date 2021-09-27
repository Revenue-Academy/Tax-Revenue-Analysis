# -*- coding: utf-8 -*-
"""
Created on Thu Mar 26 18:51:40 2020

@author: wb305167
"""

import pandas as pd
import numpy as np

# Creates a new dataframe with a list named data and with the field name
# field_name. the rows of the field field_name will be populated by the values
# in the list named data
# usage 
# df = create_dataframe(Country_Codes, 'Country_Code')
#
def create_dataframe(data, field_name):
    df = pd.DataFrame(data, columns = [field_name])   
    return(df)

# Function similar to egen in STATA
# usage egen(df, 'avg_rev', 'rev', 'Region_Code', 'mean')
# df = egen(df, 'mean_GGR_NGDP', 'GGR_NGDP', ['Region_Code', 'year'], 'mean')
# for grouping by a combination of fields use list notation ['Region_Code, 'year'] 
# if we want the mean satisfying a certain condition, we use the 
# field name value, field value and field condition
# example df = egen(df, 'avg_rev', 'rev', 'Region_Code', 'mean', 'year', '<', 2019)
# calculates the mean only satisfying the condition year<2019

# value_of is to place a particular record value in each record satisfying the condition
# in the example below we take the value of 'rev' in year 2020 and fill in 
# the 'rev' for all the 'year' of the 'Country_Code' for further analysis
# df = egen(df, 'rev_2020', 'rev', 'Country_Code', 'value_of', 'year', 2020)
# df = egen(df, 'GGR_NGDP_2020', 'GGR_NGDP', 'Country_Code', 'value_of', 'year', 2020)
def egen(df, new_field_name, field_name, by, func, field_name_value=None, field_condition=None, field_value=None):
    def dataframe_partition(df, field_name_value=None, field_condition=None, field_value=None):
        import operator
        ops = {'>': operator.gt,
           '<': operator.lt,
           '>=': operator.ge,
           '<=': operator.le,
           '=': operator.eq}
        return df[ops[field_condition](df[field_name_value], field_value)]
 
    if func=='value_of':
        if (field_name_value is None or field_value is None):
            print('error')
        else:
            df2=df[df[field_name_value]==field_value][[by, field_name]]
    elif func=='mean':
        if field_condition is not None:
            df1=dataframe_partition(df, field_name_value, field_condition, field_value)
        df2 = df1.groupby(by=by)[field_name].mean()
        df2 = df2.reset_index()
    elif func=='sum':
        if field_condition is not None:
            df1=dataframe_partition(df, field_name_value, field_condition, field_value)
        df2 = df1.groupby(by=by)[field_name].sum()
        df2 = df2.reset_index()      
    df2=df2.rename(columns={field_name:new_field_name})
    df = pd.merge(df, df2, on=by, how='inner')
    return(df)

# Creates a new field with the default values if provided else 
# blanks will be filled
# usage 
# df = gen(df, 'Revenue Shock')
# df = gen(df, 'Revenue Shock', 1.0)
#
def gen(df, field_name, data=None, default_value=None):
    if field_name in df.columns.values:
        print('Field : ', field_name, ' already exists')
    else:
        if default_value is None:        
            field_name_values = ['']*len(df)
        else:
            if data is None:
                field_name_values = [default_value]*len(df)
            else:
                field_name_values = data
        df[field_name] = field_name_values
    return(df)

# replaces the values of the column replace_field_name with replace_value
# in those rows whereever the condition condition_field_name == condition_field_name_value
# is satisfied
# usage 
# df = replace(df, 'Total_Non_Tax_Revenue', 1.0, 'Country_Code', 'ASM')
#
def replace(df, replace_field_name, replace_value, condition_field_name,
            condition_field_name_value):
    df[replace_field_name] = np.where(df[condition_field_name]==condition_field_name_value, replace_value, df[replace_field_name])      
    return(df)

# returns a list of records from a dataframe satisfying certain conditions
# up to three conditions could be used to select
# usage
# list_if(revenue_df, ['year', 'govt_expenditure', 'Total_Revenue_excl_SC'], 'Country_Code', '=', 'IND', 'year', '>=', 2000)
#
def list_if(df, field_name,
            condition_field_name1=None, condition_operator1=None, condition_field_value1=None,
            condition_field_name2=None, condition_operator2=None, condition_field_value2=None,
            condition_field_name3=None, condition_operator3=None, condition_field_value3=None):

    condition_field_name_list = []
    condition_operator_list = []
    condition_field_value_list = []
    if ((condition_field_name1 is not None) and
        (condition_field_name2 is not None) and
        (condition_field_name3 is not None)):
            condition_field_name_list = [condition_field_name1,
                                         condition_field_name2,
                                         condition_field_name3]
            condition_operator_list = [condition_operator1,
                                       condition_operator2,
                                       condition_operator3]
            condition_field_value_list = [condition_field_value1,
                                          condition_field_value2,
                                          condition_field_value3]
    elif ((condition_field_name1 is not None) and
          (condition_field_name2 is not None)):
            condition_field_name_list = [condition_field_name1,
                                         condition_field_name2]
            condition_operator_list = [condition_operator1,
                                       condition_operator2]
            condition_field_value_list = [condition_field_value1,
                                          condition_field_value2]
    elif (condition_field_name1 is not None):
            condition_field_name_list = [condition_field_name1]
            condition_operator_list = [condition_operator1]      
            condition_field_value_list = [condition_field_value1]            
    print('field_name: ', field_name)
    print(condition_field_name_list)
    print(condition_field_value_list)
    length_condition = len(condition_field_name_list)
    if (length_condition==0):
        return(df[field_name])
    else:
        for i in range(length_condition):
            print(condition_field_name_list[i])
            print(condition_field_value_list[i])
            if (condition_operator_list[i]=='='):
                df = df[df[condition_field_name_list[i]]==condition_field_value_list[i]]
            elif (condition_operator_list[i]=='>'):
                df = df[df[condition_field_name_list[i]]>condition_field_value_list[i]]
            elif (condition_operator_list[i]=='>='):
                df = df[df[condition_field_name_list[i]]>=condition_field_value_list[i]]
            elif (condition_operator_list[i]=='<'):
                df = df[df[condition_field_name_list[i]]<condition_field_value_list[i]]
            elif (condition_operator_list[i]=='<='):
                df = df[df[condition_field_name_list[i]]<=condition_field_value_list[i]]               
    #print(df)
    return (df[field_name])

def remove_outliers(df, field_name, lower=None, upper=None):
    if lower is not None:
        df = df[df[field_name]>=lower]
    if upper is not None:
        df = df[df[field_name]<=upper]
    return(df)

# unlike the pandas merge, this merge updates the common fields (EXCEPT THE 
# FIELDS ON WHICH MERGED - see function stata_merge_update_field) from the 
# secondary dataframe to the master dataframe (when overwrite is set to True)
# or where the master dataframe is empty (when overwrite is set to False - Default) 
# and includes all the rows from both the secondary and master dataframe 
# when merge_type is set to "outer" , similarly "left" or "right" or "inner" 
# merge with DEFAULT being "outer" merge
# usage 
# df = stata_merge(df1, df2, 'year', 'Country_Code', merge_type="outer",
#                  overwrite=True, indicator=True)
def stata_merge_update_all_fields_full(df1, df2, field1, field2=None, 
                                       merge_type=None, overwrite=None,
                                       indicator=None):
    merge_fields = [field1]
    if field2 is not None:
        merge_fields = merge_fields + [field2]
    df1_columns = df1.columns
    df2_columns = df2.columns
    common_fields = list(set(df1_columns) & set(df2_columns))
    common_fields = [x for x in common_fields if x not in merge_fields]
    if merge_type is not None:
        #if ((merge_type=="left") or (merge_type=="right") or (merge_type=="inner")):
        df = pd.merge(df1, df2, how=merge_type, on=merge_fields, indicator=True)
    else:
        df = pd.merge(df1, df2, how="outer", on=merge_fields, indicator=True)
    common_fields_x = [x+'_x' for x in common_fields]
    common_fields_y = [x+'_y' for x in common_fields]  
    for i in range(len(common_fields_x)):
        if overwrite is not None:
            if overwrite:
                df[common_fields_x[i]] = df[common_fields_y[i]]
        else:
            df[common_fields_x[i]] = np.where(df[common_fields_x[i]].isnull(), df[common_fields_y[i]], df[common_fields_x[i]])  

    df.rename(columns=dict(zip(common_fields_x, common_fields)),inplace=True)
    if indicator is None:
        df = df.drop(['_merge'], axis=1, errors='ignore')
    else:
        if not indicator:
            df = df.drop(['_merge'], axis=1, errors='ignore')
    all_fields = list(df.columns)
    new_fields = [x for x in all_fields if x not in common_fields_y]
    df = df[new_fields]
    return(df)

# unlike the pandas merge, this merge updates the specified fields from the 
# secondary dataframe to the master dataframe
# usage 
# df2 =  stata_merge_update_field(df, country_map, 'Country', 
#                             update_master_field='Country',
#                             update_secondary_field='WB_Country',
#                             indicator=True)
def stata_merge_update_field(df1, df2, field1, field2=None, 
                             update_master_field=None,
                             update_secondary_field=None,
                             indicator=None):
    merge_fields = [field1]
    if field2 is not None:
        merge_fields = merge_fields + [field2]
    df1_columns = df1.columns
    df1 = df1.drop(['_merge'], axis=1, errors='ignore')
    df2_columns = df2.columns
    df2 = df2.drop(['_merge'], axis=1, errors='ignore')
    common_fields = list(set(df1_columns) & set(df2_columns))
    common_fields = [x for x in common_fields if x not in merge_fields]
    #print(common_fields)

    df = pd.merge(df1, df2, how="left", on=merge_fields, indicator=True)
    # if update_master_field or update_secondary_field is common in both dataframes
    # then merge will append an _x and _y respectively
    # so to check that
    if update_master_field in common_fields:
        update_master_field = update_master_field+'_x'    
    if update_secondary_field in common_fields:
        update_secondary_field = update_secondary_field+'_y'
    
    df[update_master_field] = np.where(df['_merge']=="both", df[update_secondary_field], df[update_master_field])
    
    if update_master_field in common_fields:
        df = df.rename(columns={update_master_field:update_master_field[:-2]})
    if indicator is None:
        df = df.drop(['_merge'], axis=1, errors='ignore')
    else:
        if not indicator:
            df = df.drop(['_merge'], axis=1, errors='ignore')
    return(df)

# unlike the pandas merge, this merge updates the common fields from the 
# secondary dataframe to the master dataframe
# the ultra merge also incorporates all records of both dataframes
# kinds of merge
# usage 
# df = stata_merge(df1, df2, 'year', 'Country_Code')
def stata_merge(df1, df2, field1, field2=None, indicator=None):
    merge_fields = [field1]
    if field2 is not None:
        merge_fields = merge_fields + [field2]
    df1_columns = df1.columns
    df2_columns = df2.columns
    common_fields = list(set(df1_columns) & set(df2_columns))
    common_fields = [x for x in common_fields if x not in merge_fields]
    df = pd.merge(df1, df2, how="outer", on=merge_fields, indicator=True)
    common_fields_x = [x+'_x' for x in common_fields]
    common_fields_y = [x+'_y' for x in common_fields]
    
    for i in range(len(common_fields_x)):
        df[common_fields_x[i]] = np.where(df['_merge']=="both", df[common_fields_y[i]], df[common_fields_x[i]])   
    
    df.rename(columns=dict(zip(common_fields_x, common_fields)),inplace=True)
    if indicator is None:
        if not indicator:
            common_fields_y = common_fields_y + ['_merge']
    all_fields = list(df.columns)
    new_fields = [x for x in all_fields if x not in common_fields_y]
    df = df[new_fields]
    return(df)

def browse(df):
    df.to_csv('temp.csv')
    import os
    os.startfile('temp.csv')


#converts a wide WDI file to a long dataframe and also stores in csv format
#usage:
# Perform a simple cleanup first keeping the columns in the first row
#filename = "GDP - Constant 2010 USD - March 2021.xls"
#sheetname = "Sheet1"
#parameter = 'GDP_constant_USD'
#df_gdp_constant_usd = convert_WDI_file(filename, sheetname, parameter)
def convert_WDI_file(filename, sheetname, parameter):
    
    df = pd.read_excel(filename, sheet_name=sheetname, index_col=None, header=0)
    df = df.rename(columns={'Country Code':'Country_Code'})
    df.drop(['Country Name', 'Indicator Name', 'Indicator Code'], axis=1, inplace=True)
    
    df = df.set_index('Country_Code') 
    df = df.stack()
    df = df.reset_index()
    df = df.rename(columns={'level_1':'year',0:parameter})
    
    if filename.find('.xlsx'):
        filename.replace('.xlsx', '')
    elif filename.find('.xls'):
        filename.replace('.xls', '')
    else:
        filename.replace('.', '')
        
    df.to_csv(filename+'.csv', index=False)

    return(df)

#converts a wide WDI file to a long dataframe and also stores in csv format
#usage:
#filename = "GDP - Constant 2010 USD - March 2021.xls"
#sheetname = "Sheet1"
#parameter = 'GDP_constant_USD'
#df_gdp_constant_usd = convert_WDI_file(filename, sheetname, parameter)
def convert_file_long(df, index_col, parameter):
    #df = pd.read_excel(filename, sheet_name=sheetname, index_col=None, header=0)
    #df = df.rename(columns={'Country Code':'Country_Code'})
    #df.drop(['Country Name', 'Indicator Name', 'Indicator Code'], axis=1, inplace=True)
    
    df = df.set_index(index_col)
    df = df.stack()
    df = df.reset_index()
    df = df.rename(columns={'level_1':'year',0:parameter})
    df = df.set_index('year')
    return(df)