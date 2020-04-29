/********************* Creation of the core type geometry *********************/

// Core of the transformer.
X_Rectangle = -(W_Leg + W_Hole + W_Centre*0.5) ;
W_Rectangle = (W_Leg + W_Hole + W_Centre*0.5)*2;
Y_Rectangle = -(H_Leg + H_Hole*0.5);
H_Rectangle = (H_Leg + H_Hole*0.5)*2;
lc_Rectangle = lc_Core_Corner;
Call Create_Rectangle;

// Holes in the core.
X_Rectangle = -(W_Hole + W_Centre*0.5);
W_Rectangle = W_Hole;
Y_Rectangle = Y_Rectangle + H_Leg;
H_Rectangle = H_Hole;
lc_Rectangle = lc_Holes;
For i In {1:2}
	Num_Surf = Num_Surf + 1;
	Call Create_Round_Rectangle;
	Surf_Holes() += {Num_Surf};
	X_Rectangle = X_Rectangle + W_Hole + W_Centre;	
EndFor

// Primary windings.
X_Rectangle = - (W_Hole + W_Centre*1.5 + W_Inductor1 + Air_Gap1);
W_Rectangle = W_Inductor1;
Y_Rectangle = -(H_Hole*0.5) + (H_Hole - H_Inductor1)/2;
H_Rectangle = H_Inductor1;
lc_Rectangle = lc_Windings;
For j In {1:2}
	For i In {1:3}
		Num_Surf = Num_Surf + 1;
		Call Create_Rectangle;
		Surf_Inductors() += {Num_Surf};
		X_Rectangle = X_Rectangle + W_Centre + W_Hole;		
	EndFor
	X_Rectangle = X_Rectangle - 3*(W_Centre + W_Hole) + W_Inductor1 + W_Centre + 2*Air_Gap1;
EndFor

// Secondary windings.
X_Rectangle = - (W_Hole + W_Centre*1.5 + W_Inductor1 + Air_Gap1 + W_Inductor2 + Air_Gap2);
W_Rectangle = W_Inductor2;
Y_Rectangle = -(H_Hole*0.5) + (H_Hole - H_Inductor1)/2;
H_Rectangle = H_Inductor2;
For j In {1:2}
	For i In {1:3}
		Num_Surf = Num_Surf + 1;
		Call Create_Rectangle;
		Surf_Inductors() += {Num_Surf};
		X_Rectangle = X_Rectangle + W_Centre + W_Hole;			
	EndFor
	X_Rectangle = X_Rectangle - 3*(W_Centre + W_Hole) + W_Centre + 2*W_Inductor1 + 2*Air_Gap1 + W_Inductor2 + 2*Air_Gap2;
EndFor

// Replace the external inductors at the right place (they have been misplaced because W_Centre != W_Leg)
Translate {(W_Centre - W_Leg), 0 , 0} { Surface{Surf_Inductors(0)}; Surface{Surf_Inductors(6)}; } 
Translate {-(W_Centre - W_Leg), 0 , 0} { Surface{Surf_Inductors(5)}; Surface{Surf_Inductors(11)}; } 


// External domain circle.
X_Circle = 0;
Y_Circle = 0;
R_Circle = R_ext;
Num_Surf = Num_Surf +1;
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
	X_Rectangle = -(W_Centre + W_Hole + W_Centre*0.5);
	W_Rectangle = (W_Centre + W_Hole + W_Centre*0.5)*2;
	Y_Rectangle =  H_Hole*0.5;
	H_Rectangle = H_Leg;
	Num_Surf = Num_Surf +1;
	lc_Rectangle = lc_Core_Corner;
	Call Create_Rectangle;

	X_Rectangle = -(W_Hole + W_Centre*0.5);		// Remove the rounded corners
	W_Rectangle = W_Hole;
	Y_Rectangle =  H_Hole*0.5 - r_corner;
	H_Rectangle = r_corner;
	Num_Surf = Num_Surf +1;
	lc_Rectangle = lc_Core_Corner;
	Call Create_Rectangle;	
	X_Rectangle = (W_Centre*0.5);
	W_Rectangle = W_Hole;
	Y_Rectangle =  H_Hole*0.5 - r_corner;
	H_Rectangle = r_corner;
	Num_Surf = Num_Surf +1;
	lc_Rectangle = lc_Core_Corner;
	Call Create_Rectangle;
	
	Surf_Core() = BooleanDifference{ Surface{1}; Delete; }{ Surface{Surf_Holes()}; Surface{Num_Surf-2}; Surface{Num_Surf-1}; Surface{Num_Surf}; Delete;};  // Creation of a E-shape core for the three phases.
	
	X_Rectangle = -(W_Leg + W_Hole + W_Centre*0.5) ;
	W_Rectangle = (W_Leg + W_Hole + W_Centre*0.5)*2;
	Y_Rectangle =  H_Hole*0.5 + Air_Gap3;
	H_Rectangle = H_Leg;
	Num_Surf = Num_Surf +1;
	lc_Rectangle = lc_Core_Corner;
	Call Create_Rectangle;																						 // Creation of a I-shape core which closes the magnetic circuit.
	Surf_Core() += {Num_Surf};							
	
	Translate {0, Air_Gap3*0.5, 0} { Surface{16}; Surface{17}; } 												 // Centering of the domain.
EndIf

cl = newl;
// Skin of the air
SA() += {cl - 4 - !Core_Air_Gap*(4)};
SA() += {cl - 3 - !Core_Air_Gap*(4)};
SA() += {cl - 2 - !Core_Air_Gap*(4)};
SA() += {cl - 1 - !Core_Air_Gap*(4)};
// Skin of air inf
SAI() += {cl};
SAI() += {cl+1};
SAI() += {cl+2};
SAI() += {cl+3};

cp = newp;
// Points of air inf
PAI() += {cp};
PAI() += {cp+1};
PAI() += {cp+2};
PAI() += {cp+3};
jj()=BooleanDifference{ Surface{16}; Delete; }{ Surface{17}; };				  										 // AIR INF
s() = BooleanDifference{ Surface{17}; Delete; }{ Surface{Surf_Core()}; Surface{Surf_Inductors()}; };		 	 	// AIR

If (Add_shield==1)
	Delete{Surface{jj()} ;}
	Delete{Line{SAI()} ;}
	Delete{Point{PAI()};}
EndIf













