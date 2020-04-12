/********************* Creation of the shell type geometry *********************/

// Core of the transformer.
X_Rectangle = -(W_Leg + W_Hole) - (W_Centre/2);
W_Rectangle = (W_Leg + W_Hole)*2 + W_Centre;
Y_Rectangle = -(H_Leg + H_Hole*1.5 + H_Centre);
H_Rectangle = (H_Leg + H_Hole*1.5 + H_Centre)*2;
Call Create_Rectangle;

// Holes in the core.
X_Rectangle = X_Rectangle + W_Leg;
W_Rectangle = W_Hole;
Y_Rectangle = Y_Rectangle + H_Leg;
H_Rectangle = H_Hole;
For j In {1:2}
	For i In {1:3}
		Num_Surf = Num_Surf + 1;
		Call Create_Rectangle;
		Surf_Holes() += {Num_Surf};
		Y_Rectangle = Y_Rectangle + H_Hole + H_Centre;		
	EndFor
	X_Rectangle = X_Rectangle + W_Hole + W_Centre;
	Y_Rectangle = Y_Rectangle -3*(H_Hole + H_Centre);
EndFor

// Primary windings.
X_Rectangle = - (W_Centre/2 + W_Inductor1 + Air_Gap1);
W_Rectangle = W_Inductor1;
Y_Rectangle = -(H_Hole*1.5 + H_Centre) + (H_Hole - H_Inductor1)/2;
H_Rectangle = H_Inductor1;
For j In {1:2}
	For i In {1:3}
		Num_Surf = Num_Surf + 1;
		Call Create_Rectangle;
		Surf_Inductors() += {Num_Surf};
		Y_Rectangle = Y_Rectangle + H_Hole + H_Centre;		
	EndFor
	X_Rectangle = X_Rectangle + W_Inductor1 + W_Centre + 2*Air_Gap1;
	Y_Rectangle = Y_Rectangle -3*(H_Hole + H_Centre);
EndFor

// Secondary windings.
X_Rectangle = - (W_Centre/2 + W_Inductor1 + Air_Gap1 + W_Inductor2 + Air_Gap2);
W_Rectangle = W_Inductor2;
Y_Rectangle = -(H_Hole*1.5 + H_Centre) + (H_Hole - H_Inductor2)/2;
H_Rectangle = H_Inductor2;
For j In {1:2}
	For i In {1:3}
		Num_Surf = Num_Surf + 1;
		Call Create_Rectangle;
		Surf_Inductors() += {Num_Surf};
		Y_Rectangle = Y_Rectangle + H_Hole + H_Centre;		
	EndFor
	X_Rectangle = X_Rectangle + W_Centre + 2*W_Inductor1 + 2*Air_Gap1 + W_Inductor2 + 2*Air_Gap2;
	Y_Rectangle = Y_Rectangle -3*(H_Hole + H_Centre);
EndFor


// External domain circle.
X_Circle = 0;
Y_Circle = 0;
R_Circle = R_out;
Num_Surf = Num_Surf +1;
Call Create_Circle;

// Internal domain circle. 
X_Circle = 0;
Y_Circle = 0;
R_Circle = R_in;
Num_Surf = Num_Surf +1;
Call Create_Circle;

BooleanDifference{ Surface{1}; Delete; }{ Surface{Surf_Holes()}; Delete; }		 // CORE
BooleanDifference{ Surface{20}; Delete; }{ Surface{21}; }				 // AIR INF
s() = BooleanDifference{ Surface{21}; Delete; }{ Surface{1}; Surface{Surf_Inductors()}; };// AIR















