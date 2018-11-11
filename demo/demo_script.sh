#!/usr/bin/env bash
#############################################################################
# Create env

# conda create -n python3 jupyterlab plotly pandas pytables ipywidgets
# activate python3
# conda install -c conda-forge jupytext nbdime jupyter_contrib_nbextensions
# pip install wbdata

# Cleanup
cd ../demo && rm .git .gitignore Greenhouse_gas_emissions.* world_bank_indicators.hdf .ipynb_checkpoints */.ipynb_checkpoints -rf

# Git init
git init
echo '.ipynb_checkpoints' >> .gitignore
echo '*alice*' >> .gitignore
echo '*bob*' >> .gitignore
echo 'demo_script.sh' >> .gitignore
git add .gitignore
git commit -m 'Ignore Alice and Bob folders'

#############################################################################
# Demo I: Jupytext using the command line
# We use Alice's initial version of the notebook
cp 1_alice/Greenhouse_gas_emissions.ipynb .
cp 1_alice/world_bank_indicators.hdf .

# NOTEBOOK: Quick overview of the CO2 notebook

# Convert to Python script
jupytext --to py Greenhouse_gas_emissions.ipynb

# Commit initial version
git checkout -b alice
git add Greenhouse_gas_emissions.*
git add world_bank_indicators.hdf
git commit -am 'Initial notebook by Alice'

# PYCHARM: Change signature of 'download_once'

# Then update input cells in ipynb file
jupytext --to ipynb --update Greenhouse_gas_emissions.py

# NOTEBOOK: Refresh
# - Outputs of unchanged input cells are preserved.
# - Python variables are preserved.

git commit -am 'Changed order of args in download_once'

# GITHUB DESKTOP: Change is clear
# Application: distribute a notebook in a package
# in the form of a Python script. The notebook is
# automatically updated when the package is refactored.

#############################################################################
# Demo II: Paired notebooks

# NOTEBOOK CONFIG: Add
# c.NotebookApp.contents_manager_class = "jupytext.TextFileContentsManager"
# to the Jupyter notebook config file:
# Windows: C:\Users\Marc\.jupyter\jupyter_notebook_config.py
# Linux: ~/.jupyter/jupyter_notebook_config.py

rm Greenhouse_gas_emissions.py

# NOTEBOOK: Add "jupytext": {"formats": "ipynb,py"}, to the notebook
# metadata. Save the notebook: the py file is created automatically.

#############################################################################
# Demo III: How to collaborate

######### Alice ###########

# Alice commits the shared notebook. Sharing the .py file
# would be enough - later we will remove the ipynb file.
git commit -am 'Using paired notebooks'

# Alice pushes to the common repository
git checkout master
git rebase alice

########## Bob ###########
git checkout -b bob

# NOTEBOOK: Close and remove ipynb: Assume only py was shared
rm Greenhouse_gas_emissions.ipynb

# Bob contributes!
cp 2_bob/Greenhouse_gas_emissions.py .

# NOTEBOOK: Open 'py' notebook, run (read) and save

# Bob contributes
git commit -am 'Plot and comment CO2 emissions'

# And pushes to the common repository
git checkout master
git rebase bob

########## Alice, at the same time ######
git checkout alice
cp 3_alice/Greenhouse_gas_emissions.py .

# NOTEBOOK: Refresh, run and save notebook

git commit -am 'Metric explorer'

# Sync with common repository: conflict !!
# Note that git did not tried to merge the ipynb file.
git rebase master

# PYCHARM: Resolve the conflict on the py file
# NOTEBOOK: Refresh notebook in Jupyter
git add Greenhouse_gas_emissions.*
git rebase --continue

# Push to shared repository
git checkout master
git rebase alice

# And we're done!
