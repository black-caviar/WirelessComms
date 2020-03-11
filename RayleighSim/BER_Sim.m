%% BER Performance Comparison of Space-Time Block Codes 
clear all; close all; clc;

SNR_Vec = 0:2:50;
BER_Vec = zeros(2, length(SNR_Vec));

N = 2^20;
data = randi([0,1], 1, N);
tran = pskmod(data, 2);

RayleighNoise0 = rectpulse(genRayChan(N/2, 120, 2.4e9), 2);
RayleighNoise1 = rectpulse(genRayChan(N/2, 120, 2.4e9), 2);
% Assure that Rayleigh channel conditions do not change in between symbol
% pairs 

for i = 1:length(SNR_Vec)     
    rx = awgn(tran .* RayleighNoise1 * 2, 2*SNR_Vec(i));
    rx_data = pskdemod(rx, 2);
    BER_Vec(1,i) = sum(rx_data ~= data)/N;
end

adata = spaceTimeEnc(tran);

for i = 1:length(SNR_Vec)  
    sig0 = adata(1,:) .* RayleighNoise0 * 2;
    sig1 = adata(2,:) .* RayleighNoise1 * 2;
    rx = awgn(sig0 + sig1, 2*SNR_Vec(i));
    rx_dec = spaceTimeDec(rx);
    rx_data = pskdemod(rx_dec, 2);
    BER_Vec(2,i) = sum(rx_data ~= data)/N;
end

semilogy(SNR_Vec, BER_Vec(1,:));
hold on;
semilogy(SNR_Vec, BER_Vec(2,:));
legend('No diversity', 'Alamouti 2x1');
xlim([0, 50]);
ylim([1e-6, 1]);