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
giga = 1e9      ;
mu0  = 4*Pi*1e-7;

/************************************ Electrical definition ******************************************************/	
DefineConstant[
	type = { 1 , Name StrCat[PathElectricalParameters,"00type A or B?"], Highlight "Red", Visible 1,
		Choices{
			0 = " type A ",
			1 = " type B "
    } }];
	
DefineConstant[
    test = { 0 , Name StrCat[PathElectricalParameters,"01Load connected to the secondary"], Highlight "Red", Visible 1,
		Choices{
			0 = "Short circuit",
			1 = "Open Circuit",
			2 = "Define your load"
    } }];

DefineConstant[
    Prim_connection = { 0 , Name StrCat[PathElectricalParameters,"04Primary windings connection"], Highlight "Red", Visible 1,
		Choices{
			0 = "Star",
			1 = "Delta"
    } }];

DefineConstant[
    Second_connection = { 0 , Name StrCat[PathElectricalParameters,"05Secondary windings connection"], Highlight "Red", Visible 1,
		Choices{
			0 = "Star",
			1 = "Delta"
    } }];
	
DefineConstant[
  Flag_FrequencyDomain = {1 , Name StrCat[PathElectricalParameters,"07Frequency domain analysis?"], Highlight "Red", Visible 1,
    Choices{
      0 = "No ",
      1 = "Yes "
    } }];

/************************************ Geometry definition ******************************************************/    

DefineConstant[
	Geo = { 0 , Name StrCat[PathGeometricParameters,"00Which Transfo type ?"], Highlight "Green", Visible 1,
		Choices{
			0 = "Core type",
			1 = "Shell type"
    } }];

DefineConstant[
	Core_Air_Gap = { 0 , Name StrCat[PathGeometricParameters,"01Air gap in the core?"], Highlight "Green", Visible 1,
		Choices{
			0 = "No",
			1 = "Yes"
    } }];
	
DefineConstant[
	Laminated_Core = { 1 , Name StrCat[PathGeometricParameters,"02Is the core laminated?"], Highlight "Green", Visible 1,
		Choices{
			0 = "No",
			1 = "Yes"
    } }];
 	
/************************************ Electrical parameters ******************************************************/
//User's input
Primary_Turns  = DefineNumber[100  , Name StrCat[PathElectricalParameters, "09Number of primary turns" ], Highlight "Red" ];

// Definition of in the statement
If (type == 0) 
	Voltage_primary  = 2.4*kilo ;
	Voltage_secondary= 240      ;	
	Nominal_S        = 200*kilo ;
Else
	Voltage_primary  = 60*kilo  ;
	Voltage_secondary= 2.4*kilo ;
	Nominal_S        = 20*kilo  ;
EndIf
 
 /************************************ Geometrical parameters ******************************************************/
// User's input
H_Leg        = DefineNumber[0.1   , Name StrCat[PathGeometricParameters ,"05Height of the leg "                      ], Highlight "Grey"];
W_Leg        = DefineNumber[0.1   , Name StrCat[PathGeometricParameters ,"06Width of the leg  "                      ], Highlight "Grey"];
Air_Gap1     = DefineNumber[0.001  , Name StrCat[PathGeometricParameters ,"08Insulation gap betwen core and inductors"], Highlight "Grey"];
Air_Gap2     = DefineNumber[0.001  , Name StrCat[PathGeometricParameters ,"09Insulation gap between 2 inductors"      ], Highlight "Grey"];
H_Hole       = DefineNumber[0.5    , Name StrCat[PathGeometricParameters ,"10Height of the hole"                      ], Highlight "Grey"];
K_Ind1       = DefineNumber[0.8    , Name StrCat[PathGeometricParameters ,"11Inductor 1 height coefficient "          ], Highlight "Grey"];
K_Ind2       = DefineNumber[0.8    , Name StrCat[PathGeometricParameters ,"12Inductor 2 height coefficient "          ], Highlight "Grey"];
Air_Gap3     = DefineNumber[0.001  , Name StrCat[PathGeometricParameters ,"13Air gap in the core"                     ], Highlight "Grey", Visible Core_Air_Gap];
W_Centre     = DefineNumber[0.02   , Name StrCat[PathGeometricParameters ,"14Width of the central part of the core "  ], Highlight "Grey", Visible Geo];
H_Centre     = DefineNumber[0.01   , Name StrCat[PathGeometricParameters ,"15Height of the central part of the core"  ], Highlight "Grey", Visible Geo];
r_corner	 = DefineNumber[0.001  , Name StrCat[PathGeometricParameters ,"16Radius of the rounded hole corner"       ], Highlight "Grey"];

// Useful computation
H_Inductor1 = K_Ind1 * H_Hole;
H_Inductor2 = K_Ind2 * H_Hole;

// Counter initilization
Num_Surf = 1 ;

