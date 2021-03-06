%%
%for cg minus 5 AOA vs CL
%clean
clear 
clc

IAS = [240,221,202,179.5,160.1,140.5].*0.5144;
rho = 1.225;
MassOfFuel=(3100+503+[971.6,969.3,965.1,961.4,956.1,953.9]).*0.453592;
WeightOfFuel = MassOfFuel.*9.81;
CL = WeightOfFuel./(0.5.*rho.*IAS.^2.*17.48);
AoA=[-0.55,-0.18,-0.15,-0.047,1.004,2.144];

p1=polyfit(AoA,CL,1);
scatter(AoA,CL);
range = [-10:0.1:10];
hold on
plot(range,p1(1).*range + p1(2));
%%
%landing
IAS_landing = [119.3,111.3,100.6,90.5,80.2,69.6].*0.5144;
rho = 1.225;
MassOfFuel_landing=(3100+503+[936.8,926.9,920.8,917.6,917,914.6]).*0.453592;
WeightOfFuel_landing = MassOfFuel_landing.*9.81;
CL_landing = WeightOfFuel_landing./(0.5.*rho.*IAS_landing.^2.*17.48);
AoA_landing=[-5.248,-4.286,-3.312,-0.781,2.33,6.249];

hold on
scatter(AoA_landing,CL_landing,'*');
p2 = polyfit(AoA_landing,CL_landing,1);
hold on
plot(range,p2(1).*range+p2(2));
legend('points for clean setup','line for clean setup','points for landing setup','line for landing setup');
xlabel('Angel of attack in degree');
ylabel('CL(Coefficient of life)');
title('CL vs AoA for zero xcg - 5');
hold off
%%
%for de and CL
%for clean condition xcg-5

rangeE=[-20:0.01:5];
deltaE=[+0.01*14,-0.01*30,-0.02*30,-0.015*30,-0.068*30,-0.111*30];
scatter(deltaE,CL,'*');
pdeltaE = polyfit(deltaE,CL,1);
hold on
plot(rangeE,pdeltaE(1).*rangeE+pdeltaE(2));
hold on

%%
%landing
deltaE_landing=[-0.003*30,-0.048*30,-0.087*30,-0.203*30,-0.357*30,-0.558*30];
scatter(deltaE_landing,CL_landing,'*');
pdeltaE_landing = polyfit(deltaE_landing,CL_landing,1);
hold on
plot(rangeE,pdeltaE_landing(1).*rangeE+pdeltaE_landing(2));
title('CL vs deltaE when xcg - 5')
ylabel('CL')
xlabel('Elevator deflection in angle');
legend('clean points','Line for clean setup','landing points','Line for landing setup');

%clean dDeltaE/dCl = -14.1970
%landing = -17.5534


