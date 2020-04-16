
Macro Create_Rectangle
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

// This function creates a circle of radius R_Circle. The mesh size at the center and at 4 point on the periphery is fixed to lc_Circle.
Macro Create_Circle
	cp = newp ; 
	Point(cp)   = {X_Circle           , Y_Circle           , 0       , lc_Circle};
	Point(cp+1) = {X_Circle+(R_Circle), Y_Circle           , 0       , lc_Circle};
	Point(cp+2) = {X_Circle           , Y_Circle+(R_Circle), 0       , lc_Circle};
	Point(cp+3) = {X_Circle-(R_Circle), Y_Circle           , 0       , lc_Circle};
	Point(cp+4) = {X_Circle           , 0-(R_Circle)       , Y_Circle, lc_Circle};

	cl = newl;
	Circle(cl)   = {cp+1, cp, cp+2};
	Circle(cl+1) = {cp+2, cp, cp+3};
	Circle(cl+2) = {cp+3, cp, cp+4};
	Circle(cl+3) = {cp+4, cp, cp+1};

	cll = newll; 
	Curve Loop(cll) =  {cl, cl+1, cl+2, cl+3};
	Plane Surface(Num_Surf) = {cll};
Return