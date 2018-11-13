# # Setup
#
# ## Creating the Python environment
#
# The Python environment for our _Greenhouse gas emissions_ notebook was created with
#
# ```bash
# conda create -n python3 jupyterlab plotly pandas pytables ipywidgets
# activate python3
# conda install -c conda-forge jupytext nbdime jupyter_contrib_nbextensions
# pip install wbdata
# ```
#
# ## Cleanup

cd ../demo && rm .git .gitignore Greenhouse_gas_emissions.* world_bank_indicators.hdf .ipynb_checkpoints */.ipynb_checkpoints -rf

# ## Git init

# +
git init
git config user.email "jupytext@demo.com"
git config user.name "demo"
echo '.ipynb_checkpoints' >> .gitignore
echo '*alice*' >> .gitignore
echo '*bob*' >> .gitignore
echo 'demo_script.sh' >> .gitignore
git add .gitignore
git commit -m 'Ignore Alice and Bob folders'

#'git lg' from https://coderwall.com/p/euwpig/a-better-git-log
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
# -

# # Demo I: Refactor a notebook
#
# ## Alice's initial contribution
#
# We use Alice's initial version of the notebook, from folder `1_alice`.

cp 1_alice/Greenhouse_gas_emissions.ipynb .
cp 1_alice/world_bank_indicators.hdf .

# NOTEBOOK: Quick overview of the CO2 notebook
#
# ## Notebook as script

jupytext --to py Greenhouse_gas_emissions.ipynb

# ## Commit initial version

git checkout -b alice
git add Greenhouse_gas_emissions.*
git add world_bank_indicators.hdf
git commit -am 'Initial notebook by Alice'

# ## Refactor the script

# PYCHARM: Change signature of 'download_once'

# Then update input cells in ipynb file
jupytext --to ipynb --update Greenhouse_gas_emissions.py

# ## Refresh the notebook

# NOTEBOOK: Refresh
# - Outputs of unchanged input cells are preserved.
# - Python variables are preserved.

git commit -am 'Changed order of args in download_once'

# GITHUB DESKTOP: Change is clear

# ## An application: up-to-date examples
#
# Example notebook distributed as a script in a Python package: the notebook is automatically updated when the package is refactored.

# # Demo II: Paired notebooks

# ## Jupyter configuration
#
# We first remove the Python script:

rm Greenhouse_gas_emissions.py

# Now we activate paired notebooks by adding
# ```
# c.NotebookApp.contents_manager_class = "jupytext.TextFileContentsManager"
# ```
# to the Jupyter notebook config file, that is
# - `C:\Users\Marc\.jupyter\jupyter_notebook_config.py` on Windows, and
# - `~/.jupyter/jupyter_notebook_config.py` on Linux.
#
# We need to restart `jupyter notebook` or `jupyter lab`.
#
# We add `"jupytext": {"formats": "ipynb,py"},` to the metadata of our notebook. 
#
# Save the notebook: the py file is created automatically.

# # Demo III: Collaborate with Jupytext
# ## First contribution by Alice
#
# Alice commits the shared notebook. Sharing the .py file would be enough - later we will remove the ipynb file.

git commit -am 'Using paired notebooks'

# She pushes to the common repository

git checkout master
git rebase alice

# ## Second contribution by Bob

git checkout -b bob

# NOTEBOOK: Close and remove ipynb: Assume only py was shared. Re-open and run the `py` file.

rm Greenhouse_gas_emissions.ipynb

# Bob contributes! We emulate this contribution by copying the updated script.

cp 2_bob/Greenhouse_gas_emissions.py .

# NOTEBOOK: Open 'py' notebook, run (read) and save
#
# Bob commits and pushes to the common repository

git commit -am 'Plot and comment CO2 emissions'

# And pushes to the common repository
git checkout master
git rebase bob

# ## Simultaneous contribution by Alice

git checkout alice
cp 3_alice/Greenhouse_gas_emissions.py .

# NOTEBOOK: Refresh, run and save notebook

git commit -am 'Metric explorer'

# ## Resolving the conflict on the script

# A **conflict** occurs when she syncs with the common repository !!
# Note that git did not tried to merge the ipynb file.

git rebase master

# PYCHARM: Resolve the conflict on the py file
#
# NOTEBOOK: Refresh notebook in Jupyter

git add Greenhouse_gas_emissions.*
git rebase --continue

# Push to shared repository

git checkout master
git rebase alice

# And we're done!

# ## Git log

git lg
