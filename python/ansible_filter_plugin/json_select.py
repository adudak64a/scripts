#!/usr/bin/env python3

from ansible.errors import AnsibleFilterError
from ansible.module_utils.common.text.converters import to_native

# This filter-plugin are using for select or/and delete some value from json variable. Below, example for use
# Variable before | json_select it's variable which you get in finale
#
# my_vars: "{{ example.data.exmpl_item | json_select('', ['ip','domain','phpversion','customlog','phpopenbasedirprotect']) }}"
# my_vars: "{{ example | json_select(['data','exmpl_item'], ['ip','domain','phpversion','customlog','phpopenbasedirprotect']) }}"
# my_vars: "{{ example.data | json_select(['exmpl_item',0], ['ip','domain','phpversion','customlog','phpopenbasedirprotect']) }}"
# my_vars: "{{ example.data.exmpl_item | json_select(2, ['ip','domain','phpversion','customlog','phpopenbasedirprotect']) }}"


class FilterModule(object):
    def filters(self):
        return {
            'json_select': self.json_select
        }

    def jmagik(self, jbody, jpth, jfil):
        countr = 0
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
                countr = 0
                for j in jfil:
                    if j != i:
                        countr += 1
                if(countr == len(jfil)):
                    jvar[nm].pop(i)
        if countr1 == False:
            jvar = jvar[0]
        return jvar

    def json_select(self, jbody, jpth, jfil):
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
