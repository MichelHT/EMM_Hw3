Include "data.geo";

mur_Core = DefineNumber[1000, Name StrCat[PathMaterialsParameters , "Relative permeability of the core"], Highlight "Yellow"];
Freq     = DefineNumber[50  , Name StrCat[PathElectricalParameters, "Operating frequency              "], Highlight "Red"];

Group {

	// Physical regions
	Air         = Region[{Air_ext}]        ;
	Air_Inf	  = Region[{AirInf}]         ;
	Sur_Air_Ext = Region[{Skin_airInf}]    ; // exterior boundary
	Core        = Region[{Core}]           ; // magnetic core of the transformer, assumed non-conducting

	For i In {1:3}
		a = Primary_ph1_p + (i - 1) * 100    ; 
		b = Primary_ph1_p + (i - 1 + 3) * 100;
		c = Primary_ph1_p + (i - 1 + 6) * 100;
		d = Primary_ph1_p + (i - 1 + 9) * 100;

		Primary_p_phase~{i}   = Region[{a}];
		Primary_m_phase~{i}   = Region[{b}];
		Secondary_p_phase~{i} = Region[{c}];
		Secondary_m_phase~{i} = Region[{d}];

		Primary_coils        += Region[{Primary_p_phase~{i}  ,Primary_m_phase~{i}}  ];
		Secondary_coils      += Region[{Secondary_p_phase~{i},Secondary_m_phase~{i}}];
  	
		Coils  += Region[{Primary_p_phase~{i},Primary_m_phase~{i},Secondary_p_phase~{i},Secondary_m_phase~{i}}]; 
	EndFor 

	// Abstract regions 
	Vol_Mag   = Region[{Air, Core, Coils, Air_Inf}]; // full magnetic domain (surfaces)
	Vol_S_Mag = Region[{Coils}]           ; // Stranded conductors only. 
	Vol_Inf_Mag = Region[{Air_Inf}]         ; //We are applying the infinite shell transformation for accuracy
	Val_Rint = R_int ;  Val_Rext = R_ext    ; // Interior and exterior radii of ring
	If(Laminated_Core == 0)
		Vol_C_Mag = Region[{Core}];
	EndIf
}

Function{
	//Permeability
	mu[Air]    = 1 * mu0       	;
	mu[Air_Inf]    = 1 * mu0      ;
	mu[Coils]  = 1 * mu0       	;
	mu[Core]   = mur_Core * mu0	;
	nu[]       = 1 / mu[]      	;

	//Conductivity
	sigma[Coils]  = 1e7       	;
	sigma[Core]  = 1e7       	;
   
	//Signs:
	For i In {1:3}
		SignBranch[Primary_p_phase~{i}]   =  1;
		SignBranch[Secondary_p_phase~{i}] =  1;
		SignBranch[Primary_m_phase~{i}]   = -1;
		SignBranch[Secondary_m_phase~{i}] = -1;
	EndFor

	Ns[Primary_coils]   = Primary_turns              ;
	Ns[Secondary_coils] = Primary_turns/transfo_ratio;


	//Defining the current density: 
	For i In {1:3}
		Sc[Primary_p_phase~{i}]   = SurfaceArea[];
		Sc[Primary_m_phase~{i}]   = SurfaceArea[];
		Sc[Secondary_p_phase~{i}] = SurfaceArea[];
		Sc[Secondary_m_phase~{i}] = SurfaceArea[];
	EndFor

	js0[Coils] = Ns[] / Sc[] * Vector[0, 0, SignBranch[]];

	thickness_Core = 1;

	//2b added to the definition of the voltage:
	CoefGeos[Coils] = SignBranch[] * thickness_Core; 
	CoefGeos[Core] = thickness_Core;
}

Flag_CircuitCoupling = 1;

