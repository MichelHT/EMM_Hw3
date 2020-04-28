% This function computes the equivalent circuit of the transformer 
% corresponding to the simulations results given as input 

function Equivalent_Circuit(Directory)
close all; 

%% Name of the files

% Short circuit Files
File_CurrentSC_Primary = {'SC_I1_Rin_ph1.txt', 'SC_I1_Rin_ph2.txt', 'SC_I1_Rin_ph3.txt'};
File_VinSC_Primary = {'SC_U1_Vpr_ph1.txt', 'SC_U1_Vpr_ph2.txt', 'SC_U1_Vpr_ph3.txt'};
File_VRinSC_Primary = {'SC_U1_Rin_ph1.txt', 'SC_U1_Rin_ph2.txt', 'SC_U1_Rin_ph3.txt'};

File_CurrentSC_Secondary = {'SC_I2_Rout_ph1.txt' , 'SC_I2_Rout_ph2.txt' , 'SC_I2_Rout_ph3.txt'};
File_VSC_Secondary = {'SC_U2_Rout_ph1.txt', 'SC_U2_Rout_ph2.txt', 'SC_U2_Rout_ph3.txt'};

% Open circuit Files
File_CurrentOC_Primary = {'OC_I1_Rin_ph1.txt', 'OC_I1_Rin_ph2.txt', 'OC_I1_Rin_ph3.txt'};
File_VinOC_Primary = {'OC_U1_Vpr_ph1.txt', 'OC_U1_Vpr_ph2.txt', 'OC_U1_Vpr_ph3.txt'};
File_VRinOC_Primary = {'OC_U1_Rin_ph1.txt', 'OC_U1_Rin_ph2.txt', 'OC_U1_Rin_ph3.txt'};

File_CurrentOC_Secondary = {'OC_I2_Rout_ph1.txt' , 'OC_I2_Rout_ph2.txt' , 'OC_I2_Rout_ph3.txt'};
File_VOC_Secondary = {'OC_U2_Rout_ph1.txt', 'OC_U2_Rout_ph2.txt', 'OC_U2_Rout_ph3.txt'};


