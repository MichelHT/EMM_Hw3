SetFactory("OpenCASCADE");

Include "data.geo"     ;

Include "functions.geo";

If (Geo == 1)
	Include "Shell_type_geometry.geo";
	//Physicals
	Physical Surface("AIR"    ,Air)                            = {s(0)}     ;	
	Physical Surface("AIR_WINDOW", Air_Window)                 = {s(1),s(2)}; 
	Physical Surface("AIR_INF",AirInf)                         = {20}       ;	
	Physical Surface("CORE"   ,Core)                           = {1}        ;	
	Physical Surface("Primary_Phase1_Plus"   ,Primary_ph1_p)   = {8}        ;	
	Physical Surface("Primary_Phase2_Plus"   ,Primary_ph2_p)   = {9}        ;	
	Physical Surface("Primary_Phase3_Plus"   ,Primary_ph3_p)   = {10}       ;	
	Physical Surface("Primary_Phase1_Minus"  ,Primary_ph1_m)   = {11}       ;	
	Physical Surface("Primary_Phase2_Minus"  ,Primary_ph2_m)   = {12}       ;	
	Physical Surface("Primary_Phase3_Minus"  ,Primary_ph3_m)   = {13}       ;	
	Physical Surface("Secondary_Phase1_Plus" ,Secondary_ph1_p) = {14}       ;	
	Physical Surface("Secondary_Phase2_Plus" ,Secondary_ph2_p) = {15}       ;	
	Physical Surface("Secondary_Phase3_Plus" ,Secondary_ph3_p) = {16}       ;	
	Physical Surface("Secondary_Phase1_Minus",Secondary_ph1_m) = {17}       ;	
	Physical Surface("Secondary_Phase2_Minus",Secondary_ph2_m) = {18}       ;	
	Physical Surface("Secondary_Phase3_Minus",Secondary_ph3_m) = {19}       ;	
	//Coloring:
	Color Orange{Surface{8:13} ;}
	Color Red   {Surface{14:19};}
	Color Grey50{Surface{s()}  ;}
	Color Green {Surface{1}    ;}
	Color Blue  {Surface{20}   ;}
Else 
	Include "Core_type_geometry.geo" ;
	//Physicals
	Physical Surface("AIR"    , Air   )                        = {s(0)}     ; 
	Physical Surface("AIR_WINDOW", Air_Window)                 = {s(1),s(2)}; 
	Physical Surface("AIR_INF", AirInf)                        = {16}       ; 
	Physical Surface("CORE"   , Core  )                        = {1}        ; 
	Physical Surface("Primary_Phase1_Plus"   ,Primary_ph1_p)   = {4}        ; 
	Physical Surface("Primary_Phase2_Plus"   ,Primary_ph2_p)   = {5}        ; 
	Physical Surface("Primary_Phase3_Plus"   ,Primary_ph3_p)   = {6}        ; 
	Physical Surface("Primary_Phase1_Minus"  ,Primary_ph1_m)   = {7}        ; 
	Physical Surface("Primary_Phase2_Minus"  ,Primary_ph2_m)   = {8}        ; 
	Physical Surface("Primary_Phase3_Minus"  ,Primary_ph3_m)   = {9}        ; 
	Physical Surface("Secondary_Phase1_Plus" ,Secondary_ph1_p) = {10}       ; 
	Physical Surface("Secondary_Phase2_Plus" ,Secondary_ph2_p) = {11}       ; 
	Physical Surface("Secondary_Phase3_Plus" ,Secondary_ph3_p) = {12}       ; 
	Physical Surface("Secondary_Phase1_Minus",Secondary_ph1_m) = {13}       ; 
	Physical Surface("Secondary_Phase2_Minus",Secondary_ph2_m) = {14}       ; 
	Physical Surface("Secondary_Phase3_Minus",Secondary_ph3_m) = {15}       ; 
	//Coloring:
	Color Orange{Surface{4:9}  ;}
	Color Red   {Surface{10:15};}
	Color Grey50{Surface{s()}  ;}
	Color Green {Surface{1}    ;}
	Color Blue  {Surface{16}   ;}
EndIf
