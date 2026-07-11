//
//  CoolPropBridge.h
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/5/26.
//

#pragma once

#ifdef __cplusplus
extern "C" {
#endif

double coolprop_props(
    const char* output,
    const char* input1, double val1,
    const char* input2, double val2,
    const char* fluid
);

const char* coolprop_error(void);

const char* get_fluids_list(void);

const char* get_fluid_property(const char* fluid, const char* property);

int set_fluid_reference_state(const char* fluid_name, const char* reference_state);

const char* get_coolprop_version(void);

#ifdef __cplusplus
}
#endif