%% Importation of the data and computation of the equivalent parameters
cd(Directory)
for(i=1:3) % Loop over the phase
    
    % Importation of all data (The secondary quantities are never used, but we have them so I have imported them, who knows, it may be useful one day ^^)
    fid_CurrentSC_Primary          =fopen(File_CurrentSC_Primary{i},'r');
    fid_VinSC_Primary              =fopen(File_VinSC_Primary{i},'r');
    fid_VRinSC_Primary             =fopen(File_VRinSC_Primary{i},'r');
    fid_CurrentSC_Secondary        =fopen(File_CurrentSC_Secondary{i},'r');
    fid_VSC_Secondary              =fopen(File_VSC_Secondary{i},'r'); 
    fid_CurrentOC_Primary          =fopen(File_CurrentOC_Primary{i},'r');
    fid_VinOC_Primary              =fopen(File_VinOC_Primary{i},'r');
    fid_VRinOC_Primary             =fopen(File_VRinOC_Primary{i},'r'); 
    fid_CurrentOC_Secondary        =fopen(File_CurrentOC_Secondary{i},'r');
    fid_VOC_Secondary              =fopen(File_VOC_Secondary{i},'r');
    
    % Loop parameter initialization
    j = 1;
    
    % This part was for jump one line in the file, not necessary anymore
    % because the format of the file has changed I don't know why 
    
    %     fgetl(fid_CurrentSC_Primary);
    %     fgetl(fid_VinSC_Primary);
    %     fgetl(fid_VRinSC_Primary);
    %     fgetl(fid_CurrentSC_Secondary);
    %     fgetl(fid_VSC_Secondary);
    %     fgetl(fid_CurrentOC_Primary);
    %     fgetl(fid_VinOC_Primary);
    %     fgetl(fid_VRinOC_Primary);
    %     fgetl(fid_CurrentOC_Secondary);
    %     fgetl(fid_VOC_Secondary);
    
    
    while(feof(fid_CurrentSC_Primary)==0)% Loop over the number of test performed (loop parameter: j)
        
        CurrentSC_Primary{i,j}= fscanf(fid_CurrentSC_Primary,'%g %g',[1 3]);        % Current in the primary short circuit case
        VinSC_Primary{i,j}= fscanf(fid_VinSC_Primary,'%g %g',[1 3]);                % Impose primary voltage short circuit case
        VRinSC_Primary{i,j}= fscanf(fid_VRinSC_Primary,'%g %g',[1 3]);              % Voltage drop accross Rin short circuit case
        CurrentSC_Secondary{i,j}= fscanf(fid_CurrentSC_Secondary,'%g %g',[1 3]);    % Current in secondary short circuit case
        VSC_Secondary{i,j}= fscanf(fid_VSC_Secondary,'%g %g',[1 3]);                % Voltage secondary short circuit case
        CurrentOC_Primary{i,j}= fscanf(fid_CurrentOC_Primary,'%g %g',[1 3]);        % Current in the primary open circuit case
        VinOC_Primary{i,j}= fscanf(fid_VinOC_Primary,'%g %g',[1 3]);                % Impose primary voltage open circuit cas
        VRinOC_Primary{i,j}= fscanf(fid_VRinOC_Primary,'%g %g',[1 3]);              % Voltage drop accross Rin open circuit case
        CurrentOC_Secondary{i,j}= fscanf(fid_CurrentOC_Secondary,'%g %g',[1 3]);    % Current in secondary open circuit case
        VOC_Secondary{i,j}= fscanf(fid_VOC_Secondary,'%g %g',[1 3]);                % Voltage secondary open circuit case
        
        % Computatin of the Voltage applied on the windings
        VSC_Primary{i,j} = VinSC_Primary{i,j} - VRinSC_Primary{i,j};
        VOC_Primary{i,j} = VinOC_Primary{i,j} - VRinOC_Primary{i,j};

        % Computation of the active and reactive power consumption
        PSC{i,j} = (VSC_Primary{i,j}(2)*CurrentSC_Primary{i,j}(2))+(VSC_Primary{i,j}(3)*CurrentSC_Primary{i,j}(3));                 % Dot product (= |VSC|*|ISC|*cos(phi))
        POC{i,j} = (VOC_Primary{i,j}(2)*CurrentOC_Primary{i,j}(2))+(VOC_Primary{i,j}(3)*CurrentOC_Primary{i,j}(3));                 % Dot product (= |VOC|*|IOC|*cos(phi))
        temp = -cross([VSC_Primary{i,j}(2) VSC_Primary{i,j}(3) 0 ],[CurrentSC_Primary{i,j}(2) CurrentSC_Primary{i,j}(3) 0]);        % Cross product(= |VSC|*|ISC|*sin(phi))
        QSC{i,j} = temp(3);
        temp = -cross([VOC_Primary{i,j}(2) VOC_Primary{i,j}(3) 0 ],[CurrentOC_Primary{i,j}(2) CurrentOC_Primary{i,j}(3) 0]);        % Cross product(= |VOC|*|IOC|*sin(phi))
        QOC{i,j} = temp(3);

        % Equivalent circuit parameters (Formula given in the slides)
        R1_p_R2p{i,j} = (PSC{i,j})/((CurrentSC_Primary{i,j}(2)*CurrentSC_Primary{i,j}(2))+(CurrentSC_Primary{i,j}(3)*CurrentSC_Primary{i,j}(3)));
        X1_p_X2p{i,j} = (QSC{i,j})/((CurrentSC_Primary{i,j}(2)*CurrentSC_Primary{i,j}(2))+(CurrentSC_Primary{i,j}(3)*CurrentSC_Primary{i,j}(3)));
        Xmu{i,j} = ((VOC_Primary{i,j}(2)*VOC_Primary{i,j}(2))+(VOC_Primary{i,j}(3)*VOC_Primary{i,j}(3)))/(QOC{i,j});
        
        % As a guy mentionned during the class, for the core type we have a
        % huge imbalanced between the losses in each phase. This imbalanced
        % is modified when we vary Ns, but the sum of all losses in all the
        % phase remains constant when Ns is varied. I think there is
        % something to understand here :) I have computed the mean
        % resistance (= total resistance divided by 3) and I take it into
        % account to compute the efficiency of the transformer as we
        % discussed.
        if(i==1)
            R_Mean{j} = R1_p_R2p{i,j}/3;
        else
            R_Mean{j} = R_Mean{j} + R1_p_R2p{i,j}/3;
        end
        j = j + 1;
    end   

    % Close the files
    fclose(fid_CurrentSC_Primary);
    fclose(fid_VinSC_Primary);
    fclose(fid_VRinSC_Primary);
    fclose(fid_CurrentSC_Secondary);
    fclose(fid_VSC_Secondary);
    fclose(fid_CurrentOC_Primary);
    fclose(fid_VinOC_Primary);
    fclose(fid_VRinOC_Primary);
    fclose(fid_CurrentOC_Secondary);
    fclose(fid_VOC_Secondary);   

end

cd .. 
end