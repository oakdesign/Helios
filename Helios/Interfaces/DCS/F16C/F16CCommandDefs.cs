using System;

namespace GadrocsWorkshop.Helios.Interfaces.DCS.F16C
{
    enum Keys : int
    {
        iCommandPlaneWheelBrakeOn		= 74,
	    iCommandPlaneWheelBrakeOff		= 75,	
	    iCommandPlaneThrustCommon		= 2004
    }
    enum device_commands : int {
        Button_1 = 3000,
        Button_2,
        Button_3,
        Button_4,
        Button_5,
        Button_6,
        Button_7,
        Button_8,
        Button_9,
        Button_10,
        Button_11,
        Button_12,
        Button_13,
        Button_14,
        Button_15,
        Button_16,
        Button_17,
        Button_18,
        Button_19,
        Button_20,
        Button_21,
        Button_22,
        Button_23,
        Button_24,
        Button_25,
        Button_26,
        Button_27,
        Button_28,
        Button_29,
        Button_30,
        Button_31,
        Button_32,
        Button_33,
        Button_34,
        Button_35,
        Button_36,
        Button_37,
        Button_38,
        Button_39,
        Button_40,
        Button_41,
        Button_42,
        Button_43,
        Button_44,
        Button_45,
        Button_46,
        Button_47,
        Button_48,
        Button_49,
        Button_50,
        Button_51,
        Button_52,
        Button_53,
        Button_54,
        Button_55,
        Button_56,
        Button_57,
        Button_58,
        Button_59,
        Button_60,
        Button_61,
        Button_62,
        Button_63,
        Button_64,
        Button_65,
        Button_66,
        Button_67,
        Button_68,
        Button_69,
        Button_70
    }

