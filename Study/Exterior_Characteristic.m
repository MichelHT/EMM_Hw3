% This functions plot the exterior characteristic  of the transformer
% corresponding to the simulations results given as input.
function Exterior_Characteristic

%% Directory containing the simulations results

Directory = 'Core_type_first_try';
% Directory = 'Shell_type_first_try';


%% Importation of the data and computation of the norm of the secondary current and voltage

cd(Directory);
Files_Current = {'I2_ph1.txt', 'I2_ph2.txt', 'I2_ph3.txt'};
Files_Voltage = {'U2_ph1.txt', 'U2_ph2.txt', 'U2_ph3.txt'};
for(i=1:3)
    % Importation
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
ylabel('$U_2$ [V]');
xlabel('$I_2$ [A]');
grid;
legend('Phase 1', 'Phase 2', 'Phase 3');
set(gca,'fontsize',20,'fontname','Times','LineWidth',0.5);


%% Fresnel diagram open circuit

Figure2=figure(2);clf;set(Figure2,'defaulttextinterpreter','latex');
col = {'r' 'b' 'k'}
hold on;
grid;
for(i=1:3)    
Vec_V2_Vide{i} = [V2{i}(end,2) V2{i}(end,3)];
line([0 Vec_V2_Vide{i}(1)] , [0 Vec_V2_Vide{i}(2)],'linewidth',3,'color',col{i});
end
axis('equal')
legend('Phase 1', 'Phase 2', 'Phase 3');
set(gca,'fontsize',20,'fontname','Times','LineWidth',0.5);


end
