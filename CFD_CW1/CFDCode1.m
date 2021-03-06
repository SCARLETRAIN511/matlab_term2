clc
clear

%1d
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
title('Graph using Thomas algorithms');
hold off

%calculate the theoretical values
ubar = transpose(sin(3*pi*mdx));
epsilondirect = max(abs(u-ubar));
epsilonDirect(x) = epsilondirect;
fprintf('The maximum epsilon of direct is %3.5f\n',epsilondirect);
end


%question 1e
deltaXMatrix = [1/10,1/20,1/50,1/100,1/200,1/500];
epsilonIter = zeros(6,1);
for x = 1:length(deltaXMatrix)
%assume lambda=1,m=3;
lambda = 1;
m = 3;
%differen intervals
deltaX = deltaXMatrix(x);

clear var b eps u r alpha
%calculate Numnber of mesh points
N = 1./deltaX + 1;
mdx = [0:deltaX:1];

%calculate B matrix
b = transpose(deltaX^2.*(-1-m^2*pi^2)*sin(3*pi*mdx(2:N-1)));

%calculate A matrix
A = zeros(N-2,N-2);
for i = 1:N-2
    A(i,i) = (-2-lambda*deltaX^2);
end
for i = 2:N-2
    A(i,i-1) = 1;
    A(i-1,i) = 1;
end

u = zeros(N-2,1);
eps = 1;
n=0;
while eps >= 10^(-7)
    n = n + 1;
    r(:,n) = b - A*u(:,n);
    alpha = (transpose(r(:,n))*r(:,n))/(transpose(r(:,n))*A*r(:,n));
    eps = sqrt((1/N)*sum(r(:,n).^2));
    u(:,n+1) = u(:,n) + alpha * r(:,n);
end

ubar = transpose(sin(3*pi*mdx));
ufinal = [0;u(:,length(u(1,:)));0];
epsiloniter = max(abs(ufinal-ubar));
epsilonIter(x) = epsiloniter;
fprintf('The maximum epsilon of iteration is %3.5f\n',epsiloniter);

figure
plot(mdx,ufinal,'--r');
%predicted values;
hold on 
plot(mdx,sin(3.*pi.*mdx),'-g');
grid on
hold on
legend('Predicted','Actual');
title('Graph using Iteration');
hold off
end

figure(13);
plot(log10(deltaXMatrix),log10(epsilonIter),'-b');
hold on
plot(log10(deltaXMatrix),log10(epsilonDirect),'or');
grid on
legend('EpsilonIterMax','EpsilonDirectMax');
xlabel("log(deltaX)");
ylabel("log(Epsilon)");
hold off


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

