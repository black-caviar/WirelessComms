%% ChannelSim 
close all; clear all; clc;

N = 2^20;

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

Sef = Se(f,fm,fc);
Sef(end) = Sef(end-1) + diff(Sef(end-2:end-1));
Sef(1) = Sef(2) - diff(Sef(2:3));

plot(Sef);10.1109/49.730453
%figure;
% corrected Se function
Sefs = sqrt(Sef);

% This should be square root
S0 = Sefs .* n0;
S1 = Sefs .* n1;

%S0 = Sefs * 500;
%S1 = Sefs * 500;

%t = zeros(size(n0)) + 1;
%plot(Se(f,fm,fc));

%figure;
%plot(abs(n0));
%figure;
%plot(abs(S0));

% The problem is the presence of infinity at the extremes of Se
% Not sure if formula is adjusted correctly, looks waay too steep
% Check if plot is logarithmic
% Find way to solve infinity issue 

s0 = ifft(S0);
s1 = ifft(S1);

net = s0.^2 + (s1*1j).^2;
sig = sqrt(net);

figure;
plot(abs(sig))

