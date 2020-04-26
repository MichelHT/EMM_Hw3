// Commin data
Include "data.geo";

/*********************** Definition of further parameter (whose modification do no require a new mesh generation)  *******************************************/
DefineConstant[
    test = { 0 , Name StrCat[PathElectricalParameters,"01Load connected to the secondary"], Highlight "Red", Visible 1,
		Choices{
			0 = "Short circuit",
			1 = "Open Circuit",
			2 = "Define your load"
    } }];
	

DefineConstant[
	Laminated_Core = { 1 , Name StrCat[PathGeometricParameters,"02Is the core laminated?"], Highlight "Green", Visible 1,
		Choices{
			0 = "No",
			1 = "Yes"
    } }];
Load_exponent  = DefineNumber[-3    , Name StrCat[PathElectricalParameters, "02Order of magnitude of the load expressed in Ohm"      ], Highlight "Red" , Visible test==2];
Phase 		   = DefineNumber[0     , Name StrCat[PathElectricalParameters, "03Phase of the load connected to the secondary (in deg)"], Highlight "Red" , Visible test==2];
muir_Core      = DefineNumber[20000 , Name StrCat[PathMaterialsParameters , "10Relative permeability of the core"                    ], Highlight "Yellow"]; //static permeability between 20000 and 50000
B_sat          = DefineNumber[2   , Name StrCat[PathElectricalParameters, "11Saturation magnetic flux density [T]"                 ], Highlight "Red"   ]; //varies with the magnetic material only defined for ferrites magnetic material
Concentration_Coef          = DefineNumber[3.25   , Name StrCat[PathElectricalParameters, "12Correction of the concentration of flux at the rounded corner of the core"], Highlight "Red"   ];
Snoek_constant = DefineNumber[4*giga, Name StrCat[PathMaterialsParameters , "13Snoek constant"                                       ], Highlight "Yellow"]; // [4,12]gigaHz
Freq           = DefineNumber[50    , Name StrCat[PathElectricalParameters, "08Operating frequency              "                    ], Highlight "Red" , Visible Flag_FrequencyDomain ];

// Boucherot formulation: We basically impose the core thickness so that the magnetic flux generated by one single phase lead to 80% of B_sat in a 
// magnetic circuit of width W_Ref. 
Thickness_Core    = (Voltage_primary)/((2*Pi)/(Sqrt[2]))/Freq/(0.8*B_sat)/Primary_Turns/W_Ref;

// The thickeness of the core is further updated because the magnetic flux density at the rounded corner of the core is higher than at the 
// center of the core. The value Concentration_Coef has been manually adjusted so that the maximum flux density reached at the rounded corner of the core is equal to 80% of B_sat.
Thickness_Core  = Thickness_Core *(Concentration_Coef/(0.8*B_sat)); 

/************************************ Beginning of the .Pro file ******************************************************/
Group {

	// Physical regions
	Air         = Region[{Air_ext}];
	Core        = Region[{Core}]   ;

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
	Vol_Mag     = Region[{Air, Core, Coils}]; 
	Vol_S_Mag   = Region[{Coils}]           ; 
	
	If(Laminated_Core==0)
		Vol_C_Mag = Region[{Core}];
	EndIf

	If (Add_shield==0)
		Air_Inf	    = Region[{AirInf}]     ;
		Sur_Air_Ext = Region[{Skin_airInf}]; 
		Vol_Inf_Mag = Region[{Air_Inf}]    ;
		Vol_Mag    += Region[{Air_Inf}]    ;
		Val_Rint = R_int                   ;  
		Val_Rext = R_ext                   ; 
	Else
		Sur_Air_Ext = Region[{Skin_air}]; 
	EndIf
}

