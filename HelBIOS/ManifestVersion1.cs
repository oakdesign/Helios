using System;
using System.Collections.Generic;
using System.Text.Json.Serialization;

namespace net.derammo.HelBIOS.ManifestVersion1
{
    [Serializable]
    public class ModuleDefinition : Dictionary<string, DeviceDefinition>
    {
    }

    [Serializable]
    public class DeviceDefinition : Dictionary<string, ItemDefinition>
    {
    }

    [Serializable]
    public class ItemDefinition
    {
        public string category { get; set; }
        public enum ControlType
        {
            UNSET,
            action,
            analog_dial,
            analog_gauge,
            discrete_dial,
            display,
            electrically_held_switch,
            emergency_parking_brake,
            fixed_step_dial,
            frequency,
            LANTIRN_Led_Booth,
            LANTIRN_Led_Bottom,
            LANTIRN_Led_Top,
            led,
            limited_dial,
            metadata,
            mission_computer_switch,
            Multi_Led_Color_1,
            Multi_Led_Color_2,
            selector,
            toggle_switch,
            variable_step_dial
        }
        public ControlType control_type { get; set; }
        public enum ApiVariant
        {
            momentary_last_position,
            multiturn
        }
        public ApiVariant api_variant { get; set; }
        public string description { get; set; }
        public string identifier { get; set; }
        public class Input
        {
            public enum Interface
            {
                UNSET,
                action,
                BcdWheel,
                fixed_step,
                set_state,
                variable_step
            }
            public string description { get; set; }
            [JsonPropertyName("interface")]
            public Interface _interface { get; set; }
            public int max_value { get; set; }
            public enum Argument
            {
                UNSET,
                TOGGLE,
                TOGGLE_XY
            }
            public Argument argument { get; set; }
        }
        public Input[] inputs { get; set; }
        public class Output
        {
            public int address { get; set; }
            public int max_length { get; set; }
            public string description { get; set; }
            public int mask { get; set; }
            public int max_value { get; set; }
            public int shift_by { get; set; }
            public string suffix { get; set; }
            public enum Type
            {
                UNSET,
                _string,
                integer
            }
            public Type type { get; set; }
        }
        public Output[] outputs { get; set; }
        public enum MomentaryPositions
        {
            UNSET,
            first_and_last,
            last,
            none
        }
        public MomentaryPositions momentary_positions { get; set; }
        public enum PhysicalVariant
        {
            UNSET,
            _3_position_switch,
            button_light,
            infinite_rotary,
            limited_rotary,
            push_button,
            rocker_switch,
            toggle_switch
        }
        public PhysicalVariant physical_variant { get; set; }
    }
}
