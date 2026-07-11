//
//  CoolPropBridge.mm
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/5/26.
//

#include "CoolPropBridge.h"
#include "CoolProp.h"
#include <string>

static std::string lastError;

extern "C" {
    double coolprop_props(
        const char* output,
        const char* input1, double val1,
        const char* input2, double val2,
        const char* fluid
    ) {
        try {
            return CoolProp::PropsSI(output, input1, val1, input2, val2, fluid);
        } catch (const std::exception& e) {
            lastError = e.what();
            return -1.0;
        } catch (...) {
            lastError = "Unknown error";
            return -1.0;
        }
    }

    const char* coolprop_error(void) {
        return lastError.c_str();
    }

   

// Function to get the list of fluids in the library
    const char* get_fluids_list(void) {
        try {
            static std::string fluids = CoolProp::get_global_param_string("FluidsList");
            return fluids.c_str();
        } catch (const std::exception& e) {
            lastError = e.what();
            return  "";
        } catch(...) {
            lastError = "Failed to fetch fluids list";
            return  "";
        }
    }
    
// Function to get the properties of the fluid 
    const char* get_fluid_property(const char* fluid, const char* property) {
        try {
            static std::string result;
            result = CoolProp::get_fluid_param_string(fluid, property);
            return result.c_str();
        } catch (...) {
            return  "false";
        }
    }

    int set_fluid_reference_state(const char* fluid_name, const char* reference_state) {
        try {
            // CoolProp expects std::string for this function
            std::string fluid(fluid_name);
            std::string state(reference_state);
            
            CoolProp::set_reference_stateS(fluid, state);
            return 1; // Success
            
        } catch (const std::exception& e) {
            // Optional: If you have a global error string pointer like you do for coolprop_error(),
            // you could set it here using e.what()
            return 0; // Failure
        } catch (...) {
            return 0; 
        }
    }

    // getting CoolProp lib version
    const char* get_coolprop_version(void) {
        try {
            static std::string version = CoolProp::get_global_param_string("version");
            return version.c_str();
        } catch (...) {
            return "Unknown";
        }
    }

}


