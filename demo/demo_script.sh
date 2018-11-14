# # Setup
#
# ## Creating the Python environment
#
# The Python environment for our _Greenhouse gas emissions_
# notebook was created with
#
# ```bash
# conda create -n python3 jupyterlab plotly pandas pytables ipywidgets
# activate python3
# conda install -c conda-forge jupytext nbdime jupyter_contrib_nbextensions
# pip install wbdata
# jupyter nbextension enable toc2/main
# ```
#
# ## Cleanup

cd ../demo && rm .git .gitignore Greenhouse_gas_emissions.* world_bank_indicators.hdf .ipynb_checkpoints */.ipynb_checkpoints -rf

# ## Git init

git init
git config user.email "jupytext@demo.com"
git config user.name Init
echo '.ipynb_checkpoints' >> .gitignore
echo '*alice*' >> .gitignore
echo '*bob*' >> .gitignore
echo 'demo_script.sh' >> .gitignore
git add .gitignore
git commit -m 'Ignore source folders'


# # Demo I: Refactor a notebook
#
# ## Alice's initial contribution
#
# We use Alice's initial version of the notebook
# from folder `1_alice`.

cp 1_alice/Greenhouse_gas_emissions.ipynb .
cp 1_alice/world_bank_indicators.hdf .

# NOTEBOOK: Quick overview of the CO2 notebook.
#
# NOTEBOOK: Run the notebook (we will need the Python variables).
#
# ## Notebook as script

jupytext --to py Greenhouse_gas_emissions.ipynb

# PYCHARM: Quick overview of Python representation.
#
# ## Commit initial version

git config user.name Alice
git checkout -b alice
git add Greenhouse_gas_emissions.*
git add world_bank_indicators.hdf
git commit -m 'Initial notebook by Alice'

# ## Refactor the script

# PYCHARM: Change signature of 'download_once'
# (move argument 'path' to second position).

# Then update input cells in ipynb file

jupytext --to ipynb --update Greenhouse_gas_emissions.py

# ## Refresh the notebook
#
# NOTEBOOK: Refresh
# - Outputs of unchanged input cells are preserved.
# - Python variables are preserved.
#
# NOTEBOOK: Run the missing cells

git commit -am 'Changed order of args in download_once'

# GITHUB DESKTOP: Change is clear
#
# Compare notebook and script sizes:

ls -l Greenhouse_gas_emissions.*

# # Demo II: Jupytext in Jupyter, and paired notebooks

# ## Configure Jupyter

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
# Now any Python (Bash, R, Julia,...) script opens as a notebook!

# ## Paired notebooks
#
# Alices removes the Python representation of her notebook:

rm Greenhouse_gas_emissions.py

# NOTEBOOK: configure the notebook to use a pair of `ipynb` and `py` files:  
# add `"jupytext": {"formats": "ipynb,py"},` to the notebook metadata. 
#
# Then Alice saves the notebook: the py file is created automatically.

ls -l Greenhouse_gas_emissions.*

git commit -am 'Using paired notebooks'

# # Demo III: Collaborate with Jupytext
# ## First contribution by Alice
#
# Alice commits the shared notebook. Sharing the .py file is enough.
#
# She pushes to the common repository

git checkout master
git rebase alice

# ## Second contribution by Bob

git config user.name Bob
git checkout -b bob

# NOTEBOOK: Close and remove ipynb: Assume only py was shared.

rm Greenhouse_gas_emissions.ipynb

# NOTEBOOK: Re-open and run the `py` file. Save. The `ipynb` file is regenerated.

ls -l Greenhouse_gas_emissions.*

# Bob contributes! We emulate this contribution
# by copying the updated representation of the notebook.

cp 2_bob/Greenhouse_gas_emissions.py .

# NOTEBOOK: Refresh `py` notebook, run (read) and save
#
# Bob commits and pushes to the common repository

git commit -am 'Plot and comment CO2 emissions'
git checkout master
git rebase bob

# ## Simultaneous contribution by Alice
#
# Alice contributes an interactive application with Python widgets.

git config user.name Alice
git checkout alice
cp 3_alice/Greenhouse_gas_emissions.py .

# NOTEBOOK: Refresh, run and save notebook

git commit -am 'Interactive metric explorer'

# ## Resolving the conflict on the script

# A **conflict** occurs when she syncs with the common repository !!
# Note that git did not tried to merge the ipynb file.

git rebase master

# PYCHARM: Resolve the conflict on the py file.
#
# NOTEBOOK: Refresh notebook in Jupyter. Run it all. Save.

git status

git add Greenhouse_gas_emissions.*
git rebase --continue

# Push to shared repository

git checkout master
git rebase alice

# And we're done!
#
# GITHUB DESKTOP: View merge