Group {
	Resistance_Cir  = Region[{}]; // resistances
	Inductance_Cir  = Region[{}]; // inductances
	Capacitance_Cir = Region[{}]; // capacitances
	SourceV_Cir     = Region[{}]; // voltage sources
	SourceI_Cir     = Region[{}]; // current sources

	For i In {1:3}		
		// Primary voltages
		xx = 10001 + (i-1) * 100  ;
		yy = 10001 + i * 5  * 100 ;
		zz = 10001 + i * 100 * 100;

		Voltage_pr~{i}  = Region[{xx}]            ;  //Primary voltage source
		SourceV_Cir    += Region[{Voltage_pr~{i}}];

		// Input resistances
		R_in~{i}        = Region[{yy}]      ; // Resistance in series with the voltage source
		Resistance_Cir += Region[{R_in~{i}}];

		// Output resistances
		If((test == 0) || (test == 1) || ((test == 2) && (Phase != 90) && (Phase != -90)))
			R_out~{i}       = Region[{zz}]       ; 		// The load resistance
			Resistance_Cir += Region[{R_out~{i}}];
		EndIf
		If(test == 2)
			If (Phase>0)
				zz = zz + 1;
				L_out~{i}   = Region[{zz}]           ; 		// The load inductance
				Inductance_Cir += Region[{L_out~{i}}];
			ElseIf (Phase<0)
				zz = zz + 2;
				C_out~{i}   = Region[{zz}]       ;		// The load capacitance
				Capacitance_Cir += Region[{C_out~{i}}];
			EndIf	
		EndIf
	EndFor
}

Function { 
	deg = Pi/180  ;
	Omega = 2*Pi*Freq;

	For i In {1:3}
		// Input Voltages:
		V_pr~{i}    = Voltage_primary  ;
		phase_V~{i} = 120 * (i-1) * deg;

		// Input resistances
		Resistance[R_in~{i}] = 1e-3 ; 

		// Load resistances
		If (test == 0)
			//Short circuit
			Resistance[R_out~{i}] = 750*mili   ; 
		ElseIf (test == 1)
			//Open circuit  
			Resistance[R_out~{i}] = 1e7        ; 
		Else 
		// User defined load
		If(Phase == 0)
			// Purely resistive load
			Resistance[R_out~{i}] = 10^Load_exponent; 
		ElseIf(Phase == 90)
			// Purely inductive load
			Inductance[L_out~{i}] = (10^Load_exponent)/(Omega);
		ElseIf(Phase == -90)
			// Purely capacitive load
			Capacitance[C_out~{i}] = 1/((10^Load_exponent)*(Omega));
		ElseIf(Phase > 0)
			// R-L load
			K = Tan[Phase*deg];
			Resistance[R_out~{i}] = (10^Load_exponent)/(Sqrt[1+(K*K)]);
			Inductance[L_out~{i}] =  (K*(10^Load_exponent))/(Omega*Sqrt[1+(K*K)]);
		ElseIf(Phase < 0)
			// R-C Load
			K = Tan[-Phase*deg];
			Resistance[R_out~{i}] = (10^Load_exponent)*Sqrt[1+(K*K)];
			Capacitance[C_out~{i}] = (K)/(Omega*(10^Load_exponent)*Sqrt[1+(K*K)]);
		EndIf
    EndIf
  EndFor
}

