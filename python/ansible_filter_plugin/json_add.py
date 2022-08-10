#!/usr/bin/env python3
# TODO nedd develop logic for handling strucutre with figure element
# TODO review function 'json_add'. Compare wuth git version

from ansible.errors import AnsibleFilterError
from ansible.module_utils.common.text.converters import to_native

# This filter-plugin are using for add/or replace some value from json variable. Below, example for use
# Variable before '| json_select' it's variable which you get in finale
# if value in {} exist in real payload, plugin replace they, else, add
#
# my_vars: "{{ my_vars | json_add( ['exmpl_item', 'data', 2], {'example1': '333.333.333.333', 'string': 'value'} )  }}"
# my_vars: "{{ my_vars | json_add( ['exmpl_item', 'data'], {'example2': '333.333.333.333', 'string': 'value'} )  }}"
# my_vars: "{{ my_vars.exmpl_item.data | json_add( '', {'example2': '333.333.333.333', 'string': 'value'} )  }}"
# my_vars: "{{ my_vars.exmpl_item.data[4] | json_add('', {'example2': '333.333.333.333'} )  }}"
# my_vars: "{{ my_vars.domain_alias.data | json_add( 2, {'example2': '333.333.333.333', 'example1': 'maybe'}} )  }}"


class FilterModule(object):

    def filters(self):
        return {
            'json_add': self.json_add
        }

    def jmagik(self, jbody, jpth, jfil):
        countr1 = True
        if jpth != "" and type(jpth) is not int:
            jvar = jbody
            for i in jpth:
                jvar = jvar[i]
        elif type(jpth) is int:
            jvar = jbody[jpth]
        else:
            jvar = jbody
        if type(jvar) is not list:
            jvar = [jvar]
            countr1 = False
        for nm in range(len(jvar)):
            for i in list((jvar[nm])):
                jvar[nm].update(jfil)
        if countr1 == False:
            jvar = jvar[0]
        return jvar

    def json_add(self, jbody, jpth, jfil):
        try:
            if(jpth != "" and type(jpth) is not int):
                jbody[str(jpth)] = self.jmagik(jbody, jpth, jfil)
                del jbody[str(jpth)]
            elif(type(jpth) is int):
                jbody[jpth] = self.jmagik(jbody, jpth, jfil)
            else:
                jbody = self.jmagik(jbody, jpth, jfil)
            return jbody
        except Exception as Err_Vl:
            raise AnsibleFilterError(
                "Something happened, this was the original exception: %s" % to_native(Err_Vl))
