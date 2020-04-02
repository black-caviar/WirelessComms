%clear all; close all; clc

load('Rcvd_Teplitskiy.mat');
PN = [8 7 6 1 0];
B_RCOS = [0.0038 0.0052 -0.0044 -0.0121 -0.0023 0.0143 0.0044 -0.0385 ...
    -0.0563 0.0363 0.2554 0.4968 0.6025 0.4968 0.2554 0.0363 -0.0563 ...
    -0.0385 0.0044 0.0143 -0.0023 -0.0121 -0.0044 0.0052 0.0038];


%PN = 'x^8 + x^7 + x^6 + 1'
PNGEN = comm.PNSequence('Polynomial', PN, 'InitialConditions', 1, ...
    'SamplesPerFrame', 2^8-1, 'Mask', de2bi(1,8));
PNSEQ = PNGEN();
oPN = zeros(1, 4*length(PNSEQ));
oPN(1:4:end) = pskmod(PNSEQ,2);
%bpPN = rectpulse(pskmod(PNSEQ, 2), 4);

%oPN = rectpulse(PNSEQ, 4);

rx = filter(B_RCOS, 1, Rcvd);

%pcorr = correlate(oPN, real(rx'));
%pcorr = correlate(rectpulse(bpPN,4), rx');
%plot(real(conv(flip(oPN), rx')))
%figure; plot([1:1020], pcorr);
mycorr = abs(xcorr(oPN, rx'));
mycorr = filter(fliplr(oPN), 1, rx);
figure; plot([1:16000], 20*log10(mycorr(1:16000)));
ylim([0,50]);
[m,ind] = max(mycorr)

H = hadamard(8);

%%

%pnShift = round(-mod(ind, 1020)/4);
pnShift = -144;
rxds = rx(1:4:end);

rxPN = pskmod(circshift(PNSEQ, pnShift),2);

pcorr = correlate(rxPN, rxds');
%pcorr = correlate(rectpulse(bpPN,4), rx');

%figure; plot(abs(pcorr));
ncorr = abs(xcorr(rxPN, rxds));
%figure; plot(ncorr);

%figure;
%scatterplot(rx);

%rxDEPN = repmat(circshift(bpPN, ind), length(rx)/length(bpPN), 1)' .* rx;


%pnbp = pskmod(rxPN, 2);
rxdec = rxds .* repmat(rxPN', 1, length(rxds)/length(rxPN));
rxframe = reshape(rxdec, 255, []);
rxtrim = rxframe(7:192+6,:);
%plot(abs(xcorr(rxPN', rxdec)));
pilot = intdump(rxtrim, 8);
scatterplot(pilot(:,1));
scatterplot(mean(pilot));
adj = 1./mean(pilot);
unphased = rxtrim .* adj;
%scatterplot(unphased(:,10));

charsegs = reshape(unphased, 64, {});
walshchars = repmat(H(6,:)',8,1) .* (charsegs-1);

chars = intdump(walshchars, 8);
blanks = mean(abs(chars)) < .5; 
chars(:,blanks) = 0;
%chars(:,1:3) = 0;
char(bi2de(pskdemod(chars, 2)'))'


%%
close all;
f = 31 * 2 * pi;
%f = 20 * 2 * pi;
t = linspace(0, length(Rcvd)/1e6, length(Rcvd));
s = sin(f * t + 13*(2*pi)/99);
%13

carrSync = comm.CarrierSynchronizer('Modulation', 'BPSK');
syncSig = carrSync(Rcvd');

figure; plot(real(xcorr(rxPN, rx')));
hold on;
plot(s*420);
hold off;

figure; plot(real(xcorr(rxPN, syncSig)));

new = filter(B_RCOS, 1, Rcvd .* s);
figure; plot(real(xcorr(rxPN, new')));
scatterplot(new);

data1 = qamdemod(codeCC(syncSig, H(6,:)'),2);
data2 = qamdemod(codeCC(new', H(6,:)'),2);

H = hadamard(8);
%%
vars = zeros(1,300);
for i = 0:299
    f = i * 0.1 + 20;
    s = sin(f * t);
    new = filter(B_RCOS, 1, Rcvd .* s);
    vars(i+1) = var(real(new));
end
figure; plot(vars);
%%

vars = zeros(1,100);
for i = 0:99
    p = i * 2*pi/99;
    s = sin(f * t + p);
    new = filter(B_RCOS, 1, Rcvd .* s);
    vars(i+1) = var(imag(new));
end
figure; plot(vars);


%%
junk = randi([0,1],1,1000);
enc = pskmod(junk, 2);
rx = awgn(enc, 20);
scatterplot(rx);

function rate = correlate(ref, test)
    
    rate = zeros(size(ref));
    for i = 1:length(ref)
        shift = circshift(ref,i);
        rate(i,:) = sum(shift.*test(1:length(ref),:));
    end

end