    enum control_commands : int
    {
        DigitalBackup = 3000
    , AltFlaps
    , BitSw
    , FlcsReset
    , LeFlaps
    , TrimApDisc
    , RollTrim
    , PitchTrim
    , YawTrim
    , ManualPitchOverride
    , StoresConfig
    , ApPitchAtt
    , ApPitchAlt
    , ApRoll
    , AdvMode
    , ManualTfFlyup
    , ThrottleFriction
    , AB_DETENT
    , DigitalBackup_ITER
    , AltFlaps_ITER
    , LeFlaps_ITER
    , TrimApDisc_ITER
    , RollTrim_ITER
    , RollTrim_AXIS
    , PitchTrim_ITER
    , PitchTrim_AXIS
    , YawTrim_ITER
    , YawTrim_AXIS
    , ManualPitchOverride_ITER
    , StoresConfig_ITER
    , ApPitchAtt_EXT
    , ApPitchAlt_EXT
    , ApRoll_ITER
    , AdvMode_ITER
    , ManualTfFlyup_ITER
    , ThrottleFriction_ITER
    }
    enum elec_commands : int
    {
        MainPwrSw = 3000
    , CautionResetBtn
    , FlcsPwrTestSwMAINT
    , FlcsPwrTestSwTEST
    , EPU_GEN_TestSw
    , ProbeHeatSw
    , MainPwrSw_ITER
    , FlcsPwrTestSw_ITER
    , EPU_GEN_TestSw_ITER
    , ProbeHeatSw_EXT
    , ProbeHeatSw_ITER
    }
    enum fuel_commands : int
    {
        FuelMasterSw = 3000
    , FuelMasterSwCvr
    , ExtFuelTransferSw
    , EngineFeedSw
    , FuelQtySelSw
    , FuelQtySelSwTEST
    , TankInertingSw
    , AirRefuelSw
    , FuelMasterSw_ITER
    , FuelMasterSwCvr_ITER
    , ExtFuelTransferSw_ITER
    , EngineFeedSw_ITER
    , FuelQtySelSw_ITER
    , TankInertingSw_ITER
    , AirRefuelSw_ITER
    }
    enum engine_commands : int
    {
        EpuSwCvrOn = 3000
    , EpuSwCvrOff
    , EpuSw
    , EngAntiIceSw
    , JfsSwStart1
    , JfsSwStart2
    , EngContSwCvr
    , EngContSw
    , MaxPowerSw
    , ABResetSwReset
    , ABResetSwEngData
    , FireOheatTestBtn
    , EpuSwCvrOn_ITER
    , EpuSwCvrOff_ITER
    , EpuSw_ITER
    , EngAntiIceSw_ITER
    , EngContSwCvr_ITER
    , EngContSw_ITER
    , MaxPowerSw_ITER
    }
    enum gear_commands : int
    {
        LGHandle = 3000
    , DownLockRelBtn
    , ParkingSw
    , AntiSkidSw
    , BrakesChannelSw
    , HookSw
    , HornSilencerBtn
    , AltGearHandle
    , AltGearResetBtn
    , AntiSkidSw_EXT
    , BrakesChannelSw_ITER
    , HookSw_ITER
    }
    enum oxygen_commands : int
    {
        SupplyLever = 3000
    , DiluterLever
    , EmergencyLever
    , ObogsBitSw
    , SupplyLever_ITER
    , DiluterLever_ITER
    , EmergencyLever_ITER
    , ObogsBitSw_ITER
    }
    enum cpt_commands : int
    {
        CanopyHandcrank = 3000
    , CanopySwitchOpen
    , CanopySwitchClose
    , CanopyHandle
    , CanopyTHandle
    , EjectionHandle
    , ShoulderHarnessKnob
    , EmergencyOxygenGreenRing
    , EjectionSafetyLever
    , RadioBeaconSwitch
    , SurvivalKitDeploymentSwitch
    , EmergencyManualChuteHandle
    , SeatAdjSwitchUp
    , SeatAdjSwitchDown
    , CanopyHandcrank_ITER
    , CanopySwitch_ITER
    , CanopyHandle_ITER
    , CanopyTHandle_ITER
    , ShoulderHarnessKnob_ITER
    , EjectionSafetyLever_ITER
    , RadioBeaconSwitch_ITER
    , SurvivalKitDeploymentSwitch_ITER
    }
    enum extlights_commands : int
    {
        AntiCollKn = 3000
    , PosFlash
    , PosWingTail
    , PosFus
    , FormKn
    , Master
    , AerialRefuel
    , LandingTaxi
    , AntiCollKn_ITER
    , PosFlash_ITER
    , PosWingTail_ITER
    , PosFus_ITER
    , FormKn_ITER
    , FormKn_AXIS
    , Master_ITER
    , AerialRefuel_ITER
    , AerialRefuel_AXIS
    , LandingTaxi_ITER
    }
    enum cptlights_commands : int
    {
        MasterCaution = 3000
    , MalIndLtsTest
    , Consoles
    , IntsPnl
    , DataEntryDisplay
    , ConsolesFlood
    , InstPnlFlood
    , MalIndLtsBrt
    , MalIndLtsDim
    , Consoles_EXT
    , Consoles_AXIS
    , IntsPnl_EXT
    , IntsPnl_AXIS
    , DataEntryDisplay_EXT
    , DataEntryDisplay_AXIS
    , ConsolesFlood_EXT
    , ConsolesFlood_AXIS
    , InstPnlFlood_EXT
    , InstPnlFlood_AXIS
    , UtilityBrt_ITER
    , UtilityBrt_AXIS
    }
    enum hotas_commands : int
    {
        STICK_NWS_AR_DISC_MSL_STEP = 3000
    , STICK_TRIMMER_UP
    , STICK_TRIMMER_DOWN
    , STICK_TRIMMER_LEFT
    , STICK_TRIMMER_RIGHT
    , STICK_DISP_MANAGE_UP
    , STICK_DISP_MANAGE_DOWN
    , STICK_DISP_MANAGE_LEFT
    , STICK_DISP_MANAGE_RIGHT
    , STICK_TGT_MANAGE_UP
    , STICK_TGT_MANAGE_DOWN
    , STICK_TGT_MANAGE_LEFT
    , STICK_TGT_MANAGE_RIGHT
    , STICK_CMS_MANAGE_FWD
    , STICK_CMS_MANAGE_AFT
    , STICK_CMS_MANAGE_LEFT
    , STICK_CMS_MANAGE_RIGHT
    , STICK_EXPAND_FOV
    , STICK_PADDLE
    , STICK_TRIGGER_1ST_DETENT
    , STICK_TRIGGER_2ND_DETENT
    , STICK_WEAPON_RELEASE
    , THROTTLE_CUTOFF_RELEASE
    , THROTTLE_TRANSMIT_FWD
    , THROTTLE_TRANSMIT_AFT
    , THROTTLE_TRANSMIT_LEFT
    , THROTTLE_TRANSMIT_RIGHT
    , THROTTLE_MAN_RNG
    , THROTTLE_UNCAGE
    , THROTTLE_DOG_FIGHT
    , THROTTLE_SPEED_BRAKE
    , THROTTLE_ANT_ELEV_AXIS
    , THROTTLE_ANT_ELEV_UP
    , THROTTLE_ANT_ELEV_DOWN
    , THROTTLE_RDR_CURSOR_FWD
    , THROTTLE_RDR_CURSOR_AFT
    , THROTTLE_RDR_CURSOR_LEFT
    , THROTTLE_RDR_CURSOR_RIGHT
    , THROTTLE_ENABLE
    //,--	THROTTLE_MAN_RNG_ITER
    //,--	THROTTLE_MAN_RNG_AXIS
    , THROTTLE_MAN_RNG_INC
    , THROTTLE_MAN_RNG_DEC
    , THROTTLE_DOG_FIGHT_ITER
    , THROTTLE_DOG_FIGHT_CYCL
    , THROTTLE_DOG_FIGHT_EXT
    , THROTTLE_SPEEDSPEED_BRAKE_EXT
    , THROTTLE_RDR_CURSOR_Y_AXIS
    , THROTTLE_RDR_CURSOR_X_AXIS
    }
    enum ecs_commands : int
    {
        AirSourceKnob = 3000
    , TempKnob
    , DefogLever
    , AirSourceKnob_ITER
    , TempKnob_ITER
    , TempKnob_AXIS
    , DefogLever_ITER
    , DefogLever_AXIS
    }
    enum ufc_commands : int
    {
        UFC_Sw = 3000
    , DIG0_M_SEL
    , DIG1_T_ILS
    , DIG2_ALOW
    , DIG3
    , DIG4_STPT
    , DIG5_CRUS
    , DIG6_TIME
    , DIG7_MARK
    , DIG8_FIX
    , DIG9_A_CAL
    , COM1
    , COM2
    , IFF
    , LIST
    , ENTR
    , RCL
    , AA
    , AG
    , RET_DEPR_Knob
    , CONT_Knob
    , SYM_Knob
    , BRT_Knob
    , Wx
    , FLIR_INC
    , FLIR_DEC
    , FLIR_GAIN_Sw
    , DRIFT_CUTOUT
    , WARN_RESET
    , DED_INC
    , DED_DEC
    , DCS_RTN
    , DCS_SEQ
    , DCS_UP
    , DCS_DOWN
    , F_ACK
    , IFF_IDENT
    , RF_Sw
    , UFC_Sw_ITER
    , SYM_Knob_ITER
    , SYM_Knob_AXIS
    , RET_DEPR_Knob_ITER
    , RET_DEPR_Knob_AXIS
    , BRT_Knob_ITER
    , BRT_Knob_AXIS
    , CONT_Knob_ITER
    , CONT_Knob_AXIS
    , FLIR_GAIN_Sw_ITER
    , DriftCO_WarnReset_ITER
    , RF_Sw_ITER
    }
    enum mmc_commands : int
    {
        MmcPwr = 3000
    , MasterArmSw
    , EmerStoresJett
    , GroundJett
    , AltRel
    , VvVah
    , AttFpm
    , DedData
    , DeprRet
    , Spd
    , Alt
    , Brt
    , Test
    , MFD
    , MmcPwr_ITER
    , MasterArmSw_ITER
    , MasterArmSw_EXT
    , GroundJett_ITER
    , VvVah_EXT
    , AttFpm_EXT
    , DedData_EXT
    , DeprRet_EXT
    , Spd_EXT
    , Alt_EXT
    , Brt_EXT
    , Test_EXT
    , MFD_ITER
    }
    enum fcr_commands : int
    {
        PwrSw = 3000
    , PwrSw_ITER
    }
    enum ralt_commands : int
    {
        PwrSw = 3000
    , PwrSw_ITER
    }
    enum sms_commands : int
    {
        StStaSw = 3000
    , LeftHDPT
    , RightHDPT
    , LaserSw
    , StSta_ITER
    , LeftHDPT_ITER
    , RightHDPT_ITER
    , LaserSw_ITER
    }
    enum hmcs_commands : int
    {
        IntKnob = 3000
    , IntKnob_ITER
    , IntKnob_AXIS
    }
    enum rwr_commands : int
    {
        IntKnob = 3000
    , Handoff
    , Launch
    , Mode
    , UnknownShip
    , SysTest
    , TgtSep
    , BrtKnob
    , Search
    , ActPwr
    , Power
    , Altitude
    , IntKnob_ITER
    , IntKnob_AXIS
    , BrtKnob_ITER
    , BrtKnob_AXIS
    , Power_ITER
    }
    enum cmds_commands : int
    {
        RwrSrc = 3000
    , JmrSrc
    , MwsSrc
    , Jett
    , O1Exp
    , O2Exp
    , ChExp
    , FlExp
    , Prgm
    , Mode
    , DispBtn
    , RwrSrc_ITER
    , JmrSrc_ITER
    , MwsSrc_ITER
    , Jett_ITER
    , O1Exp_ITER
    , O2Exp_ITER
    , ChExp_ITER
    , FlExp_ITER
    , Prgm_ITER
    , Mode_ITER
    }
    enum sai_commands : int
    {
        test = 3000
    , cage
    , reference
    , power
    , reference_EXT
    , power_EXT
    , cage_EXT
    , reference_AXIS
    }
    enum intercom_commands : int
    {
        COM1_PowerKnob = 3000
    , COM1_ModeKnob
    , COM2_PowerKnob
    , COM2_ModeKnob
    , SecureVoiceKnob
    , MSL_ToneKnob
    , TF_ToneKnob
    , THREAT_ToneKnob
    , ILS_PowerKnob
    , TACAN_Knob
    , INTERCOM_Knob
    , HotMicCipherSw
    , IFF_AntSelSw
    , UHF_AntSelSw
    , VMS_InhibitSw
    , PlainCipherSw
    , ZeroizeSwCvr
    , ZeroizeSw
    , COM1_PowerKnob_ITER
    , COM1_PowerKnob_AXIS
    , COM1_ModeKnob_ITER
    , COM2_PowerKnob_ITER
    , COM2_PowerKnob_AXIS
    , COM2_ModeKnob_ITER
    , SecureVoiceKnob_ITER
    , SecureVoiceKnob_AXIS
    , MSL_ToneKnob_ITER
    , MSL_ToneKnob_AXIS
    , TF_ToneKnob_ITER
    , TF_ToneKnob_AXIS
    , THREAT_ToneKnob_ITER
    , THREAT_ToneKnob_AXIS
    , ILS_PowerKnob_ITER
    , ILS_PowerKnob_AXIS
    , TACAN_Knob_ITER
    , TACAN_Knob_AXIS
    , INTERCOM_Knob_ITER
    , INTERCOM_Knob_AXIS
    , HotMicCipherSw_ITER
    , IFF_AntSelSw_ITER
    , UHF_AntSelSw_ITER
    , VMS_InhibitSw_ITER
    , PlainCipherSw_ITER
    , ZeroizeSwCvr_ITER
    , ZeroizeSw_ITER
    }
    enum uhf_commands : int
    {
        ChannelKnob = 3000
    , FreqSelector100Mhz
    , FreqSelector10Mhz
    , FreqSelector1Mhz
    , FreqSelector01Mhz
    , FreqSelector0025Mhz
    , FreqModeKnob
    , FunctionKnob
    , TToneSw
    , SquelchSw
    , VolumeKnob
    , TestDisplayBtn
    , StatusBtn
    , AccessDoor
    , LoadBtn
    , ZeroSw
    , MnSq
    , GdSq
    , FunctionKnob_ITER
    , FreqModeKnob_ITER
    , TToneSw_ITER
    , SquelchSw_ITER
    , VolumeKnob_ITER
    , VolumeKnob_AXIS
    , AccessDoor_ITER
    , ZeroSw_ITER
    , FreqSelector100Mhz_ITER
    }
    enum iff_commands : int
    {
        CNI_Knob = 3000
    , MasterKnob
    , M4CodeSw
    , M4ReplySw
    , M4MonitorSw
    , EnableSw
    , M1M3Selector1_Inc
    , M1M3Selector1_Dec
    , M1M3Selector2_Inc
    , M1M3Selector2_Dec
    , M1M3Selector3_Inc
    , M1M3Selector3_Dec
    , M1M3Selector4_Inc
    , M1M3Selector4_Dec
    , CNI_Knob_ITER
    , MasterKnob_ITER
    , M4CodeSw_ITER
    , M4ReplySw_ITER
    , M4MonitorSw_ITER
    , EnableSw_ITER
    }
    enum ky58_commands : int
    {
        KY58_ModeSw = 3000
    , KY58_FillSw
    , KY58_FillSw_Pull
    , KY58_PowerSw
    , KY58_Volume
    , KY58_ModeSw_ITER
    , KY58_FillSw_ITER
    , KY58_PowerSw_ITER
    , KY58_Volume_ITER
    , KY58_Volume_AXIS
    }
    enum mfd_commands : int
    {
        OSB_1 = 3000
        , OSB_2
        , OSB_3
        , OSB_4
        , OSB_5
        , OSB_6
        , OSB_7
        , OSB_8
        , OSB_9
        , OSB_10
        , OSB_11
        , OSB_12
        , OSB_13
        , OSB_14
        , OSB_15
        , OSB_16
        , OSB_17
        , OSB_18
        , OSB_19
        , OSB_20
        , GAIN_Rocker_UP
        , GAIN_Rocker_DOWN
        , SYM_Rocker_UP
        , SYM_Rocker_DOWN
        , CON_Rocker_UP
        , CON_Rocker_DOWN
        , BRT_Rocker_UP
        , BRT_Rocker_DOWN
    }
    enum ami_commands : int
    {
        SettingKnob = 3000
    }
    enum ehsi_commands : int
    {
        ModeBtn = 3000
    , LeftKnob
    , LeftKnobBtn
    , RightKnob
    , RightKnobBtn
    }
    enum clock_commands : int
    {
        CLOCK_left_lev_up = 3000
    , CLOCK_left_lev_rotate
    , CLOCK_right_lev_down
    }
    enum alt_commands : int
    {
        PNEU = 3000
    , ELEC
    , ZERO
    }
    enum mids_commands : int
    {
        PwrSw = 3000
    , PwrSw_ITER
    }
    enum ins_commands : int
    {
        ModeKnob = 3000
    , ModeKnob_ITER
    }
}
