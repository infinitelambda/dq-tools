import shutil
import os

def copy_dbt_docs(config, **kwargs):
    site_dir = config['site_dir']
    shutil.copytree("integration_tests/target/", os.path.join(site_dir, 'dbt-docs'))