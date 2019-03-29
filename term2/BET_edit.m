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
%use loop to fscanf 1 value each time
for i=1:68
    for j=1:3
        AOA_VS_CL_CD(i,j)=fscanf(fid,'%e',1);
    end
end
%warning: the data in AOA_VS_CL_CD about angle of attack is in unit of
%degree so when calculating angle of attack below, you should also use
%degree


N=4;%blade numbers
D=16.36;%diameter of the blade
R0=1.55;
Croot=0.53;
Ctip=0.53;
E=-18;%degree linear blade twist
angular_velocity=27;%rads s^-1
density=1.12;%density of air
cut=200;
azimuth_angle=0:pi/100:(2*pi-pi/100);

ic=input('input the blade setting angle');%get the blade setting angle input will be radian
Vinf=input('input the forward airspeed');%forwad speed
Winf=input('input the rate of descent');
twist=input('input the twist of the blade')*2*pi/360;%input will be degree so turn in to radian



%caluculate the local chord for each small section and the positions of
%them
for i=1:200
    section_chord(i)=Croot+(Ctip-Croot)*i/200;%the width for each small pieces
    R(i)=R0+(D/2-R0)*i/200;%Distance from center, value of R
end
FN=0;


%calculate the velocity normal to disc W
%need condition to do calculation
if Winf<=0
    W=Winf/2-1/2*sqrt(Winf^2+8*FN/(pi*density*D^2));
elseif Winf >sqrt(8*FN/(density*pi*D^2))
    W=Winf/2+1/2*sqrt(Winf^2-8*FN/(pi*density*D^2));
else
    disp('No analytical solution.');
end


% use cubic spline to calculate corresponding value of CL and CD specific
% angle of attack
CL=[];%initiate lift coefficient
CD=[];%initiate dray coefficient
AOA_list=AOA_VS_CL_CD(:,1);
CL_list=AOA_VS_CL_CD(:,2);
CD_list=AOA_VS_CL_CD(:,3);
polyArray_CL=CubicIn(AOA_list,CL_list);
polyArray_CD=CubicIn(AOA_list,CD_list);
%still need to use nested loop to calculate CL and CD for different
%azimuth_angle.


%this nested loop is to create 200x200 array as both the blade section and
%the azimuth angle are divided into 200 pieces and 
%i represents sections and j represents azimuth angle so one row gets
%value for differnet sections but same azimuth angle and one column
%represents different azimuth angles but same section.
for i=1:200
    for j=1:200
        VT(i,j)=angular_velocity*R(j)+Vinf*sin(azimuth_angle(i));%to calculate tangential velocity
        Ve(i,j)=(VT(i,j)^2+W^2)^0.5;%to calculate downward velocity;
        deltaA(i,j)=atan(W./VT(i,j));
        ae(i,j)=(ic+(R(j)-R0)*twist/(D/2-R0)+deltaA(i,j))*360/(2*pi);%to calculate angle of attack(use degree)
        CL(i,j)=cubicEval(AOA_list,polyArray_CL,ae(i,j));
        CD(i,j)=cubicEval(AOA_list,polyArray_CD,ae(i,j));%use function created before to find corresponding CD and CL
    end
end


%use trapz function of calculate double integrals
%calculate total thrust of the rotor disc
%fitsr integrate by Radius then by psi
d_Fn=N*(0.5*density*Ve.^2).*section_chord.*(CL.*cos(deltaA)+CD.*sin(deltaA))./(2*pi);
Fn=trapz(azimuth_angle,trapz(R,d_Fn));

d_Fx=N*(0.5*density*Ve.^2).*section_chord.*(CD.*cos(deltaA)+CL.*sin(deltaA)).*sin(azimuth_angle)./(2*pi);
Fx=trapz(azimuth_angle,trapz(R,d_Fx));

d_Fy=-N*(0.5*density*Ve.^2).*section_chord.*(CD.*cos(deltaA)+CL.*sin(deltaA)).*cos(azimuth_angle)./(2*pi);
Fy=trapz(azimuth_angle,trapz(R,d_Fy));

d_T=N*(0.5*density*Ve.^2).*section_chord.*(CD.*cos(deltaA)+CL.*sin(deltaA)).*R./(2*pi);
T=trapz(azimuth_angle,trapz(R,d_T));

%calculate diving power
P=T*angular_velocity;

%calculate pitching and rolling moments
d_Mx=-N*(0.5*density*Ve.^2).*section_chord.*(CL.*cos(deltaA)+CD.*sin(deltaA)).*R.*cos(azimuth_angle)./(2*pi);
Mx=trapz(azimuth_angle,trapz(R,d_Mx));

d_My=-N*(0.5*density*Ve.^2).*section_chord.*(CD.*cos(deltaA)+CL.*sin(deltaA)).*R.*sin(azimuth_angle)./(2*pi);
My=trapz(azimuth_angle,trapz(R,d_My));

%all values are worked out

disp(['The total thrust is',num2str(Fn),'N']);

disp(['The drag force is ',num2str(Fx),'N']);

disp(['The side force is',num2str(Fy),'N']);

disp(['The moment about the rotor hub is',num2str(Fn),'Nm']);

disp(['Average pitching moment is ',num2str(Mx),'Nm']);

disp(['Average rolling moment is',num2str(My),'Nm']);

disp(['The average power to drive the rotor is',num2str(P),'W']);
