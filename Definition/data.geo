PathGeometry             = "Input/005Geometry/"             ;
PathGeometricParameters  = "Input/010Geometric parameters/" ;
PathMeshParameters       = "Input/012Mesh parameters/"      ;
PathMaterialsParameters  = "Input/020Materials parameters/" ;
PathElectricalParameters = "Input/015Electrical parameters/";
PathResultsUI            = "Output/"                        ;

cm   = 1e-2     ;
mili = 1e-3     ;
kilo = 1e3      ;
mega = 1e6      ;
mu0  = 4*Pi*1e-7;


DefineConstant[
	       Geo = { 0 , Name StrCat[PathGeometricParameters,"00Which Transfo type ?"], Highlight "Green", Visible 1,
    Choices{
      0 = "Core type",
      1 = "Shell type"
    } }];

DefineConstant[
	       type = { 0 , Name StrCat[PathElectricalParameters,"04type A or B?"], Highlight "Red", Visible 1,
    Choices{
      0 = " type A ",
      1 = " type B "
    } }];

DefineConstant[
	       Core_Air_Gap = { 0 , Name StrCat[PathGeometricParameters,"01Air gap in the core?"], Highlight "Green", Visible 1,
    Choices{
      0 = "No",
      1 = "Yes"
    } }];	
	
DefineConstant[
        test = { 0 , Name StrCat[PathElectricalParameters,"02Which are you willing to do?"], Highlight "Red", Visible 1,
    Choices{
      0 = "Short circuit",
      1 = "Open Circuit",
      2 = "Define your load"
    } }];

DefineConstant[
        Prim_connection = { 0 , Name StrCat[PathElectricalParameters,"03Which are you willing to do?"], Highlight "Red", Visible 1,
    Choices{
      0 = "Star",
      1 = "Delta"
    } }];

DefineConstant[
        Second_connection = { 0 , Name StrCat[PathElectricalParameters,"04Which are you willing to do?"], Highlight "Red", Visible 1,
    Choices{
      0 = "Star",
      1 = "Delta"
    } }];


If (type == 0) 
  Voltage_primary  = 2.4*kilo ;
  Voltage_secondary= 240      ;
  Nominal_S        = 200*kilo ;
Else
  Voltage_primary  = 60*kilo  ;
  Voltage_secondary= 2.4*kilo ;
  Nominal_S        = 20*kilo  ;
EndIf

transfo_ratio = Voltage_primary/Voltage_secondary;//transformation ratio

//Flag for laminated core (& insulation?) should be added as well 
//thickness core 2b defined ..

//Mesh parameters:
lc_Rectangle = DefineNumber[0.001      , Name StrCat[PathMeshParameters     ,"01Core & Windings   "],Highlight "LightBlue1"];
lc_Circle    = DefineNumber[0.01       , Name StrCat[PathMeshParameters     ,"02Airbox            "],Highlight "LightBlue1"];

//Geometric parameters:
W_Inductor1  = DefineNumber[0.0025     , Name StrCat[PathGeometricParameters ,"01Width Inductor 1  "      ], Highlight "Grey"];
W_Inductor2  = DefineNumber[0.0025     , Name StrCat[PathGeometricParameters ,"02Width Inductor 2  "      ], Highlight "Grey"];
H_Leg        = DefineNumber[0.01       , Name StrCat[PathGeometricParameters ,"04Height of the leg "      ], Highlight "Grey"];
W_Leg        = DefineNumber[0.01       , Name StrCat[PathGeometricParameters ,"05Width of the leg  "      ], Highlight "Grey"];
W_Hole       = DefineNumber[0.015      , Name StrCat[PathGeometricParameters ,"06Width of the hole "      ], Highlight "Grey"];
Air_Gap1     = DefineNumber[0.001      , Name StrCat[PathGeometricParameters ,"07Air Gap 1         "      ], Highlight "Grey"];
Air_Gap2     = DefineNumber[0.001      , Name StrCat[PathGeometricParameters ,"08Air Gap 2         "      ], Highlight "Grey"];
H_Hole       = DefineNumber[0.02       , Name StrCat[PathGeometricParameters ,"03Height of the hole"      ], Highlight "Grey"];
H_Inductor1  = DefineNumber[H_Hole*0.8 , Name StrCat[PathGeometricParameters ,"09Height Inductor 1 "      ], Highlight "Grey"];
H_Inductor2  = DefineNumber[H_Hole*0.8 , Name StrCat[PathGeometricParameters ,"11Height Inductor 2 "      ], Highlight "Grey"];
Primary_turns= DefineNumber[20         , Name StrCat[PathElectricalParameters,"06RNumber of primary turns"], Highlight "Red" ];
Load_resist  = DefineNumber[1*kilo     , Name StrCat[PathElectricalParameters,"05Resistance of the load"  ], Highlight "Red" , Visible test==2     ];
Air_Gap3     = DefineNumber[0.001      , Name StrCat[PathGeometricParameters ,"14Air gap in the core"     ], Highlight "Grey", Visible Core_Air_Gap];
W_Centre     = DefineNumber[0.02       , Name StrCat[PathGeometricParameters ,"12Width of the central part of the core "], Highlight "Grey", Visible Geo];
H_Centre     = DefineNumber[0.01       , Name StrCat[PathGeometricParameters ,"13Height of the central part of the core"], Highlight "Grey", Visible Geo];

Num_Surf = 1 ;

If (Geo == 1)	
	R_in  = Sqrt[((W_Leg + W_Hole) + (W_Centre/2))^2+((H_Leg + H_Hole*1.5 + H_Centre))^2]*1.5;
	R_out = Sqrt[((W_Leg + W_Hole) + (W_Centre/2))^2+((H_Leg + H_Hole*1.5 + H_Centre))^2]*3  ;
Else
	R_in  = Sqrt[((W_Leg + 1.5*W_Hole) + (W_Leg))^2+((H_Leg + H_Hole*0.5 ))^2]*1.5;
	R_out = Sqrt[((W_Leg + 1.5*W_Hole) + (W_Leg))^2+((H_Leg + H_Hole*0.5 ))^2]*3  ;
EndIf

//Physical Tags:
Skin_airInf     = 400 ; 
Air_ext         = 500 ;
AirInf          = 600 ;
Core            = 700 ;

Primary_ph1_p   = 900 ;
Primary_ph2_p   = 1000;
Primary_ph3_p   = 1100;

Primary_ph1_m   = 1200;
Primary_ph2_m   = 1300;
Primary_ph3_m   = 1400;

Secondary_ph1_p = 1500;
Secondary_ph2_p = 1600;
Secondary_ph3_p = 1700;

Secondary_ph1_m = 1800; 
Secondary_ph2_m = 1900;
Secondary_ph3_m = 2000;