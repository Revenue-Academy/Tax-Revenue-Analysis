# -*- coding: utf-8 -*-
"""
Created on Tue Mar 17 16:45:49 2020

@author: wb305167
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

def adjust_crisis_yr(df, start_year, end_year, crisis_year, tax_type):
    true_crisis_year = crisis_year
    if (crisis_year >= start_year+2):
        if ((df[df['year']==crisis_year-1][tax_type].values[0] >
            df[df['year']==crisis_year][tax_type].values[0]) and
            (df[df['year']==crisis_year-2][tax_type].values[0] <
            df[df['year']==crisis_year-1][tax_type].values[0])):
            return(crisis_year - 1)
    if (crisis_year >= start_year+2):
        if ((df[df['year']==crisis_year-1][tax_type].values[0] >
            df[df['year']==crisis_year][tax_type].values[0]) and
            (df[df['year']==crisis_year][tax_type].values[0] <
            df[df['year']==crisis_year+1][tax_type].values[0])):
            return(crisis_year - 1)       
    if (crisis_year <= end_year-2):
        if ((df[df['year']==crisis_year+1][tax_type].values[0] >
            df[df['year']==crisis_year][tax_type].values[0]) and
            (df[df['year']==crisis_year+2][tax_type].values[0] <
            df[df['year']==crisis_year+1][tax_type].values[0])):
            return(crisis_year + 1)
    print('true crisis year: ',true_crisis_year)
    return(true_crisis_year)            
    
def find_pre_crisis_trend(df, start_year, end_year, crisis_year, tax_type):
    #adjusted crisis year is sent into the function    
    #tol = 0.0
    #print("crisis_year: ", crisis_year)
    #print(df[df['year']==crisis_year][tax_type].values[0])    
    #print("tax_type: ", tax_type)
    tol = (df[df['year']==crisis_year][tax_type].values[0])/250
    print('tol: ', tol)
    pre_crisis_trend = ""
    print(' crisis year-1: ', df[df['year']==crisis_year-1][tax_type].values[0])
    print(' crisis year: ',df[df['year']==crisis_year][tax_type].values[0])
    print(' crisis year+1: ',df[df['year']==crisis_year+1][tax_type].values[0])
    print(' crisis year+2: ',df[df['year']==crisis_year+2][tax_type].values[0])
    
    if (crisis_year >= start_year-1) and (crisis_year <= end_year-1):
        if ((df[df['year']==crisis_year-1][tax_type].values[0] -
             df[df['year']==crisis_year][tax_type].values[0]) > tol):
            if ((df[df['year']==crisis_year][tax_type].values[0] -
                df[df['year']==crisis_year+1][tax_type].values[0]) > tol):
                if ((df[df['year']==crisis_year+1][tax_type].values[0] -
                     df[df['year']==crisis_year+2][tax_type].values[0]) > tol):
                    
                    print((df[df['year']==crisis_year+1][tax_type].values[0] -
                     df[df['year']==crisis_year+2][tax_type].values[0]))
                    pre_crisis_trend = "downward"
                
        if ((df[df['year']==crisis_year][tax_type].values[0] -
            df[df['year']==crisis_year-1][tax_type].values[0]) > tol):
            if ((df[df['year']==crisis_year+1][tax_type].values[0] -
                 df[df['year']==crisis_year][tax_type].values[0]) > tol):
                if ((df[df['year']==crisis_year+2][tax_type].values[0] -
                     df[df['year']==crisis_year+1][tax_type].values[0]) > tol):                
                    pre_crisis_trend = "upward"         
    return(pre_crisis_trend)
    
def find_turnaround_year_negative_shock(df, end_year, crisis_year,
                                        recovery_year, tax_type):
    turn_around_year = np.nan  
    if (not np.isnan(recovery_year)):
        min_revenue = df[df['year']==crisis_year+1][tax_type].values[0]
        turn_around_year = crisis_year+1
        for year in range(crisis_year+1, end_year):
            revenue_year = df[df['year']==year][tax_type].values[0]
            if (revenue_year<min_revenue):
                min_revenue = revenue_year
                turn_around_year = year
    return(turn_around_year)

# if recovery_year = -1 then trends do not show any shock
# if recovery_year = 0 then did not recover
def find_yr_recovery_negative_shock(df, end_year, crisis_year, pre_crisis_trend, tax_type):
    #adjusted crisis year and pre-crisis trend is sent into the function
    data_gap = False
    recovery_year_1_2 = np.nan
    recovery_year_3_4 = np.nan        
    recovery_year = np.nan
    recovery_year_1_2_str = "Did not Recover"
    recovery_year_3_4_str = "Did not Recover"
    recovery_year_str = "Did not Recover" 
    if ((pre_crisis_trend == 'downward') or (pre_crisis_trend == 'upward')):
        recovery_year_1_2 = np.nan
        recovery_year_3_4 = np.nan
        recovery_year = np.nan
        recovery_year_1_2_str = "Trend"
        recovery_year_3_4_str = "Trend"
        recovery_year_str = "Trend"
    else:
        pre_crisis_revenue = df[df['year']==crisis_year][tax_type].values[0]
        crisis_revenue = df[df['year']==crisis_year+1][tax_type].values[0]
        
        print('pre_crisis_revenue: ', pre_crisis_revenue)
        for year in range(crisis_year+1, end_year+1):
            revenue_year = df[df['year']==year][tax_type].values[0]
            if np.isnan(revenue_year) and not data_gap:
                data_gap = True
            print('revenue_year: ', revenue_year)
            #if (pre_crisis_trend != 'upward'):
            if ((revenue_year >= 0.5*pre_crisis_revenue) and
                (np.isnan(recovery_year_1_2))):
                recovery_year_1_2 = year
                recovery_year_1_2_str = str(recovery_year_1_2)
                print('recovery_year_1_2: ', recovery_year_1_2)
            if ((revenue_year >= 0.75*pre_crisis_revenue) and 
                 (np.isnan(recovery_year_3_4))):
                recovery_year_3_4 = year
                recovery_year_3_4_str = str(recovery_year_3_4)                    
                print('recovery_year_3_4: ', recovery_year_3_4)             
            if (revenue_year >= pre_crisis_revenue):
                recovery_year = year
                print('recovery_year: ', recovery_year)
                recovery_year_str = str(recovery_year)              
                return(recovery_year_1_2, recovery_year_3_4, recovery_year,
                       recovery_year_1_2_str, recovery_year_3_4_str,
                       recovery_year_str)                   
        if (year == end_year):
            if not(np.isnan(revenue_year)) and not data_gap:
                if np.isnan(recovery_year_1_2):
                    recovery_year_1_2 = end_year+1
                    print('recovery_year_1_2: ', recovery_year_1_2)
                if np.isnan(recovery_year_3_4):
                    recovery_year_3_4 = end_year+1
                    print('recovery_year_3_4: ', recovery_year_3_4)
                if np.isnan(recovery_year):
                    recovery_year = end_year+1
                    print('recovery_year: ', recovery_year)
    print(recovery_year_1_2_str, recovery_year_3_4_str, recovery_year_str)    
    return(recovery_year_1_2, recovery_year_3_4, recovery_year,
           recovery_year_1_2_str, recovery_year_3_4_str, recovery_year_str)
    
def find_negative_shock(df, pre_crisis_trend, crisis_year, recovery_year, 
                       turn_around_year, param):
    param_shock_value = np.nan
    pre_crisis_param_value = np.nan
    crisis_param_value = np.nan
    pre_crisis_param_value = df[df['year']==crisis_year][param].values[0]
    #print('pre_crisis_trend: ', pre_crisis_trend)
    if ((pre_crisis_trend == 'downward') or
        (pre_crisis_trend == 'upward')):
        param_shock_value = np.nan
    else:
        if ((turn_around_year!=0) and not (np.isnan(turn_around_year))):
            print('param: ', param)
            print('turn_around_year: ', turn_around_year)
            crisis_param_value = df[df['year']==turn_around_year][param].values[0]
            param_shock_value = crisis_param_value - pre_crisis_param_value
            """
            if (param_shock_value<0):
                param_shock_value = np.nan
            """
    return(param_shock_value, pre_crisis_param_value, crisis_param_value)

def find_growth_rate(df, param, condition_field_name,
            condition_field_name_value, year1, year2):
    print('param: ', param)
    if (year1 != 0):
        param_year1 = df[(df['year']==year1) & (df[condition_field_name] == condition_field_name_value)][param].values[0]
    else:
        param_year1 = np.nan
    if (year2 != 0):
        param_year2 = df[(df['year']==year2) & (df[condition_field_name] == condition_field_name_value)][param].values[0]
    else:
        param_year2 = np.nan
    param_gr = (param_year2 - param_year1)/param_year1
    print('param_year1: ', param_year1)
    print('param_year2: ', param_year2)    
    print('param_gr: ', param_gr)
    return(param_year1, param_year2, param_gr)
       
def find_buoyancy(df, base_param, param, condition_field_name,
            condition_field_name_value, year1, year2):
    base_param_year1, base_param_year2, base_param_gr = find_growth_rate(df, base_param, condition_field_name,
            condition_field_name_value, year1, year2)
    param_year1, param_year2, param_gr = find_growth_rate(df, param, condition_field_name,
            condition_field_name_value, year1, year2)
    param_buoyancy = param_gr/base_param_gr
    print('param_buoyancy: ', param_buoyancy)
    return(param_year1, param_year2, param_buoyancy)
 
def customize_annotate(region=None, tax_type=None):
    x_adjust = 0.0
    y_adjust = 0.0
    """    
    if ((region is None) and (tax_type is None)):    
        x_adjust = 0.0
        y_adjust = 0.0
    if ((region == "SSA") and (tax_type == "Value_Added_Tax")):    
        x_adjust = 0.0
        y_adjust = -0.5
    if ((region == "Global") and (tax_type == "Value_Added_Tax")):    
        x_adjust = 0.0
        y_adjust = -0.5
    if ((region == "WER") and (tax_type == "Value_Added_Tax")):  
        x_adjust = 0.0
        y_adjust = -2.0
    if ((region == "WER") and (tax_type == "Total_Non_Tax_Revenue")):  
        x_adjust = 0.0
        y_adjust = 1.0     

    if ((region == "Global") and (tax_type == "Income_Taxes")):    
        x_adjust = 0.0
        y_adjust = -0.5
    if ((region == "SSA") and (tax_type == "Value_Added_Tax")):    
        x_adjust = 0.0
        y_adjust = -0.5
    if ((region == "SSA") and (tax_type == "Value_Added_Tax")):    
        x_adjust = 0.0
        y_adjust = -0.5        
    """         
    return(x_adjust, y_adjust)


def customize_axes_bounds(region, tax_type, y_low, y_high):
    y_low = y_low
    y_high = y_high
    if ((region == "MENA") and (tax_type != "Total_Non_Tax_Revenue")):    
        y_low = 0.0
        y_high = 8.0
    if ((region == "MENA") and (tax_type == "Total_Non_Tax_Revenue")):    
        y_low = 0.0
        y_high = 23.0      
    if ((region == "WER") and (tax_type == "Income_Taxes")):    
        y_low = 0.0
        y_high = 15.0        
    """
    if ((region == "SSA") and (tax_type == "Value_Added_Tax")):    
        x_adjust = 0.0
        y_adjust = -0.5
    if ((region == "SSA") and (tax_type == "Value_Added_Tax")):    
        x_adjust = 0.0
        y_adjust = -0.5        
    """        
    return(y_low, y_high, np.linspace(y_low, y_high, y_high-y_low+1))

# Find nice position for the text Recovery Year
def find_nice_pos(df, tax_type, x_pos=None, y_low=None, y_high=None):
    
    if x_pos is None:
        x_pos=2014
    if (y_low is None):
        y_low = int(df[tax_type].min())
    if (y_high is None):      
        y_high = int(df[tax_type].max()) + 1

    y_mid=(y_low + y_high)/2
    y_gap=(y_high - y_low)
    print(df)
    print('x_pos: ', x_pos)
    y_loc = df[df['year']==x_pos][tax_type].values[0]
    print('y_loc: ', y_loc, 'y_mid: ', y_mid, 'y_step: ', y_gap/8)
    if (y_loc >= y_mid):
        y_pos = y_mid-2*(y_gap/8)
    else:
        y_pos = y_mid+(y_gap/8)
    print('y_low: ', y_low, 'y_high: ', y_high, 'y_pos: ', y_pos)
    print('y_gap: ', y_gap)        
    return(x_pos, y_pos, y_gap/8)
    
def annotate_chart(df, crisis_year, pre_crisis_trend, recovery_year,
                   turn_around_year, revenue_shock, tax_type, axes,
                   font_size=None, x_pos=None, y_low=None, y_high=None,
                   x_adjust=None, y_adjust=None):   

    x_pos, y_pos, text_gap = find_nice_pos(df, tax_type, x_pos, y_low, y_high)
    print('x_pos: ', x_pos, 'y_pos: ', y_pos, 'text_gap: ', text_gap)
    print('x_adjust: ', x_adjust, 'y_adjust: ', y_adjust)
        
    if font_size is None:
        font_size = 16  
    if x_adjust is None:
        x_adjust=0
    if y_adjust is None:
        y_adjust=0    

    #print('pre-crisis trend: ', pre_crisis_trend)
    if (revenue_shock == ''):
        revenue_shock_text = ""
        recovery_year_text = ""
    else:
        revenue_shock_text = ('Revenue Shock: ' +
                              "{:.2f}".format(revenue_shock) +
                              ' (% of GDP)')
        if (recovery_year==0):
            if ((pre_crisis_trend == 'downward') or 
                (pre_crisis_trend == 'upward')):
                recovery_year_text = ""
            else:
                recovery_year_text = "Did Not Recover"
        else:
            recovery_year_text = 'Year of Recovery: ' + str(recovery_year)
    print('recovery_year_text: ', recovery_year_text)
    print('revenue_shock_text: ', revenue_shock_text)
    
    axes.annotate(revenue_shock_text, # this is the text
                 (x_pos + x_adjust, y_pos+ text_gap + y_adjust), # this is the point to label
                 textcoords="offset points", # how to position the text
                 xytext=(0,10), # distance from text to points (x,y)
                 ha='center', # horizontal alignment can be left, right or center
                 fontsize = font_size) # size of marker
    
    axes.annotate(recovery_year_text, # this is the text
                 (x_pos+x_adjust,y_pos+y_adjust), # this is the point to label
                 textcoords="offset points", # how to position the text
                 xytext=(0,10), # distance from text to points (x,y)
                 ha='center', # horizontal alignment can be left, right or center
                 fontsize = font_size) # size of marker

def plot_chart(df4, i, j, start_year, end_year, taxes=None,
               taxes_tuple=None, my_dpi=None, axes=None,
               y_low=None, y_high=None, country_code=None,
               tax_type=None, crisis_year=None, pre_crisis_trend=None,
               recovery_year=None, turn_around_year=None, revenue_shock=None,
               k=None, l=None):
    markers = ['^', 'x', 's', '*', 'D', 'v', '8', 'X']
    colors = ['r', 'b', 'y', 'm', 'c', 'k', 'g', '0.5']
    Region_desc = ['Sub-Saharan Africa', 'Latin America and the Caribbean',
                'South Asia', 'Eastern Europe and Central Asia',
                'East Asia and the Pacific', 'Middle-East and North Africa',
                'Western Europe', 'North America']
    if ((i==0) and (j==0)):
        fig, axes = plt.subplots(3,2, figsize=(20, 18), dpi=my_dpi,
                                 constrained_layout=True)    
        axes[0,0] = df4.plot(kind='line', x='year', xticks = np.linspace(start_year,end_year,end_year-start_year+1),
                      use_index=True, y=taxes,
                      legend=False, rot=0, ax=axes[0,0])
        axes[0,0].xaxis.label.set_visible(False)
        axes[0,0].tick_params(axis='both', which='major', labelsize=14)    
        for i, line in enumerate(axes[0,0].get_lines()):
            line.set_marker(markers[i])
        for i, line in enumerate(axes[0,0].get_lines()):
            line.set_color(colors[i])    
        axes[0,0].legend(taxes_tuple,
                loc='upper center', bbox_to_anchor=(0.3, 1.15),
                  fancybox=True, shadow=False, frameon=True, ncol=3)
        axes[0,0].xaxis.label.set_visible(False)
        axes[0,0].set_ylabel("% of GDP")
        return(axes)
    else:    
        tax_type_label = tax_type.replace('_', ' ')
        y_low, y_high, y_ticks = customize_axes_bounds(country_code, tax_type, y_low, y_high)
        
        axes[i,j] = df4.plot(kind='line', x='year',
                            xticks = np.linspace(start_year,end_year,
                                                 end_year-start_year+1),
                            yticks = y_ticks,
                            use_index=True, y=tax_type, legend=False, rot=0,
                            color=colors[k], marker=markers[k], ax=axes[i,j])
        axes[i, j].xaxis.label.set_visible(False)
        axes[i, j].tick_params(axis='both', which='major', labelsize=14)
        #ax.xaxis.label.set_visible(False)
        #ax.yaxis.set_label_text(..)
        axes[i, j].set_ylabel("% of GDP")
        axes[i, j].set_title(tax_type_label + ' Revenue',fontweight="bold")      
        for x,y in zip(df4['year'],df4[tax_type]):
            label = "{:.1f}".format(y)
            axes[i,j].annotate(label, # this is the text
                         (x,y), # this is the point to label
                         textcoords="offset points", # how to position the text
                         xytext=(0,10), # distance from text to points (x,y)
                         ha='center', # horizontal alignment can be left, right or center
                         fontsize = 14) # size of marker
        
        # Label the recovery year
        x_adjust, y_adjust = customize_annotate(country_code, tax_type)
        print('x_adjust: ', x_adjust, 'y_adjust: ', y_adjust)
        annotate_chart(df4, crisis_year, pre_crisis_trend, recovery_year,
                       turn_around_year, revenue_shock, tax_type, axes[i, j],
                       font_size=12, y_low = y_low, y_high=y_high, x_adjust=x_adjust,
                       y_adjust=y_adjust)

    fig.suptitle('Revenue Performance around the Financial Crisis - '+Region_desc[l], fontweight='bold', fontsize=16)    
    filename='Revenue Performance - '+ country_code +'.png'
    plt.savefig('C:/Users/wb305167/Documents/python/Tax-Revenue-Analysis/' + filename, dpi=my_dpi)  