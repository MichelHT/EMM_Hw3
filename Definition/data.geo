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
	Add_shield = { 0 , Name StrCat[PathGeometricParameters,"02Is shield_tank surrounding the transformer?"], Highlight "Green", Visible 1,
		Choices{
			0 = "No",
			1 = "Yes"
   } }];

/************************************ Electrical definition ******************************************************/	
DefineConstant[
	type = { 1 , Name StrCat[PathElectricalParameters,"00type A or B?"], Highlight "Red", Visible 1,
		Choices{
			0 = " type A ",
			1 = " type B "
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
	

DefineConstant[
	Phase2_Connection = { 0 , Name StrCat[PathElectricalParameters,"08Way of connecting the second inductor"], Highlight "Red", Visible (Geo==1),
		Choices{
			0 = "Default direction",
			1 = "Reverse directon"
    } }];
 	
/************************************ Electrical parameters ******************************************************/
//User's input
Primary_Turns  = DefineNumber[100  , Name StrCat[PathElectricalParameters, "09Number of primary turns" ], Highlight "Red" ];

// Definition of in the statement
If (type == 0) 
	Voltage_primary  = (2.4*kilo)/Sqrt[3] ;
	Voltage_secondary= (240)/Sqrt[3]       ;	
	Nominal_S        = 200*kilo ;
Else
	Voltage_primary  = (60*kilo)/Sqrt[3]   ;
	Voltage_secondary= (2.4*kilo)/Sqrt[3]  ;
	Nominal_S        = 20*kilo  ;
EndIf
 
 /************************************ Geometrical parameters ******************************************************/
// User's input
W_Ref        = DefineNumber[0.4   , Name StrCat[PathGeometricParameters ,"06Reference width of the core "                      ], Highlight "Grey"];	// We use this reference with in the Boucherot formulation, the width of all the part of the core are relative to W_ref
Air_Gap1     = DefineNumber[0.002  , Name StrCat[PathGeometricParameters ,"08Insulation gap betwen core and inductors"], Highlight "Grey"];
Air_Gap2     = DefineNumber[0.002  , Name StrCat[PathGeometricParameters ,"09Insulation gap between 2 inductors"      ], Highlight "Grey"];
H_Hole       = DefineNumber[0.5    , Name StrCat[PathGeometricParameters ,"10Height of the hole"                      ], Highlight "Grey"];
K_Ind1       = DefineNumber[0.6    , Name StrCat[PathGeometricParameters ,"11Inductor 1 height coefficient "          ], Highlight "Grey"];
K_Ind2       = DefineNumber[0.6    , Name StrCat[PathGeometricParameters ,"12Inductor 2 height coefficient "          ], Highlight "Grey"];
Air_Gap3     = DefineNumber[0.001  , Name StrCat[PathGeometricParameters ,"13Air gap in the core"                     ], Highlight "Grey", Visible Core_Air_Gap];
r_corner	 = DefineNumber[0.025  , Name StrCat[PathGeometricParameters ,"16Radius of the rounded hole corner"       ], Highlight "Grey"];
Domain_Coef_Int	 = DefineNumber[1.5  , Name StrCat[PathGeometricParameters ,"17(Internal circle radius) over (Largest core dimension)"       ], Highlight "Grey"];
Domain_Coef_Ext	 = DefineNumber[1.7  , Name StrCat[PathGeometricParameters ,"18(External circle radius) over (Largest core dimension)"       ], Highlight "Grey"];

// Useful computation
H_Inductor1 = K_Ind1 * H_Hole;
H_Inductor2 = K_Ind2 * H_Hole;

If((Geo == 1))	// The computation of the width of a particular part of the core, is based on a rough estimation of the magnetic flux circulating in that part
	H_Leg = 0.5 * W_Ref;
	W_Leg = 0.5 * W_Ref;
	H_Centre = 0.5 * W_Ref;
	W_Centre = W_Ref;
ElseIf((Geo == 0))
	H_Leg = ((Sqrt[7]/2)) * W_Ref;
	W_Leg = ((Sqrt[7]/2)) * W_Ref;
	W_Centre = (2) * W_Ref;
EndIf

// Counter initilization
Num_Surf = 1 ;

// Computation of the dimension of the inductors
If (type == 0) 
	N_Wire_per_Turn_Primary   = 1;		// Not useful here 1 turn is made up of 1 wire 
	N_Wire_per_Turn_Secondary = 1;		// Not useful here 1 turn is made up of 1 wire 
	A_Fil_primary   = 13.3 *mili*mili;	// "AWG6" cables: Sustain up to 55 [A] at 90° (Primary nominal current = 47.98 [A] --> Ok!)
	A_Fil_Secondary = 354.7*mili*mili;	// "700MCM" Cables Sustain up to 520 [A] at 90° (Secondary nominal current = 479.8 [A] --> Ok!)
Else
	N_Wire_per_Turn_Primary = 1;	    // Not useful here 1 turn is made up of 1 wire 
	N_Wire_per_Turn_Secondary = 7;	    // Here 1 turn of cable is made up of 7 wires in parallel
	A_Fil_primary = 107*mili*mili;	    // "AWG0000" cables: Sustain up to 205 [A] at 90° (Primary nominal current = 192.3 [A] --> Ok!)
	A_Fil_Secondary = 886.7*mili*mili;    // 7 "1750MCM" cables : Sustain up to 5145 [A] at 90° (Secondary nominal current = 4809 [A] --> Ok!)	
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
	R_int  = Sqrt[((W_Leg + W_Hole) + (W_Centre/2))^2+((H_Leg + H_Hole*1.5 + H_Centre + (Air_Gap3*Core_Air_Gap)*1.5))^2]*Domain_Coef_Int;		 
	R_ext = Sqrt[((W_Leg + W_Hole) + (W_Centre/2))^2+((H_Leg + H_Hole*1.5 + H_Centre + (Air_Gap3*Core_Air_Gap)*1.5))^2]*Domain_Coef_Ext;
Else
	R_int  = Sqrt[((W_Leg + W_Centre*0.5 + W_Hole))^2+((H_Leg + H_Hole*0.5 +(Air_Gap3*Core_Air_Gap)*0.5))^2]*Domain_Coef_Int;								 
	R_ext = Sqrt[((W_Leg + W_Centre*0.5 + W_Hole))^2+((H_Leg + H_Hole*0.5 + (Air_Gap3*Core_Air_Gap)*0.5))^2]*Domain_Coef_Ext;
EndIf

/************************************ Mesh parameters ******************************************************/

lc_Holes_Param      = DefineNumber[15 , Name StrCat[PathMeshParameters, "01Internal corners of the core "], Highlight "LightBlue1"];
lc_Holes  			= (2*Pi*r_corner)/lc_Holes_Param;

lc_Air_Param        = DefineNumber[50  , Name StrCat[PathMeshParameters, "02Away from the transformer    "], Highlight "LightBlue1"];
lc_Air              = (2*Pi*R_int)/lc_Air_Param;
lc_Circle           = lc_Air; 

lc_Windings_Param	= DefineNumber[2 , Name StrCat[PathMeshParameters, "02Windings                     "], Highlight "LightBlue1"];
lc_Windings			= (Air_Gap1)/(lc_Windings_Param);

lc_Core_Corner_Param= DefineNumber[100 , Name StrCat[PathMeshParameters, "02External corners of the core "], Highlight "LightBlue1"];
If (Geo == 1)	
	lc_Core_Corner      = 2*(2*W_Hole + 2*W_Leg + W_Centre + 3*H_Hole + 2*H_Leg + 2*H_Centre)/lc_Core_Corner_Param;
Else
	lc_Core_Corner      = 2*(2*W_Hole + 2*W_Leg + W_Centre + H_Hole + 2*H_Leg)/lc_Core_Corner_Param;
EndIf



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
Skin_air        = 500 ;
Air_ext         = 600 ;
AirInf          = 700 ;
Core            = 800 ;


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




