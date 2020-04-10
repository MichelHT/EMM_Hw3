SetFactory("OpenCASCADE");

/********************* Useful functions *********************/

// This function creates a rectangle of width W_Rectangle and height H_Rectangle. The mesh size at the corners of the rectangle is fixed to lc_Rectangle.
Function "Create_Rectangle"
	cp = newp ;
	Point(cp)       = {X_Rectangle, Y_Rectangle, 0, lc_Rectangle};
	Point(cp+1)     = {X_Rectangle + W_Rectangle, Y_Rectangle, 0, lc_Rectangle};
	Point(cp+2)     = {X_Rectangle + W_Rectangle, Y_Rectangle + (H_Rectangle), 0, lc_Rectangle};
	Point(cp+3)     = {X_Rectangle, Y_Rectangle + (H_Rectangle), 0, lc_Rectangle};

	cl = newl;
	Line(cl)    = {cp, cp+1};
	Line(cl+1)  = {cp+1, cp+2};
	Line(cl+2)  = {cp+2, cp+3};
	Line(cl+3)  = {cp+3, cp};

	cll = newll; 
	Curve Loop(cll) = {cl, cl+1, cl+2, cl+3};

	Plane Surface(Num_Surf) = {cll};
Return

// This function creates a circle of radius R_Cercle. The mesh size at the center and at 4 point on the periphery is fixed to lc_Cercle.
Function "Create_Circle"
	cp = newp ; 
	Point(cp)     = {X_Cercle, Y_Cercle, 0, lc_Cercle};
	Point(cp+1)   = {X_Cercle+(R_Cercle), Y_Cercle, 0, lc_Cercle};
	Point(cp+2)   = {X_Cercle, Y_Cercle+(R_Cercle), 0, lc_Cercle};
	Point(cp+3)   = {X_Cercle-(R_Cercle), Y_Cercle, 0, lc_Cercle};
	Point(cp+4)   = {X_Cercle, 0-(R_Cercle), Y_Cercle, lc_Cercle};

	cl = newl;
	Circle(cl)   = {cp+1, cp, cp+2};
	Circle(cl+1) = {cp+2, cp, cp+3};
	Circle(cl+2) = {cp+3, cp, cp+4};
	Circle(cl+3) = {cp+4, cp, cp+1};

	cll = newll; 
	Curve Loop(cll) =  {cl, cl+1, cl+2, cl+3};
	Plane Surface(Num_Surf) = {cll};
Return

/********************* Geometrical constant*********************/
W_Leg = 0.01;
W_Hole = 0.015;
W_Inductor1 = 0.0025;
Air_Gap1 = 0.001;
W_Inductor2 = 0.0025;
Air_Gap2 = 0.001;
H_Leg = 0.01;
H_Hole = 0.02;
H_Inductor1 = H_Hole*0.8;
H_Inductor2 = H_Hole*0.8;

R_in = Sqrt(((W_Leg + 1.5*W_Hole) + (W_Leg))^2+((H_Leg + H_Hole*0.5 ))^2)*1.5;
R_out = Sqrt(((W_Leg + 1.5*W_Hole) + (W_Leg))^2+((H_Leg + H_Hole*0.5 ))^2)*3;

/********************* Creation of the geometry *********************/

// Core of the transformer.
X_Rectangle = -(W_Leg + W_Hole + W_Leg*0.5);
W_Rectangle = (W_Leg + W_Hole + W_Leg*0.5)*2;
Y_Rectangle = -(H_Leg + H_Hole*0.5);
H_Rectangle = (H_Leg + H_Hole*0.5)*2;
lc_Rectangle = 0.001;
Num_Surf = 1;
Call "Create_Rectangle";

// Holes in the core.
X_Rectangle = X_Rectangle + W_Leg;
W_Rectangle = W_Hole;
Y_Rectangle = Y_Rectangle + H_Leg;
H_Rectangle = H_Hole;
lc_Rectangle = 0.001;
For i In {1:2}
	Num_Surf = Num_Surf + 1;
	Call "Create_Rectangle";
	Surf_Holes() += {Num_Surf};
	X_Rectangle = X_Rectangle + W_Hole + W_Leg;	
EndFor

// Primary windings.
X_Rectangle = - (W_Hole + W_Leg*1.5 + W_Inductor1 + Air_Gap1);
W_Rectangle = W_Inductor1;
Y_Rectangle = -(H_Hole*0.5) + (H_Hole - H_Inductor1)/2;
H_Rectangle = H_Inductor1;
lc_Rectangle = 0.001;
For j In {1:2}
	For i In {1:3}
		Num_Surf = Num_Surf + 1;
		Call "Create_Rectangle";
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
lc_Rectangle = 0.001;
For j In {1:2}
	For i In {1:3}
		Num_Surf = Num_Surf + 1;
		Call "Create_Rectangle";
		Surf_Inductors() += {Num_Surf};
		X_Rectangle = X_Rectangle + W_Leg + W_Hole;			
	EndFor
	X_Rectangle = X_Rectangle - 3*(W_Leg + W_Hole) + W_Leg + 2*W_Inductor1 + 2*Air_Gap1 + W_Inductor2 + 2*Air_Gap2;
EndFor


// External domain circle.
lc_Cercle = 0.001;
X_Cercle = 0;
Y_Cercle = 0;
R_Cercle = R_out;
Num_Surf = Num_Surf +1;
Call "Create_Circle";

// Internal domain circle. 
lc_Cercle = 0.001;
X_Cercle = 0;
Y_Cercle = 0;
R_Cercle = R_in;
Num_Surf = Num_Surf +1;
Call "Create_Circle";



BooleanDifference{ Surface{1}; Delete; }{ Surface{Surf_Holes()}; Delete; }				// CORE
BooleanDifference{ Surface{16}; Delete; }{ Surface{17}; }								// AIR INF
BooleanDifference{ Surface{17}; Delete; }{ Surface{1}; Surface{Surf_Inductors()}; }		// AIR

/********************* Definition of the physical curves and surfaces *********************/
Physical Surface("AIR") = {17};								// Region 1
Physical Surface("AIR_INF") = {16};							// Region 2
Physical Surface("CORE") = {1};								// Region 3
Physical Surface("Primary_Phase1_Plus") = {4};				// Region 4
Physical Surface("Primary_Phase2_Plus") = {5};				// Region 5
Physical Surface("Primary_Phase3_Plus") = {6};				// Region 6
Physical Surface("Primary_Phase1_Minus") = {7};			// Region 7
Physical Surface("Primary_Phase2_Minus") = {8};			// Region 8
Physical Surface("Primary_Phase3_Minus") = {9};			// Region 9
Physical Surface("Secondary_Phase1_Plus") = {10};			// Region 10
Physical Surface("Secondary_Phase2_Plus") = {11};			// Region 11
Physical Surface("Secondary_Phase3_Plus") = {12};			// Region 12
Physical Surface("Secondary_Phase1_Minus") = {13};			// Region 13
Physical Surface("Secondary_Phase2_Minus") = {14};			// Region 14
Physical Surface("Secondary_Phase3_Minus") = {15};			// Region 15













