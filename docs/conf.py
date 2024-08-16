# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'NES Emulator'
copyright = '2024, Matyas Daniel'
author = 'Matyas Daniel'
release = '0.1'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = ['sphinxvhdl.vhdl', 'sphinxcontrib.bibtex']
bibtex_bibfiles = ['refs.bib']

latex_table_style = ['standard', 'colorrows']

latex_elements = {
    'preamble': r'''
    \usepackage{pdfpages}
    \usepackage{pdflscape}
    '''
}


templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']



# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'alabaster'
html_static_path = ['_static']
