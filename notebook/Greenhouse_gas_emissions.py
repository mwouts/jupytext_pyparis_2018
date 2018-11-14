# -*- coding: utf-8 -*-
# ---
# jupyter:
#   jupytext:
#     formats: ipynb,py:light
#     text_representation:
#       extension: .py
#       format_name: light
#       format_version: '1.3'
#       jupytext_version: 0.8.5
#   kernelspec:
#     display_name: Python 3
#     language: python
#     name: python3
#   language_info:
#     codemirror_mode:
#       name: ipython
#       version: 3
#     file_extension: .py
#     mimetype: text/x-python
#     name: python
#     nbconvert_exporter: python
#     pygments_lexer: ipython3
#     version: 3.7.0
# ---

# # Why worry?
#
# From PWC's [Low Carbon Economy Index 2018](https://www.pwc.co.uk/services/sustainability-climate-change/insights/low-carbon-economy-index.html):
# > Carbon intensity continued to fall at a rate consistent with the previous few years, at 2.6%. But even this falls short of the 3% average decarbonisation rate needed to meet the weak national targets pledged in the 2015 Paris Agreement. The gap between the current decarbonisation rate and that needed to limit global warming to two degrees is widening. It’s now 6.4% per year for the rest of this century.
#
# > In contrast with our report last year, not one of the G20 countries achieved the 6.4% rate required to limit warming to two degrees this year. That goal is slipping further out of reach – at current levels of decarbonisation, the global carbon budget for two degrees will run out in 2036.
#
# Not sure we are on the right track! But maybe you want to check by yourself.
#
# In this notebook, we access publicly available data from the [World Bank](https://www.worldbank.org), and vizualise the evolution of greenhouse gas emissions, as well as that of the much related gross domestic product.

# # World Bank data

# The [World Bank](https://www.worldbank.org/) offers a wide set of economic and developement indicators. We download the values for a few of these indicators using `wbdata`, reshape the data using `pandas`, and explore the metrics using `ploty` and `ipywidgets`.

# +
import os
import pandas as pd
import wbdata as wb

# My preferences for printing DataFrames: few rows, and many columns.
pd.options.display.max_rows = 6
pd.options.display.max_columns = 20


# Download just once the desired indicators, save to a file
def download_once(indicators, path):
    if os.path.isfile(path):
        return pd.read_hdf(path, 'indicators')

    data = wb.get_dataframe(indicators, convert_date=True).sort_index()
    data.to_hdf(path, 'indicators')

    return data


# -

# The names of the indicators below were found using the World Bank indicator [search page](https://data.worldbank.org/indicator). There are actually many more indicators there!

indicators = {
    'SP.POP.TOTL': 'Population, total',
    'AG.SRF.TOTL.K2': 'Surface area (sq. km)',
    'AG.LND.TOTL.K2': 'Land area (sq. km)',
    'AG.LND.ARBL.ZS': 'Arable land (% of land area)',
    'EN.ATM.GHGT.KT.CE': 'Total greenhouse gas emissions (kt of CO2 equivalent)',
    'EN.ATM.CO2E.KT': 'CO2 emissions (kt)',
    'EN.ATM.NOXE.KT.CE': 'Nitrous oxide emissions (thousand metric tons of CO2 equivalent)',
    'EN.ATM.METH.KT.CE': 'Methane emissions (kt of CO2 equivalent)',
    'EN.ATM.CO2E.SF.KT': 'CO2 emissions from solid fuel consumption (kt)',
    'EN.ATM.CO2E.LF.KT': 'CO2 emissions from liquid fuel consumption (kt)',
    'EN.ATM.CO2E.GF.KT': 'CO2 emissions from gaseous fuel consumption (kt)',
    'EN.CO2.MANF.ZS': 'CO2 emissions from manufacturing industries and construction (% of total fuel combustion)',
    'EN.CO2.TRAN.ZS': 'CO2 emissions from transport (% of total fuel combustion)',
    'EN.ATM.CO2E.GF.ZS': 'CO2 emissions from gaseous fuel consumption (% of total)',
    'EN.ATM.CO2E.KD.GD': 'CO2 emissions (kg per 2010 US$ of GDP)',
    'AG.YLD.CREL.KG': 'Cereal yield (kg per hectare)',
    'AG.PRD.LVSK.XD': 'Livestock production index (2004-2006 = 100)',
    'AG.PRD.CROP.XD': 'Crop production index (2004-2006 = 100)',
    'NY.GDP.MKTP.CD': 'GDP (current US$)',
    'NY.GDP.MKTP.KD': 'GDP (constant 2010 US$)'}

world_bank_data = download_once(indicators, 'world_bank_indicators.hdf')

world_bank_data.loc['World']


# +
def world(metric):
    """Value of desired metric, on the World, indexed by date"""
    value = world_bank_data.loc['World'][metric].dropna()
    return value


