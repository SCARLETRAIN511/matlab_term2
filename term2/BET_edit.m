%This script is to analyse rotorcrafts and propellers using the way of
%splitting blade into pieces
%all the inputs about angles should be in radians except twist(degree)
%written by Jiaxuan Tang for Computing coursework quesion 2
clc
clear

%ask user for the ASCII file
fid=fopen('N0012.dat','r');
trash=fscanf(fid,'%*s',3);%jump the title
%use fscanf to store the value of the file into an array
AOA_VS_CL_CD=fscanf(fid,'%e',[3,inf]);%this will be a nx3 array

%warning: the data in AOA_VS_CL_CD about angle of attack is in unit of
%degree so when calculating angle of attack below, you should also use
%degree

%set the initial condition
N=4;%blade numbers
D=16.36;%diameter of the blade
R0=1.55;
Croot=0.53;
Ctip=0.53;
E=-18;%degree linear blade twist
angular_velocity=27;%rads s^-1
density=1.12;%density of air
R_cut=200;
psi_cut=360;

ic=input('input the blade setting angle(degree):')*pi/180;%get the blade setting angle,turn it into radian
Vinf=input('input the forward airspeed(ft/s):');%forwad speed
Winf=input('input the rate of descent(ft/s):');
twist=E*pi/180;%input will be degree so turn in to radian

%caluculate the local chord for each small section and the positions of
%them
for i=1:R_cut
    section_chord(i)=Croot+(Ctip-Croot)*i/200;%the width for each small pieces
    R(i)=R0+(D/2-R0)*i/200;%Distance from center, value of R
end
Fn_init=0;%set the inital totol thrust
psi=0:2*pi/(psi_cut-1):2*pi;%azimuth_angle

% use cubic spline to calculate corresponding value of CL and CD specific
% angle of attack
CL=[];%initiate lift coefficient
CD=[];%initiate dray coefficient
AOA_list=AOA_VS_CL_CD(1,:);
CL_list=AOA_VS_CL_CD(2,:);
CD_list=AOA_VS_CL_CD(3,:);
polyArray_CL=CubicIn(AOA_list,CL_list);
polyArray_CD=CubicIn(AOA_list,CD_list);

%use meshgrid to turn 1D array to matrix(R,section_chord,azimuth_angle(psi)
[sth,section_chord]=meshgrid(psi,section_chord);
[psi,R]=meshgrid(psi,R);

D=5;%set the initial difference
while D>2
    %this nested loop is to create 200x360 array as both the blade section are divided by R_cut and
    %the azimuth angle are divided into psi_cut pieces 
    %i represents sections and j represents azimuth angle so one row gets
    %value for differnet sections but same azimuth angle and one column
    %represents different azimuth angles but same section.
    %calculate the velocity normal to disc W
    %need condition to do calculation
    for i=1:R_cut
        for j=1:psi_cut
            if Winf<=0
                W=Winf/2-1/2*sqrt(Winf^2+8*Fn_init/(pi*density*D^2));
            elseif Winf >sqrt(8*Fn_init/(density*pi*D^2))
                W=Winf/2+1/2*sqrt(Winf^2-8*Fn_init/(pi*density*D^2));
            else
                disp('No analytical solution.');
                break
            end
            VT(i,j)=angular_velocity*R(i,j)+Vinf*sin(psi(i,j));%to calculate tangential velocity
            Ve(i,j)=(VT(i,j)^2+W^2)^0.5;%to calculate downward velocity;
            deltaA(i,j)=atan(W/VT(i,j));
            ae(i,j)=(ic+(R(i,j)-R0)*twist/(D/2-R0)+deltaA(i,j))*360/(2*pi);%to calculate angle of attack(use degree)
            CL(i,j)=cubicEval(AOA_list,polyArray_CL,ae(i,j));
            CD(i,j)=cubicEval(AOA_list,polyArray_CD,ae(i,j));%use function created before to find corresponding CD and CL
        end
    end
    d_Fn=N*(0.5*density*Ve.^2).*section_chord.*(CL.*cos(deltaA)+CD.*sin(deltaA))./(2*pi);
    Fn=trapz(psi(1,:),trapz(R(:,1),d_Fn));
    D=abs(Fn-Fn_init);
    Fn_init=Fn;
end

%use trapz function of calculate double integrals
%calculate total thrust of the rotor disc
%fitsr integrate by Radius then by psi

d_Fx=N*(0.5*density*Ve.^2).*section_chord.*(CD.*cos(deltaA)+CL.*sin(deltaA)).*sin(psi)./(2*pi);
Fx=trapz(psi(1,:),trapz(R(:,1),d_Fx));

d_Fy=-N*(0.5*density*Ve.^2).*section_chord.*(CD.*cos(deltaA)+CL.*sin(deltaA)).*cos(psi)./(2*pi);
Fy=trapz(psi(1,:),trapz(R(:,1),d_Fy));

d_T=N*(0.5*density*Ve.^2).*section_chord.*(CD.*cos(deltaA)+CL.*sin(deltaA)).*R./(2*pi);
T=trapz(psi(1,:),trapz(R(:,1),d_T));

%calculate diving power
P=T*angular_velocity;

%calculate pitching and rolling moments
d_Mx=-N*(0.5*density*Ve.^2).*section_chord.*(CL.*cos(deltaA)+CD.*sin(deltaA)).*R.*cos(psi)./(2*pi);
Mx=trapz(psi(1,:),trapz(R(:,1),d_Mx));

d_My=-N*(0.5*density*Ve.^2).*section_chord.*(CD.*cos(deltaA)+CL.*sin(deltaA)).*R.*sin(psi)./(2*pi);
My=trapz(psi(1,:),trapz(R(:,1),d_My));

%all values are worked out

disp(['The total thrust is',num2str(Fn),'N']);

disp(['The drag force is ',num2str(Fx),'N']);

disp(['The side force is',num2str(Fy),'N']);

disp(['The moment about the rotor hub is',num2str(Fn),'Nm']);

disp(['Average pitching moment is ',num2str(Mx),'Nm']);

disp(['Average rolling moment is',num2str(My),'Nm']);

disp(['The average power to drive the rotor is',num2str(P),'W']);