Constraint {
  { Name MagneticVectorPotential_2D;
    Case {
      { Region Sur_Air_Ext; Value 0; }
    }
  }
  { Name Current_2D;
    Case {
    }
  }
  { Name Voltage_2D;
    Case {
		If(Laminated_Core == 0)
			{ Region Core; Value 0; }
		EndIf
    }
  }
  { Name Current_Cir ;
    Case {
    }
  }
  //Instead of fixing the constraints we will force the circuit quantities to have a given value (/function)
  { Name Voltage_Cir ;
    Case {
      For i In {1:3}
        { Region Voltage_pr~{i}; Value V_pr~{i};
			TimeFunction F_Cos_wt_p[]{2*Pi*Freq, phase_V~{i}}; }
      EndFor
    } 
  }

	{ Name ElectricalCircuit ; Type Network ;

    Case Circuit_1 {
		// Star coupling for the primary
		If(Prim_connection == 0)
			For i In {1:3}
				aa = 2+(i-1);
				bb = 5+(i-1);
				cc = 8+(i-1);
			  
				{Region Voltage_pr~{i}     ; Branch {1 , aa} ; }
				{Region R_in~{i}           ; Branch {aa, bb} ; }
				{Region Primary_p_phase~{i}; Branch {bb, cc} ; }
				{Region Primary_m_phase~{i}; Branch {cc, 1} ; }
			EndFor
		Else 
			// Delta coupling for the primary
			For i In {1:3}
				aa = 2+(i-1); 
				bb = 5+(i-1); 

				{Region Voltage_pr~{i}     ; Branch {1 , aa} ; }
				{Region R_in~{i}           ; Branch {aa, bb} ; }
			EndFor
			{Region Primary_p_phase~{1}; Branch {5 , 8} ; }
			{Region Primary_m_phase~{1}; Branch {8 , 6} ; }
			{Region Primary_p_phase~{2}; Branch {6 , 9} ; }
			{Region Primary_m_phase~{2}; Branch {9 , 7} ; }
			{Region Primary_p_phase~{3}; Branch {7 , 10}; }
			{Region Primary_m_phase~{3}; Branch {10, 5} ; }
        EndIf

}  

    Case Circuit_2 { 
		If(Second_connection == 0)
			// Star coupling for the secondary
			For i In {1:3}
				aa = 2+(i-1); 
				bb = 5+(i-1); 
				cc = 9+(i-1);

				{Region Secondary_p_phase~{i}; Branch {1 , aa} ; }
				{Region Secondary_m_phase~{i}; Branch {aa, bb} ; }
				If(test == 0 || test == 1)
					// Purely resistive load
					{Region R_out~{i}            ; Branch {bb, 1 } ; }
				Else
					If(Phase == 0)
						// Purely resistive load
						{Region R_out~{i}            ; Branch {bb, 1 } ; }
					ElseIf(Phase == 90)
						// Purely inductive load
						{Region L_out~{i}            ; Branch {bb, 1 } ; }
					ElseIf(Phase == -90)
						// Purely capacitive load
						{Region C_out~{i}            ; Branch {bb, 1 } ; }
					ElseIf(Phase > 0)
						// R-L serie load
						{Region R_out~{i}            ; Branch {bb, cc } ; }
						{Region L_out~{i}            ; Branch {cc, 1 } ; }
					ElseIf(Phase < 0)
						// R-C parallel load
						{Region R_out~{i}            ; Branch {bb, 1 } ; }
						{Region C_out~{i}            ; Branch {bb, 1 } ; }
					EndIf
				EndIf
			EndFor

		Else 
			// Delta coupling for the secondary
			For i In {1:3}
				If(test == 0 || test ==1)
					// Purely resistive load
					{Region R_out~{i}            ; Branch {1, 2+(i-1) } ; }
				Else
					If(Phase == 0)
						// Purely resistive load
						{Region R_out~{i}            ; Branch {1, 2+(i-1) } ; }
					ElseIf(Phase == 90)
						// Purely inductive load
						{Region L_out~{i}            ; Branch {1, 2+(i-1) } ; }
					ElseIf(Phase == -90)
						// Purely capacitive load
						{Region C_out~{i}            ; Branch {1, 2+(i-1) } ; }
					ElseIf(Phase > 0)
						// R-L serie load
						{Region R_out~{i}            ; Branch {1, 5+(i-1) } ; }
						{Region L_out~{i}            ; Branch {5+(i-1), 2+(i-1) } ; }
					ElseIf(Phase < 0)
						// R-C parallel load
						{Region R_out~{i}            ; Branch {1, 2+(i-1) } ; }
						{Region C_out~{i}            ; Branch {1, 2+(i-1) } ; }
					EndIf
				EndIf
			EndFor   
			{Region Secondary_p_phase~{1}; Branch {2 , 6}  ; }
			{Region Secondary_m_phase~{1}; Branch {6 , 3}  ; }
			{Region Secondary_p_phase~{2}; Branch {3 , 8}  ; }
			{Region Secondary_m_phase~{2}; Branch {8 , 4}  ; }
			{Region Secondary_p_phase~{3}; Branch {4 , 10} ; }
			{Region Secondary_m_phase~{3}; Branch {10, 2}  ; }
		EndIf
    }
  }
}