zones = ['North America', 'Middle East & North Africa',
         'Latin America & Caribbean', 'Europe & Central Asia',
         'Sub-Saharan Africa', 'South Asia',
         'East Asia & Pacific'][::-1]


def regions(metric):
    """Value of desired metric, per world region (column), indexed by date"""
    # World regions, in order of increasing population
    value = world_bank_data.loc[zones][metric].dropna().swaplevel().unstack()[zones]
    return value


# -

# +
import plotly.graph_objs as go
import plotly.offline as offline

offline.init_notebook_mode()
# -

# # Metric explorer

# +
from ipywidgets import widgets
from IPython.display import display

metric_selector = widgets.Dropdown(
    options=list(world_bank_data),
    value='CO2 emissions (kt)',
    description='Metric')

metric_explorer = go.FigureWidget()


def update_plot(change):
    m = metric_selector.value
    if m in world_bank_data:
        metric_explorer.data = []
        metric_explorer.layout.title = m

        value_world = world(m)

        value_region = regions(m)
        for region in zones:
            metric_explorer.add_scatter(x=value_region.index, y=value_region[region], name=region,
                                        stackgroup=m if '%' not in m
                                                        and ' 100' not in m
                                                        and ' per ' not in m else None)

        metric_explorer.add_scatter(x=value_world.index, y=value_world, name='World', line=dict(dash='dash'))


metric_selector.observe(update_plot, names="value")

display(metric_selector)
update_plot(None)
display(metric_explorer)
# -


# # A few plots

# ## Greenhouse gas emissions

# Greenhouse gas emissions have increased steadily over the last decades. CO2 emissions are two thirds of the total emissions, and were multiplied by 3.5 since the sixties.

# +
data = []


def add_line(full_name, legend_name, scatter_or_bar=go.Scatter, **kwargs):
    value = world_bank_data.loc['World'][full_name].dropna()
    data.append(scatter_or_bar(x=value.index.date, y=value, name=legend_name, **kwargs))


add_line('Total greenhouse gas emissions (kt of CO2 equivalent)', 'Total', line=dict(dash='dash'))
add_line('CO2 emissions (kt)', 'CO2', stackgroup='ghg')
add_line('Nitrous oxide emissions (thousand metric tons of CO2 equivalent)', 'Nitrous oxide', stackgroup='ghg')
add_line('Methane emissions (kt of CO2 equivalent)', 'Methane', stackgroup='ghg')

layout = go.Layout(title='Greenhouse gas emissions', barmode='stack',
                   yaxis=dict(title='CO2 equivalent (kt)'))

offline.iplot(go.Figure(data=data, layout=layout), show_link=False)
# -

# ## Population, per world region

# CO2 emissions increase at a larger pace than population.

metric_name = 'Population, total'
metric = world_bank_data[metric_name].dropna()
data = [go.Scatter(x=metric.loc[region].index.date, y=metric.loc[region], name=region,
                   stackgroup='World') for region in zones]
add_line(metric_name, 'Total', line=dict(dash='dash'))
offline.iplot(go.Figure(data=data,
                        layout=go.Layout(
                            title=metric_name,
                            yaxis=dict(title='Population'))), show_link=False)

# ## Gross domestic product

metric_name = 'GDP (constant 2010 US$)'
metric = world_bank_data[metric_name].dropna()
data = [go.Scatter(x=metric.loc[region].index.date, y=metric.loc[region], name=region,
                   stackgroup='World') for region in zones]
add_line(metric_name, 'Total', line=dict(dash='dash'))
offline.iplot(go.Figure(data=data,
                        layout=go.Layout(
                            title=metric_name)), show_link=False)

# ## CO2 emissions versus GDP

# Over time, CO2 emissions to create a value of \$1 tend to decrease: production becomes more CO2 efficient over time. But we need to innovate even more to actually decrease the CO2 emissions!

metric_name = 'CO2 emissions (kg per 2010 US$ of GDP)'
metric = world_bank_data[metric_name].dropna()
data = [go.Scatter(x=metric.loc[region].index.date, y=metric.loc[region], name=region) for region in zones]
add_line(metric_name, 'Total', line=dict(dash='dash'))
offline.iplot(go.Figure(data=data,
                        layout=go.Layout(
                            title=metric_name)), show_link=False)

# # What can I do?
#
# This is probably the perfect time to make our best effort!
#
# ## Spread the word, and expose data
#
# This is a global issue. People need to stay informed. Sharing information and progresses on this issue is crucial!
#
# ## Change habits
#
# At an individual level, we also need to identify activities and consumption habits that cause CO2 emissions.
#
# ## Preserve the environement
#
# Forest are natural carbon sinks, and NASA finds that they [remove as much as 30%](https://www.nasa.gov/jpl/nasa-finds-good-news-on-forests-and-carbon-dioxide) of human CO2 emissions.
#
# ## Innovate
#
# Identifying more efficient CO2 processes could allow to preserve growth, and still reduce emissions.


