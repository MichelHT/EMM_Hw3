% This functions plot the exterior characteristic  of the transformer
% corresponding to the simulations results given as input.
function Exterior_Characteristic(Phase,Directory)
close all;
%% Test Directory:
% 'Core_type_first_try';    ===> Phase = 0
% 'Shell_type_first_try'    ===> Phase = 0
% 'Phi45_Core_type_test';   ===> Phase = 45
% 'Phi90_Core_type_test';   ===> Phase = 90
% 'Phim45_Core_type_test';  ===> Phase = -45
% 'Phim90_Core_type_test';  ===> Phase = -90

%% Importation of the data and computation of the norm of the secondary current and voltage

cd(Directory);
if((Phase ~= 90) & (Phase ~= 90))
    Files_Current = {'I2_Rout_ph1.txt', 'I2_Rout_ph2.txt', 'I2_Rout_ph3.txt'};
    Files_Voltage = {'U2_Rout_ph1.txt', 'U2_Rout_ph2.txt', 'U2_Rout_ph3.txt'};
end
if(Phase > 0)
    Files_Voltage_L = {'U2_Lout_ph1.txt', 'U2_Lout_ph2.txt', 'U2_Lout_ph3.txt'};
    if(Phase == 90)
        Files_Current_L = {'I2_Lout_ph1.txt', 'I2_Lout_ph2.txt', 'I2_Lout_ph3.txt'};
    end
elseif(Phase<0)
    Files_Current_C = {'I2_Cout_ph1.txt', 'I2_Cout_ph2.txt', 'I2_Cout_ph3.txt'};
    if(Phase == -90)
        Files_Voltage_C = {'U2_Cout_ph1.txt', 'U2_Cout_ph2.txt', 'U2_Cout_ph3.txt'};
    end
end

for(i=1:3)
    % Importation
    if((Phase ~= 90) & (Phase ~= -90))
        fid_I=fopen(Files_Current{i},'r');
        fid_V=fopen(Files_Voltage{i},'r');
        fgetl(fid_I);                                           % Saute 1 ligne
        fgetl(fid_V);                                           % Saute 1 ligne
        I2{i}= fscanf(fid_I,'%g %g',[1 inf]);
        V2{i}= fscanf(fid_V,'%g %g',[1 inf]);
        while(feof(fid_I)==0)
            fgetl(fid_I);                                       % Saute 1 ligne
            fgetl(fid_V);                                       % Saute 1 ligne
            I2{i}=[I2{i} ; fscanf(fid_I,'%g %g',[1 inf])];    
            V2{i}=[V2{i} ; fscanf(fid_V,'%g %g',[1 inf])];    
        end
        I2{i} = I2{i}';
        I2{i} = transpose(I2{i}); 
        V2{i} = V2{i}';
        V2{i} = transpose(V2{i});
        fclose(fid_I);
        fclose(fid_V);
    end
    if(Phase > 0)
        fid_V=fopen(Files_Voltage_L{i},'r');
        fgetl(fid_V);                                           % Saute 1 ligne
        V2_L{i}= fscanf(fid_V,'%g %g',[1 inf]);
        while(feof(fid_V)==0)
            fgetl(fid_V);                                       % Saute 1 ligne
            V2_L{i}=[V2_L{i} ; fscanf(fid_V,'%g %g',[1 inf])];    
        end
        V2_L{i} = V2_L{i}';
        V2_L{i} = transpose(V2_L{i});
        fclose(fid_V);
        if(Phase == 90)
            fid_I=fopen(Files_Current_L{i},'r');
            fgetl(fid_I);                                           % Saute 1 ligne
            I2{i}= fscanf(fid_I,'%g %g',[1 inf]);
            while(feof(fid_I)==0)
                fgetl(fid_I);                                       % Saute 1 ligne
                I2{i}=[I2{i} ; fscanf(fid_I,'%g %g',[1 inf])];      
            end
            I2{i} = I2{i}';
            I2{i} = transpose(I2{i}); 
            fclose(fid_I);
            V2{i} = V2_L{i};
        else
            V2{i} = V2{i} + V2_L{i};
        end
        
    elseif(Phase < 0)
        fid_I=fopen(Files_Current_C{i},'r');
        fgetl(fid_I);                                           % Saute 1 ligne
        I2_C{i}= fscanf(fid_I,'%g %g',[1 inf]);
        while(feof(fid_I)==0)
            fgetl(fid_I);                                       % Saute 1 ligne
            I2_C{i}=[I2_C{i} ; fscanf(fid_I,'%g %g',[1 inf])];      
        end
        I2_C{i} = I2_C{i}';
        I2_C{i} = transpose(I2_C{i}); 
        fclose(fid_I);
        if(Phase == -90)
            fid_V=fopen(Files_Voltage_C{i},'r');
            fgetl(fid_V);                                           % Saute 1 ligne
            V2{i}= fscanf(fid_V,'%g %g',[1 inf]);
            while(feof(fid_V)==0)
                fgetl(fid_V);                                       % Saute 1 ligne
                V2{i}=[V2{i} ; fscanf(fid_V,'%g %g',[1 inf])];    
            end
            V2{i} = V2{i}';
            V2{i} = transpose(V2{i});
            fclose(fid_V);
            I2{i} = I2_C{i};
        else
            I2{i} = I2{i} + I2_C{i};
        end
    end
    
    % Norm computation
    for(j=1:length(V2{1}(:,1)))
        I2_norm(i,j) = sqrt((I2{i}(j,2))^2+(I2{i}(j,3))^2); 
        V2_norm(i,j) = sqrt((V2{i}(j,2))^2+(V2{i}(j,3))^2); 
    end
end
cd ..

%% Plotting of the results

Figure1=figure(1);clf;set(Figure1,'defaulttextinterpreter','latex');
hold on;
plot(I2_norm(1,:),V2_norm(1,:),'r','linewidth',2);
plot(I2_norm(2,:),V2_norm(2,:),'b','linewidth',2);
plot(I2_norm(3,:),V2_norm(3,:),'k','linewidth',2);
ylabel('$||U_2||$ [V]');
xlabel('$||I_2||$ [A]');
grid;
legend('Phase 1', 'Phase 2', 'Phase 3');
set(gca,'fontsize',20,'fontname','Times','LineWidth',0.5);


%% Fresnel diagram (to verify the phase of the load)
% Whatever the value of Load, the phase should remain the same.
Load = 30; % Load = 1 ==> Almost Shortt circuit ; Load = length(V2{i}(:,2))  ==> Almost open circuit ; Smtg else: between the 2


Figure2=figure(2);clf;set(Figure2,'defaulttextinterpreter','latex');
col = {'r' 'b' 'k'};
hold on;
grid;
axis('equal')

% Voltage vector
for(i=1:3)    
    Vec_V2_Vide{i} = [V2{i}(Load,2) V2{i}(Load,3)];
    line([0 Vec_V2_Vide{i}(1)] , [0 Vec_V2_Vide{i}(2)],'linewidth',3,'color',col{i});
end

% Current vector
for(i=1:3)
    Vec_I2_Vide{i} = [-I2{i}(Load,2) -I2{i}(Load,3)];
    line([0 Vec_I2_Vide{i}(1)] , [0 Vec_I2_Vide{i}(2)],'linewidth',3,'color',col{i});
end
legend('Phase 1', 'Phase 2', 'Phase 3');
set(gca,'fontsize',20,'fontname','Times','LineWidth',0.5);


end