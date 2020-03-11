%% Simulation of Rayleigh Fading Channel
%% Generate transmission

m = 2;
nSym = 1000;

s = pskmod([0:m-1], m);

data = randi([0,m-1], 1, nSym);
tran = pskmod(data, m);

s0 = tran(1:2:end);
s1 = tran(2:2:end);

ant0 = zeros(size(tran)); % contents at antenna 0
ant1 = zeros(size(tran)); % contents at antenna 1

ant0(1:2:end) = s0;
ant0(2:2:end) = -1 * conj(s1);

ant1(1:2:end) = s1;
ant1(2:2:end) = conj(s0); 

h0 = [.8, .5];
h1 = [.7, .3];

%r0 = awgn(filter(chan0,1,s0) + filter(chan1,1,s1), 10);
%r1 = awgn(filter(chan0,1,-1*conj(s1)) + filter(chan1,1,conj(s0)), 10);

r0 = ant0(1:2:end) + 0.9*ant1(1:2:end);
r1 = ant0(2:2:end) + 0.9*ant1(2:2:end);

ds0 = r0 + conj(r1);
ds1 = r0 - conj(r1);    

D = @(x,y) (x - y) .* (conj(x) - conj(y)); 

[d0, ps0] = min(D(ds0, s'));
[d1, ps1] = min(D(ds1, s'));

rs0 = s(ps0);
rs1 = s(ps1);

rec = zeros(size(data));
rec(1:2:end) = rs0;
rec(2:2:end) = rs1; 

recdat = pskdemod(rec, m);

for i = 1:4
    
end