Function{
	// The frequency dependant permeability (Debye model)
	relaxation_frequency = Snoek_constant/muir_Core   ;
	Omega                = 2*Pi*Freq                  ;
	tau                  = 1/2/Pi/relaxation_frequency;  

	//Constant Permeability
	mu[Core]   = Re[muir_Core*mu0/Complex[1,Omega*tau]];

    mu[Air]    = 1 * mu0 ;

	If (Add_shield==0 )
		mu[Air_Inf]= 1 * mu0 ;
	EndIf
	
	mu[Coils]  = 1 * mu0 ;

	nu[]       = 1 / mu[];

	//Conductivity
	sigma[Coils]  = 1e7;

	If (Laminated_Core==0)
		sigma[Core]   = 1e7;
	EndIf

	//Signs:
	For i In {1:3}
		SignBranch[Primary_p_phase~{i}]   =  1;
		SignBranch[Secondary_p_phase~{i}] =  1;
		SignBranch[Primary_m_phase~{i}]   = -1;
		SignBranch[Secondary_m_phase~{i}] = -1;
	EndFor

	Ns[Primary_coils]  = Primary_Turns        ;
	Ns[Secondary_coils]= Secondary_Turns      ;

	//Defining the current density: 
	For i In {1:3}
		Sc[Primary_p_phase~{i}]   = SurfaceArea[];
		Sc[Primary_m_phase~{i}]   = SurfaceArea[];
		Sc[Secondary_p_phase~{i}] = SurfaceArea[];
		Sc[Secondary_m_phase~{i}] = SurfaceArea[];
	EndFor

	js0[Coils] = Ns[] / Sc[] * Vector[0, 0, SignBranch[]];	
	CoefGeos[Coils] = SignBranch[] * Thickness_Core; 
	CoefGeos[Core]  = Thickness_Core               ; 
}

Flag_CircuitCoupling=1;

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
				L_out~{i}   = Region[{zz}]           ; // The load inductance
				Inductance_Cir += Region[{L_out~{i}}];
			ElseIf (Phase<0)
				zz = zz + 2;
				C_out~{i}   = Region[{zz}]       ;		 // The load capacitance
				Capacitance_Cir += Region[{C_out~{i}}];
			EndIf	
		EndIf
	EndFor
}

