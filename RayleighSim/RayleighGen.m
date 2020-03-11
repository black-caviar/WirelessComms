%% ChannelSim 

N = 2^10;

fc = 1e9;

fm = 100/299792458 * fc;

fc = 0
fm = 500;

Se = @(f,fm,fc) 1.5./(pi * fm * sqrt(1 - ((f-fc)/fm).^2));

df = 2*fm/(N-1);     
f = linspace(-fm, fm, N) + fc;

X0 = randn(1,N/2) + 1j*randn(1,N/2);
X1 = randn(1,N/2) + 1j*randn(1,N/2);

n0 = [conj(X0),X0];
n1 = [conj(X1),X1];

S0 = Se(f, fm, fc) .* n0;
S1 = Se(f, fm, fc) .* n1;

%t = zeros(size(n0)) + 1;
plot(Se(f,fm,fc));

%plot(abs(n0));

s0 = ifft(S0);
s1 = ifft(S1);

net = s0.^2 + (s1*1j).^2;
sig = sqrt(net);

plot(sig)

