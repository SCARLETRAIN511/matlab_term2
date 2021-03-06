
clc
clear
%assume lambda = 1, m = 3

deltaXMatrix = [1/10,1/20,1/50,1/100,1/200,1/500];
epsilonDirect = zeros(6,1);
for x = 1:length(deltaXMatrix)
clear vars u fMatrix
deltaX = deltaXMatrix(x);
mdx = 0:deltaX:1;
%number of points
N = 1./deltaX + 1;

%abc for ui+1,ui,ui-1;
aCoeff = 1;
bCoeff = -2-deltaX.^2;
cCoeff = 1;

a = zeros(N-2,1);
c = zeros(N-2,1);
a(1:N-2) = aCoeff;
c(1:N-2) = cCoeff;
b = ones(N-2,1)*bCoeff;

%matrix for m
fMatrix(:,1) = deltaX.^2*(-9*pi^2-1).*sin(3.*pi.*mdx(2:N-1));
% 
% beta = zeros(N-2,1);
% gamma = zeros(N-2,1);
% 
% %forward
% beta(1) = b(1);
% gamma(1) = fMatrix(1)./beta(1);
% for k = 2:N-2
%     beta(k) = b(k)-a(k)*c(k-1)/beta(k-1);
%     gamma(k) = (-a(k)*gamma(k-1)+fMatrix(k))/beta(k);
% end
%intergrate using function to represent forward algorithms
[gamma,beta] = forward(a,b,c,fMatrix,N);

%backward
%last 2 is zero
u = zeros(N-2,1);
u(N-2) = gamma(N-2);
for k = (N-3):-1:1
    u(k) = gamma(k) - u(k+1)*c(k)/beta(k);
end
u = [0;u;0];

%plot
figure()
plot(mdx,u,'--r');
hold on 
plot(mdx,sin(3.*pi.*mdx),'-g');
grid on
legend('Predicted','Actual');
hold off

%calculate the theoretical values
ubar = transpose(sin(3*pi*mdx));
epsilon = max(abs(u-ubar));
epsilonDirect(x) = epsilon;
fprintf('The maximum epsilon of direct is %3.5f\n',epsilon);

end

figure(10);
plot(log10(deltaXMatrix),log10(epsilonDirect));

%% functions
function [gamma,beta] = forward(a,b,c,fMatrix,N)
beta = zeros(N-2,1);
gamma = zeros(N-2,1);

%forward
beta(1) = b(1);
gamma(1) = fMatrix(1)./beta(1);
for k = 2:N-2
    beta(k) = b(k)-a(k)*c(k-1)/beta(k-1);
    gamma(k) = (-a(k)*gamma(k-1)+fMatrix(k))/beta(k);
end

end

