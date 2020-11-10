%avd u/c calculation
%for main u/c 4 wheels per struct, nose gear 2 wheels

%3 structs total

%Assume the tire pressure
tirePressure = 10;%kg/cm2

%% place the u/c
heightOfCg = input("Type the height of the Center of gravity");%m
Xcg = input("Type the pos of the CG");
W0 = 146e3;%kg

Xng = input("type the pos of the nose gear");
Xmg = input("type the pos of the main gear");

SolveX = [1,1;Xng,Xmg];
SolveY = [W0;W0*Xcg];
Ans = SolveX^(-1) * SolveY;
Wmg = Ans(2);
Wng = Ans(1);

%now check the 6'' clearence
%% check the tip back angle
totalLength = input("type the total length of the a/c");
tipBackAngle = atan(heightOfCg/(totalLength - Xmg));
willTipBack = false;
if (atan((Xmg - Xcg)/heightOfCg) > tipBackAngle)
    willTipBack = true;
end

%% check overturn
PosNgMg = Xmg - Xng;
Ymg = input("type the y pos of the main gear");
angle1 = atan(Ymg/(Xmg - Xcg));
staticGroundLine = (Xcg - Xng)*sin(angle1);
overturnAngle = atan(heightOfCg/staticGroundLine);
willOverTurn = true;
if overturnAngle/pi*180 <= 63
    willOverTurn = false;
end