// Computation of the dimension of the inductors
If (type == 0) 
	N_Wire_per_Turn_Primary   = 1;		// Not useful here 1 turn is made up of 1 wire 
	N_Wire_per_Turn_Secondary = 1;		// Not useful here 1 turn is made up of 1 wire 
	A_Fil_primary   = 5.26 *mili*mili;	// "AWG10" cables: Sustain up to 35 [A] at 90° (Primary nominal current = 27.7 [A] --> Ok!)
	A_Fil_Secondary = 126.7*mili*mili;	// "250MCM" Cables Sustain up to 290 [A] at 90° (Secondary nominal current = 277.7 [A] --> Ok!)
Else
	N_Wire_per_Turn_Primary = 1;	    // Not useful here 1 turn is made up of 1 wire 
	N_Wire_per_Turn_Secondary = 5;	    // Here 1 turn of cable is made up of 5 wires in parallel
	A_Fil_primary = 42.4*mili*mili;	    // "AWG1" cables: Sustain up to 115 [A] at 90° (Primary nominal current = 111 [A] --> Ok!)
	A_Fil_Secondary = 456*mili*mili;    // "900MCM" cables : Sustain up to 2925 [A] at 90° (Secondary nominal current = 2777 [A] --> Ok!)	
EndIf

transfo_ratio   = Voltage_primary/Voltage_secondary;													//transformation ratio
Secondary_Turns = Primary_Turns/transfo_ratio      ;
W_Inductor1     = (Primary_Turns * N_Wire_per_Turn_Primary * A_Fil_primary)/(H_Inductor1);				// Width of the inductor based on the section of the cables, the number of cables and the height of the inductors input by the user.
W_Inductor2     = (Secondary_Turns * N_Wire_per_Turn_Secondary * A_Fil_Secondary)/(H_Inductor2);

// The width of the hole is automatically computed to let "Air_Gap1" between the core and the windings and "Air_Gap2" between two adjacent inductors.
If((Geo == 1))
	W_Hole = (W_Inductor1 + W_Inductor2 + Air_Gap1 + Air_Gap2 + Air_Gap1);
ElseIf((Geo == 0))
	W_Hole =  (2 * W_Inductor1 + 2 * W_Inductor2 + 2 * Air_Gap1 + 3  * Air_Gap2 );
EndIf

// Infinite shell transformation parameters
If (Geo == 1)	
	R_int  = Sqrt[((W_Leg + W_Hole) + (W_Centre/2))^2+((H_Leg + H_Hole*1.5 + H_Centre + (Air_Gap3*Core_Air_Gap)*1.5))^2]*1.5;		 
	R_ext = Sqrt[((W_Leg + W_Hole) + (W_Centre/2))^2+((H_Leg + H_Hole*1.5 + H_Centre + (Air_Gap3*Core_Air_Gap)*1.5))^2]*1.7;
Else
	R_int  = Sqrt[((W_Leg*1.5 + W_Hole))^2+((H_Leg + H_Hole*0.5 +(Air_Gap3*Core_Air_Gap)*0.5))^2]*1.5;								 
	R_ext = Sqrt[((W_Leg + 1.5*W_Hole) + (W_Leg))^2+((H_Leg + H_Hole*0.5 + (Air_Gap3*Core_Air_Gap)*0.5))^2]*1.7;
EndIf

/************************************ Mesh parameters ******************************************************/

lc_Holes_Param      = DefineNumber[10 , Name StrCat[PathMeshParameters, "01Internal corners of the core "], Highlight "LightBlue1"];
lc_Holes  			= (2*Pi*r_corner)/lc_Holes_Param;

lc_Air_Param        = DefineNumber[50  , Name StrCat[PathMeshParameters, "02Away from the transformer    "], Highlight "LightBlue1"];
lc_Air              = (2*Pi*R_int)/lc_Air_Param;

lc_Windings_Param	= DefineNumber[50 , Name StrCat[PathMeshParameters, "02Windings                     "], Highlight "LightBlue1"];
lc_Windings			= (H_Inductor2+W_Inductor2)/(2*lc_Windings_Param);

lc_Core_Corner_Param= DefineNumber[200 , Name StrCat[PathMeshParameters, "02External corners of the core "], Highlight "LightBlue1"];
lc_Core_Corner      = (2*W_Hole+3*W_Leg)/lc_Core_Corner_Param;

/************************************ Output files ******************************************************/
DefineConstant[
  OverWriteOutput = {0, Name StrCat[PathResultsUI,"01Overwrite output?"], Visible 1,
    Choices{
      0 = "No ",
      1 = "Yes "
    } }];

DefineConstant[
  Field_Card = { 0 , Name StrCat[PathResultsUI,"02Show field map?"], Highlight "Red", Visible 1,
    Choices{
      0 = "No ",
      1 = "Yes "
    } }];

/************************************ Physical Tags ******************************************************/

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




