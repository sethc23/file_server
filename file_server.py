#!/home/ub2/.virtualenvs/devenv/bin/python
# PYTHON_ARGCOMPLETE_OK
# _ARC_DEBUG
"""

Manages file_server

"""
from __init__ import *


class FileServer:
    """a fileserver"""

    def __init__ (self):
        """ 
        """
        import os
        self.T                              =   {}
        self.config                         =   {}
        self.PG                             =   {}

    def _init_config_(self, config_file=open(os.path.dirname(os.path.abspath(__file__)) + '/config.yaml')):
        """
           Read in the yaml config file

           :param config_file: Configuration file (YAML format)
           :type config_file: file
           :returns: dict of yaml file
           :rtype: dict
        """
        import yaml
        with config_file:
            return yaml.load(config_file)

    def _init_pgsql_(self):
        if not self.config:
            self.config                     =   self._init_config_()

        self.PG                             =   pgSQL(**self.config)
        self.config                         =   self.PG.T.config
        self.T                              =   self.PG.T

        all_imports                         =   locals().keys()
        excludes                            =   ['self','_parent']
        for k in all_imports:
            if not excludes.count(k):
                self.T.update(                  {k                          :   eval(k) })
        self.T.update(                          self.PG.T.__dict__)
        
    def _check_and_build_pgsql(self,verbose=True):
        self.PG.F.functions_run_confirm_extensions(exts=['plpythonu','pllua','plshu'],verbose=verbose)
        
        # Standard Triggers
        self.PG.F.triggers_create_z_auto_add_primary_key()
        self.PG.F.triggers_create_z_auto_add_last_updated_field()
        self.PG.F.triggers_create_z_array_sort()
        self.PG.F.functions_create_batch_groups(sub_dir='----',
                                                grps=['json'],
                                                files=['all'])
        # Basic table for gmail
        self.PG.F.functions_create_batch_groups(sub_dir='../sql_exts',
                                                grps=['gmail_tables'],
                                                files=['1_gmail.sql'])
        # File Index Table
        self.PG.F.functions_create_batch_groups(sub_dir='../sql_exts',
                                                grps=['file_tables'],
                                                files=['all'])
        # File Server Functions
        self.PG.F.functions_create_batch_groups(sub_dir='../sql_exts',
                                                grps=['functions'],
                                                files=['all'])

        # File Server Triggers
        self.PG.F.functions_create_batch_groups(sub_dir='../sql_exts',
                                                grps=['triggers'],
                                                files=['all'])

    def _delete_all_pgsql(self,confirm=True):
        qry = """
            DROP TABLE IF EXISTS file_idx;
            DROP FUNCTION IF EXISTS zf_pdf_metadata( TEXT ) CASCADE;

            """
        # self.T.to_sql(qry)

    def all_gmail(self):
        """syncs gmail"""
        if not self.config:
            self.config = self._init_config_()
            self.pgsql = self._init_pgsql_()
        from google_tools.google_main import Google
        G = Google(self,**self.T.config.gmail.__dict__)
        # G.Gmail.all_mail(method='full')
        G.Gmail.all_mail(method='quick')



if __name__ == '__main__':
    
    run_custom_argparse()
    # all_gmail()