Function { 
	deg = Pi/180  ;

	For i In {1:3}
		// Input Voltages:
		V_pr~{i}    = Voltage_primary  ;
		phase_V~{i} = 120 * (i-1) * deg;

		// Input resistances
		Resistance[R_in~{i}] = 1e-3 ; 

		// Load resistances
		If (test == 0)
			//Short circuit
			// Resistance[R_out~{i}] = 750*mili   ; 
			Resistance[R_out~{i}] = 0   ; 
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
					{Region R_out~{i}                ; Branch {1, 2+(i-1) } ; }
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
		
	/************************************ Print the dimensions computed automatically  ******************************************************/
	// Default value (easier to see in the gui). If the user perfom a modification the value in the GUI are not updated, but the actual values are plotted in the information window.
	W_Hole_Print	 		 = DefineNumber[W_Hole         , Name StrCat[PathResultsUI ,"03Width of the holes in the core (Not Updated!!)"   ], Highlight "Black"];
	W_Leg_Print	 		     = DefineNumber[W_Leg       	, Name StrCat[PathResultsUI ,"04Width of the external vertical part of the core (Not Updated!!)"], Highlight "Black"];
	W_Centre_Print	 		 = DefineNumber[W_Centre       	, Name StrCat[PathResultsUI ,"05Width of the central vertical part of the core (Not Updated!!)"], Highlight "Black"];
	H_Leg_Print	 		     = DefineNumber[H_Leg       	, Name StrCat[PathResultsUI ,"06Width of the external horizontal part of the core (Not Updated!!)"], Highlight "Black"];
	If (Geo == 1)	
		H_Centre_Print	 	 = DefineNumber[H_Centre       	, Name StrCat[PathResultsUI ,"07Width of the central horizontal part of the core (Not Updated!!)"], Highlight "Black"];	
	EndIf
	Thickness_Core_Print	 = DefineNumber[Thickness_Core , Name StrCat[PathResultsUI ,"04Thickness of the core (Not Updated!!)"            ], Highlight "Black"];
	H_Inductor1_Print		 = DefineNumber[H_Inductor1    , Name StrCat[PathResultsUI ,"05Height of the primary inductors (Not Updated!!)"  ], Highlight "Black"];
	H_Inductor2_Print		 = DefineNumber[H_Inductor2    , Name StrCat[PathResultsUI ,"06Height of the secondary inductors (Not Updated!!)"], Highlight "Black"];
	//Current value (printed in the information window)
	Printf("");
	Printf(" /************************************ Automatically computed dimensions ******************************************************/");
	Printf("W_Hole: %f [m] ",W_Hole);
	Printf("W_Leg: %f [m] ",W_Leg);
	Printf("W_Centre: %f [m] ",W_Centre);
	Printf("H_Leg %f [m] ",H_Leg);
	If (Geo == 1)	
		Printf("H_Centre: %f [m] ",H_Centre);
	EndIf
	Printf("Thickness_Core: %f [m] ",Thickness_Core);
	Printf("H_Inductor1: %f [m] ",H_Inductor1);
	Printf("H_Inductor2: %f [m]",H_Inductor2);
	Printf("");

    If (OverWriteOutput==1)
       If (test==0) //short circuit test
          DeleteFile["../Results/TransformerModel/UShortCircuit.txt"];
          DeleteFile["../Results/TransformerModel/IShortCircuit.txt"];
        ElseIf (test==1) //open ciruit test
          DeleteFile["../Results/TransformerModel/UOpenCircuit.txt" ];
          DeleteFile["../Results/TransformerModel/IOpenCircuit.txt" ];
        ElseIf (test==2) //load defined by user
          If (Phase != 90 && Phase != -90)
            DeleteFile["../Results/ExteriorCharacteristic/U2_Rout_ph1.txt"];
            DeleteFile["../Results/ExteriorCharacteristic/I2_Rout_ph1.txt"];
            DeleteFile["../Results/ExteriorCharacteristic/U2_Rout_ph2.txt"];
            DeleteFile["../Results/ExteriorCharacteristic/I2_Rout_ph2.txt"];
            DeleteFile["../Results/ExteriorCharacteristic/U2_Rout_ph3.txt"];
            DeleteFile["../Results/ExteriorCharacteristic/I2_Rout_ph3.txt"];
          EndIf
          If (Phase > 0)
            DeleteFile["../Results/ExteriorCharacteristic/U2_Lout_ph1.txt"];
            DeleteFile["../Results/ExteriorCharacteristic/U2_Lout_ph2.txt"];
            DeleteFile["../Results/ExteriorCharacteristic/U2_Lout_ph3.txt"];
            If(Phase == 90)
              DeleteFile["../Results/ExteriorCharacteristic/I2_Lout_ph1.txt"];
              DeleteFile["../Results/ExteriorCharacteristic/I2_Lout_ph2.txt"];
              DeleteFile["../Results/ExteriorCharacteristic/I2_Lout_ph3.txt"];
            EndIf
          ElseIf(Phase < 0)
            DeleteFile["../Results/ExteriorCharacteristic/I2_Cout_ph1.txt"];
            DeleteFile["../Results/ExteriorCharacteristic/I2_Cout_ph2.txt"];
            DeleteFile["../Results/ExteriorCharacteristic/I2_Cout_ph3.txt"];
             If (Phase == -90)
              DeleteFile["../Results/ExteriorCharacteristic/U2_Cout_ph1.txt"];
              DeleteFile["../Results/ExteriorCharacteristic/U2_Cout_ph2.txt"];
              DeleteFile["../Results/ExteriorCharacteristic/U2_Cout_ph3.txt"];
            EndIf
          EndIf
        EndIf
        DeleteFile["../Results/Frequency.txt"];
      EndIf
	
    //File containing all the studied frequencies:
	Echo[Sprintf("%g", Freq), Format Table, File > "../Results/Frequency.txt"];

      // Do you want to see the field card?
	If (Field_Card==1)
        Print[ j , OnElementsOf Region[{Vol_C_Mag, Vol_S_Mag}], Format Gmsh, File "../Results/j.pos" ];
        Print[ b , OnElementsOf Vol_Mag, Format Gmsh, File "../Results/b.pos"  ];
        Print[ az, OnElementsOf Vol_Mag, Format Gmsh, File "../Results/az.pos" ];
    EndIf 
	  
    If (Flag_FrequencyDomain)      

	/****************************************Equivalent model files*****************************************************/ 
      If (test==0) //Short circuit
			// Primary Measure
			Print[ U, OnRegion Voltage_pr_1, Format Table, File > "../Results/Equivalent_Circuit_Test/SC_U1_Vpr_ph1.txt"];
			Print[ U, OnRegion R_in_1      , Format Table, File > "../Results/Equivalent_Circuit_Test/SC_U1_Rin_ph1.txt"];
			Print[ I, OnRegion R_in_1      , Format Table, File > "../Results/Equivalent_Circuit_Test/SC_I1_Rin_ph1.txt"];
			Print[ U, OnRegion Voltage_pr_2, Format Table, File > "../Results/Equivalent_Circuit_Test/SC_U1_Vpr_ph2.txt"];
			Print[ U, OnRegion R_in_2      , Format Table, File > "../Results/Equivalent_Circuit_Test/SC_U1_Rin_ph2.txt"];
			Print[ I, OnRegion R_in_2      , Format Table, File > "../Results/Equivalent_Circuit_Test/SC_I1_Rin_ph2.txt"];
			Print[ U, OnRegion Voltage_pr_3, Format Table, File > "../Results/Equivalent_Circuit_Test/SC_U1_Vpr_ph3.txt"];
			Print[ U, OnRegion R_in_3      , Format Table, File > "../Results/Equivalent_Circuit_Test/SC_U1_Rin_ph3.txt"];
			Print[ I, OnRegion R_in_3      , Format Table, File > "../Results/Equivalent_Circuit_Test/SC_I1_Rin_ph3.txt"];
		
			// Secondary Measure
			Print[ U, OnRegion R_out_1, Format Table, File > "../Results/Equivalent_Circuit_Test/SC_U2_Rout_ph1.txt"];
			Print[ I, OnRegion R_out_1, Format Table, File > "../Results/Equivalent_Circuit_Test/SC_I2_Rout_ph1.txt"];
			Print[ U, OnRegion R_out_2, Format Table, File > "../Results/Equivalent_Circuit_Test/SC_U2_Rout_ph2.txt"];
			Print[ I, OnRegion R_out_2, Format Table, File > "../Results/Equivalent_Circuit_Test/SC_I2_Rout_ph2.txt"];
			Print[ U, OnRegion R_out_3, Format Table, File > "../Results/Equivalent_Circuit_Test/SC_U2_Rout_ph3.txt"];
			Print[ I, OnRegion R_out_3, Format Table, File > "../Results/Equivalent_Circuit_Test/SC_I2_Rout_ph3.txt"];

		ElseIf (test==1) // Open circuit
			// Primary Measure
			Print[ U, OnRegion Voltage_pr_1, Format Table, File > "../Results/Equivalent_Circuit_Test/OC_U1_Vpr_ph1.txt"];
			Print[ U, OnRegion R_in_1      , Format Table, File > "../Results/Equivalent_Circuit_Test/OC_U1_Rin_ph1.txt"];
			Print[ I, OnRegion R_in_1      , Format Table, File > "../Results/Equivalent_Circuit_Test/OC_I1_Rin_ph1.txt"];
			Print[ U, OnRegion Voltage_pr_2, Format Table, File > "../Results/Equivalent_Circuit_Test/OC_U1_Vpr_ph2.txt"];
			Print[ U, OnRegion R_in_2      , Format Table, File > "../Results/Equivalent_Circuit_Test/OC_U1_Rin_ph2.txt"];
			Print[ I, OnRegion R_in_2      , Format Table, File > "../Results/Equivalent_Circuit_Test/OC_I1_Rin_ph2.txt"];
			Print[ U, OnRegion Voltage_pr_3, Format Table, File > "../Results/Equivalent_Circuit_Test/OC_U1_Vpr_ph3.txt"];
			Print[ U, OnRegion R_in_3      , Format Table, File > "../Results/Equivalent_Circuit_Test/OC_U1_Rin_ph3.txt"];
			Print[ I, OnRegion R_in_3      , Format Table, File > "../Results/Equivalent_Circuit_Test/OC_I1_Rin_ph3.txt"];
		
			// Sceondary Measure
			Print[ U, OnRegion R_out_1, Format Table, File > "../Results/Equivalent_Circuit_Test/OC_U2_Rout_ph1.txt"];
			Print[ I, OnRegion R_out_1, Format Table, File > "../Results/Equivalent_Circuit_Test/OC_I2_Rout_ph1.txt"];
			Print[ U, OnRegion R_out_2, Format Table, File > "../Results/Equivalent_Circuit_Test/OC_U2_Rout_ph2.txt"];
			Print[ I, OnRegion R_out_2, Format Table, File > "../Results/Equivalent_Circuit_Test/OC_I2_Rout_ph2.txt"];
			Print[ U, OnRegion R_out_3, Format Table, File > "../Results/Equivalent_Circuit_Test/OC_U2_Rout_ph3.txt"];
			Print[ I, OnRegion R_out_3, Format Table, File > "../Results/Equivalent_Circuit_Test/OC_I2_Rout_ph3.txt"];

	/***************************************** Exterior characteristic files**************************************************/ 
		ElseIf(test==2)
    		If (Phase != 90 && Phase != -90)
    			Print[ U, OnRegion R_out_1, Format FrequencyTable, File > "../Results/ExteriorCharacteristic/U2_Rout_ph1.txt"];
    			Print[ I, OnRegion R_out_1, Format FrequencyTable, File > "../Results/ExteriorCharacteristic/I2_Rout_ph1.txt"];
    			Print[ U, OnRegion R_out_2, Format FrequencyTable, File > "../Results/ExteriorCharacteristic/U2_Rout_ph2.txt"];
    			Print[ I, OnRegion R_out_2, Format FrequencyTable, File > "../Results/ExteriorCharacteristic/I2_Rout_ph2.txt"];
    			Print[ U, OnRegion R_out_3, Format FrequencyTable, File > "../Results/ExteriorCharacteristic/U2_Rout_ph3.txt"];
    			Print[ I, OnRegion R_out_3, Format FrequencyTable, File > "../Results/ExteriorCharacteristic/I2_Rout_ph3.txt"];
    		EndIf
    		If(Phase > 0)
    			Print[ U, OnRegion L_out_1, Format FrequencyTable, File > "../Results/ExteriorCharacteristic/U2_Lout_ph1.txt"];
    			Print[ U, OnRegion L_out_2, Format FrequencyTable, File > "../Results/ExteriorCharacteristic/U2_Lout_ph2.txt"];
    			Print[ U, OnRegion L_out_3, Format FrequencyTable, File > "../Results/ExteriorCharacteristic/U2_Lout_ph3.txt"];
    			If(Phase == 90)
    				Print[ I, OnRegion L_out_1, Format FrequencyTable, File > "../Results/ExteriorCharacteristic/I2_Lout_ph1.txt"];
    				Print[ I, OnRegion L_out_2, Format FrequencyTable, File > "../Results/ExteriorCharacteristic/I2_Lout_ph2.txt"];
    				Print[ I, OnRegion L_out_3, Format FrequencyTable, File > "../Results/ExteriorCharacteristic/I2_Lout_ph3.txt"]; 
    			EndIf
    		ElseIf(Phase < 0)
    			Print[ I, OnRegion C_out_1, Format FrequencyTable, File > "../Results/ExteriorCharacteristic/I2_Cout_ph1.txt"];
    			Print[ I, OnRegion C_out_2, Format FrequencyTable, File > "../Results/ExteriorCharacteristic/I2_Cout_ph2.txt"];
    			Print[ I, OnRegion C_out_3, Format FrequencyTable, File > "../Results/ExteriorCharacteristic/I2_Cout_ph3.txt"];
    			If(Phase == -90)
    				Print[ U, OnRegion C_out_1, Format FrequencyTable, File > "../Results/ExteriorCharacteristic/U2_Cout_ph1.txt"];
    				Print[ U, OnRegion C_out_2, Format FrequencyTable, File > "../Results/ExteriorCharacteristic/U2_Cout_ph2.txt"];
    				Print[ U, OnRegion C_out_3, Format FrequencyTable, File > "../Results/ExteriorCharacteristic/U2_Cout_ph3.txt"];  
    			EndIf
    		EndIf
        EndIf
    EndIf
    }
  }
}
