%plot nyquist diagram
clear
clc

s=tf('s');
sys=(1)/(s^2+2*s+1);
% sys = tf(num,den);
syms x;
fx=(x-1)*(x-4)/((x+1)*(x+4));
ans = diff(fx);
pretty(ans)


figure(1)
nyquist(sys);
figure(2)
rlocus(sys);
% figure(3)
% bode(sys);
