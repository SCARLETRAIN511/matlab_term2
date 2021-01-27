%cfd coursework2
%author:Jiaxuan Tang 22/01/2021

clc
clear
close all;

gamma = 1.4;
xBegin = -2;
xEnd = 2;
%set the space
N = 100;

%initial condition
denRatio = 8;
preRatio = 10;
deltaX = 4/100;
dX = [-2:deltaX:2];
deltaT = 0.05;
dT = [0:deltaT:0.5];

%u0 = u1
rho = ones(1,length(dX));
rho(:,floor(length(rho)/2):length(rho)) = denRatio;
pressure = ones(1,length(dX));
pressure(:,floor(length(pressure)/2):length(pressure)) = preRatio;
u = zeros(1,length(dX));
entropy=log(pressure./(rho.^1.4));
BigU = [rho;rho.*u;rho.*entropy];

for n = 1:length(dT)
    for i = 1:length(dX)
        %initial value of u is 0;        
        mA = getMatrixA(u(i),entropy(i));
        eigValue(:,i) = eig(mA);
        %from eig to get F+ F-
        %get F+;
        %get F-;
    end
   %get the new Bigu
    for i2 = 2:length(dX)-1 
        %BigU n+1 = BigU n + fun(F+,F-);
        BigU(:,i2) = BigU(:,i2) - deltaT/deltaX(FPlus(:,i2)-FPlus(:,i2-1)+(FMinus(i2+1)-fMinus(i2)));
        %update the big U
    end
    
    %get from U2 to Un-1, U2 = U1,Un = Un-1
    BigU(:,1) = BigU(:,2);
    BigU(:,length(dX)) = BigU(:,length(dX)-1); 
    %from BigU n +1,get new rho,v,pressure
    
    for i3 = 1:length(dX)
        rho(i3) = BigU(1,i3);
        u(i3) = BigU(2,i3)/BigU(1,i3);
        entropy(i3) = BigU(3,i3)/BigU(1,i3);
        pressure(i3) = 0.4*rho(i3)*rho*(entropy(i3)-u(i3).^2/2);
    end
end


%functions
function matrixA = getMatrixA(u,entropy)
    matrixA = [0,1,0;
        -1.6*u^2/2,1.6*u,0.4;
        0.4*u^3-1.4*u*entropy,1.4*entropy-3*0.2*u^2,1.4*u];
end



