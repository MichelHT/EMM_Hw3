Include "date.geo";

mur_Core = DefineNumber[1000, Name StrCat[PathMaterialsParameters , "Relative permeability of the core"], Highlight "Yellow"];
Freq     = DefineNumber[50  , Name StrCat[PathElectricalParameters, "Operating frequency              "], Highlight "Red"];

Group {
  Air         = Region[{Air_Window, Air}];
  Sur_Air_Ext = Region[{Skin_airInf}]    ; // exterior boundary
  Core        = Region[{Core}]           ; // magnetic core of the transformer, assumed non-conducting
  Vol_Inf_Mag = Region[{AirInf}]         ; //We are applying the infinite shell transformation for accuracy

  For i In {1:3}
  	Primary_p_phase~{i}   = Region[{Primary_ph1_p + (i - 1) * 100}    ];
  	Primary_m_phase~{i}   = Region[{Primary_ph1_p + (i - 1 + 3) * 100}];
   	Secondary_p_phase~{i} = Region[{Primary_ph1_p + (i - 1 + 6) * 100}];
  	Secondary_m_phase~{i} = Region[{Primary_ph1_p + (i - 1 + 9) * 100}];
  EndFor 

  For i In {0:11}
  	Coils += Region[{Primary_ph1_p + i * 100}]; 
  EndFor

  // Abstract regions 
  Vol_Mag   = Region[{Air, Core, Coils}]; // full magnetic domain (surfaces)
  Vol_S_Mag = Region[{Coils}]           ; // Stranded conductors only. 
}

Function{
//Permeability
  mu[Air, Coils] = 1 * mu0       ;
  mu[Core]       = mur_Core * mu0;
  nu[]           = 1 / mu[]      ;

//Conductivity
   sigma[Coils]  = 1e7           ;

//Signs:
   For i In {1:3}
     SignBranch[Primary_p_phase~{i},Secondary_p_phase~{i}] =  1;
     SignBranch[Primary_m_phase~{i},Secondary_m_phase~{i}] = -1;
   EndFor

//Constants for the infinite shell transformation:
	Val_Rint = R_in ;
	Val_Rext = R_out;

//Defining the current density:
		
   For i In {1:3}
   	Ns[] = 100; //2b modified selon Type A or B. I'll get back to it later
   	Ns[] = 200; //2b modified selon Type A or B. I'll get back to it later
	Sc[Primary_p_phase~{i}]   = SurfaceArea[];
    Sc[Primary_m_phase~{i}]   = SurfaceArea[];
    Sc[Secondary_p_phase~{i}] = SurfaceArea[];
    Sc[Secondary_m_phase~{i}] = SurfaceArea[];
   EndFor

   js0[Coils] = Ns[] / Sc[] * Vector[0, 0, SignBranch[]];

//2b added to the definition of the voltage:
	CoefGeos[Coils] = SignBranch[] * thickness_Core; //thickness_Core to be defined
}

//Connecting the + and - of the coils in series fofre primary and secondary 
Flag_CircuitCoupling = 1;

Group {
  Resistance_Cir  = Region[{}]; // resistances
  Inductance_Cir  = Region[{}]; // inductances
  Capacitance_Cir = Region[{}]; // capacitances
  SourceV_Cir     = Region[{}]; // voltage sources
  SourceI_Cir     = Region[{}]; // current sources

  // Primary side
  E_in = Region[10001];  //Voltage sourc
  SourceV_Cir += Region[{E_in}];
  R_in = Region[10002]; // Resistance in series with the voltage source
  Resistance_Cir += Region[{R_in}];

  // Secondary side
  R_out = Region[10101]; //The load resistance
  Resistance_Cir += Region[{R_out}];
}

Function { 
  deg              = Pi/180         ;
  phase_E_in       = 90 *deg        ;
  val_E_in         = Voltage_primary;
  Resistance[R_in] = 1e-3           ; //Inputs series resistance

  If (Test == 0)
  	Resistance[R_out] = 750*mili;
  ElseIf (Test == 1)
 	Resistance[R_out] = 1e7;
  Else 
    Resistance[R_out] = DefineNumber[1*kilo, Name StrCat[PathElectricalParameters,"02Resistance of the load"], Highlight "Red"];
  EndIf
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
    }
  }
  { Name Current_Cir ;
    Case {
    }
  }
  //Instead of fixing the constraints we will force the circuit quantities to have a given value (/function)
  { Name Voltage_Cir ;
    Case {
      { Region E_in; Value val_E_in;
        TimeFunction F_Cos_wt_p[]{2*Pi*Freq, phase_E_in}; }
    }

  }

  //J'attend ta réponse pour finir cette partie
//	{ Name ElectricalCircuit ; Type Network ;
//    Case Circuit_1 { //the circuit for the primary
//      { Region E_in; Branch {1,2}; }
//      { Region R_in; Branch {2,3}; }

//      { Region Coil_1_P; Branch {2,3} ; }
//      { Region Coil_1_M; Branch {3,1} ; }
//    }
//    Case Circuit_2 { //the circuit for the secondary
//      { Region R_out; Branch {1,2}; }

//      { Region Coil_2_P; Branch {2,3} ; }
//      { Region Coil_2_M; Branch {3,1} ; }
//    }
//  }
//}


Include "../Libraries/Lib_Magnetodynamics2D_av_Cir.pro";

PostOperation {
//We need to talk x) 
}