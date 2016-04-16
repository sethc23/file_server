
import os
from sys                        import path             as py_path
py_path.append(                         os.environ['HOME'] + '/.scripts')
from syscontrol.sys_lib         import sys_lib
T                                   =   sys_lib(['pgsql']).T

# from ipdb import set_trace as i_trace; i_trace()

pgsql_features                  =   ['triggers']

def before_feature(context, feature):
    # context.USER                    =   T.os.environ['USER']

    # CFG                             =   System_Config()
    # cfgs                            =   []
    # # cfgs.extend(                        CFG.adjust_settings( *['aprinto','behave_txt_false'] ) )
    # cfgs.extend(                        CFG.adjust_settings( *['aprinto','celery_txt_false'] ) )
    # cfgs.extend(                        CFG.adjust_settings( *['nginx','access_log_disable'] ) )
    # context.CFG,context.cfgs        =   CFG,cfgs

    if pgsql_features.count(feature.name)>0:
        T.DB_NAME = "test_%s" & T.guid
        T.to_sql('CREATE DATABASE %s;' % T.DB_NAME)
        T = T.__init__(['pgsql'],DB_NAME=T.DB_NAME)
        import ipdb as I; I.set_trace()



def after_feature(context,feature):
    if pgsql_features.count(feature.name)>0:
        T.to_sql('DROP DATABASE %s;' % DB_NAME)