Include "../Libraries/Lib_Magnetodynamics2D_av_Cir.pro";

PostOperation {
{ Name Map_a; NameOfPostProcessing Magnetodynamics2D_av;
    Operation {
		// Visualisation files
		// Print[ j , OnElementsOf Region[{Vol_C_Mag, Vol_S_Mag}], Format Gmsh, File "../Results/j.pos" ];
		// Print[ b , OnElementsOf Vol_Mag, Format Gmsh, File "../Results/b.pos" ];
		// Print[ az, OnElementsOf Vol_Mag, Format Gmsh, File "../Results/az.pos" ];
	  
	  
		// Exterior characteristic files 
		If (Phase != 90 && Phase != -90)
			Print[ U, OnRegion R_out_1, Format FrequencyTable, File > "../Results/U2_Rout_ph1.txt" ];
			Print[ I, OnRegion R_out_1, Format FrequencyTable, File > "../Results/I2_Rout_ph1.txt" ];
			Print[ U, OnRegion R_out_2, Format FrequencyTable, File > "../Results/U2_Rout_ph2.txt" ];
			Print[ I, OnRegion R_out_2, Format FrequencyTable, File > "../Results/I2_Rout_ph2.txt" ];
			Print[ U, OnRegion R_out_3, Format FrequencyTable, File > "../Results/U2_Rout_ph3.txt" ];
			Print[ I, OnRegion R_out_3, Format FrequencyTable, File > "../Results/I2_Rout_ph3.txt" ];
		EndIf
		If(Phase > 0)
			Print[ U, OnRegion L_out_1, Format FrequencyTable, File > "../Results/U2_Lout_ph1.txt" ];
			Print[ U, OnRegion L_out_2, Format FrequencyTable, File > "../Results/U2_Lout_ph2.txt" ];
			Print[ U, OnRegion L_out_3, Format FrequencyTable, File > "../Results/U2_Lout_ph3.txt" ];
			If(Phase == 90)
				Print[ I, OnRegion L_out_1, Format FrequencyTable, File > "../Results/I2_Lout_ph1.txt" ];
				Print[ I, OnRegion L_out_2, Format FrequencyTable, File > "../Results/I2_Lout_ph2.txt" ];
				Print[ I, OnRegion L_out_3, Format FrequencyTable, File > "../Results/I2_Lout_ph3.txt" ]; 
			EndIf
		ElseIf(Phase < 0)
			Print[ I, OnRegion C_out_1, Format FrequencyTable, File > "../Results/I2_Cout_ph1.txt" ];
			Print[ I, OnRegion C_out_2, Format FrequencyTable, File > "../Results/I2_Cout_ph2.txt" ];
			Print[ I, OnRegion C_out_3, Format FrequencyTable, File > "../Results/I2_Cout_ph3.txt" ];
			If(Phase == -90)
				Print[ U, OnRegion C_out_1, Format FrequencyTable, File > "../Results/U2_Cout_ph1.txt" ];
				Print[ U, OnRegion C_out_2, Format FrequencyTable, File > "../Results/U2_Cout_ph2.txt" ];
				Print[ U, OnRegion C_out_3, Format FrequencyTable, File > "../Results/U2_Cout_ph3.txt" ];  
			EndIf
		EndIf
	  
	  
     //2b filled after discussion
    }
  }
}
