/********************* Creation of the core type geometry *********************/

// Core of the transformer.
X_Rectangle = -(W_Leg + W_Hole + W_Leg*0.5);
W_Rectangle = (W_Leg + W_Hole + W_Leg*0.5)*2;
Y_Rectangle = -(H_Leg + H_Hole*0.5);
H_Rectangle = (H_Leg + H_Hole*0.5)*2;
lc_Rectangle = lc_Core_Corner;
Call Create_Rectangle;

// Holes in the core.
X_Rectangle = X_Rectangle + W_Leg;
W_Rectangle = W_Hole;
Y_Rectangle = Y_Rectangle + H_Leg;
H_Rectangle = H_Hole;
lc_Rectangle = lc_Holes;
For i In {1:2}
	Num_Surf = Num_Surf + 1;
	Call Create_Round_Rectangle;
	Surf_Holes() += {Num_Surf};
	X_Rectangle = X_Rectangle + W_Hole + W_Leg;	
EndFor

// Primary windings.
X_Rectangle = - (W_Hole + W_Leg*1.5 + W_Inductor1 + Air_Gap1);
W_Rectangle = W_Inductor1;
Y_Rectangle = -(H_Hole*0.5) + (H_Hole - H_Inductor1)/2;
H_Rectangle = H_Inductor1;
lc_Rectangle = lc_Windings;
For j In {1:2}
	For i In {1:3}
		Num_Surf = Num_Surf + 1;
		Call Create_Rectangle;
		Surf_Inductors() += {Num_Surf};
		X_Rectangle = X_Rectangle + W_Leg + W_Hole;		
	EndFor
	X_Rectangle = X_Rectangle - 3*(W_Leg + W_Hole) + W_Inductor1 + W_Leg + 2*Air_Gap1;
EndFor

// Secondary windings.
X_Rectangle = - (W_Hole + W_Leg*1.5 + W_Inductor1 + Air_Gap1 + W_Inductor2 + Air_Gap2);
W_Rectangle = W_Inductor2;
Y_Rectangle = -(H_Hole*0.5) + (H_Hole - H_Inductor1)/2;
H_Rectangle = H_Inductor2;
For j In {1:2}
	For i In {1:3}
		Num_Surf = Num_Surf + 1;
		Call Create_Rectangle;
		Surf_Inductors() += {Num_Surf};
		X_Rectangle = X_Rectangle + W_Leg + W_Hole;			
	EndFor
	X_Rectangle = X_Rectangle - 3*(W_Leg + W_Hole) + W_Leg + 2*W_Inductor1 + 2*Air_Gap1 + W_Inductor2 + 2*Air_Gap2;
EndFor

// External domain circle.
X_Circle = 0;
Y_Circle = 0;
R_Circle = R_ext;
Num_Surf = Num_Surf +1;
lc_Circle = lc_Air;
Call Create_Circle;

// Internal domain circle. 
X_Circle = 0;
Y_Circle = 0;
R_Circle = R_int;
Num_Surf = Num_Surf +1;
Call Create_Circle;

// Possible Air gap in the core.
If(Core_Air_Gap == 0)	
	Surf_Core() = BooleanDifference{ Surface{1}; Delete; }{ Surface{Surf_Holes()}; Delete;}; // CORE
Else
	X_Rectangle = -(W_Leg + W_Hole + W_Leg*0.5);
	W_Rectangle = (W_Leg + W_Hole + W_Leg*0.5)*2;
	Y_Rectangle =  H_Hole*0.5;
	H_Rectangle = H_Leg;
	Num_Surf = Num_Surf +1;
	Call Create_Rectangle;	
	Surf_Core() = BooleanDifference{ Surface{1}; Delete; }{ Surface{Surf_Holes()}; Surface{Num_Surf}; Delete;};  // Creation of a E-shape core for the three phases.
	
	X_Rectangle = -(W_Leg + W_Hole + W_Leg*0.5);
	W_Rectangle = (W_Leg + W_Hole + W_Leg*0.5)*2;
	Y_Rectangle =  H_Hole*0.5 + Air_Gap3;
	H_Rectangle = H_Leg;
	Num_Surf = Num_Surf +1;
	Call Create_Rectangle;																						 // Creation of a I-shape core which closes the magnetic circuit.
	Surf_Core() += Num_Surf;							
	
	Translate {0, Air_Gap3*0.5, 0} { Surface{16}; Surface{17}; } 												 // Centering of the domain.
EndIf
BooleanDifference{ Surface{16}; Delete; }{ Surface{17}; }				  										 // AIR INF
s() = BooleanDifference{ Surface{17}; Delete; }{ Surface{Surf_Core()}; Surface{Surf_Inductors()}; };		 	 // AIR














