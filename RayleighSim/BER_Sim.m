%% BER Performance Comparison of Space-Time Block Codes 
clear all; close all; clc;

SNR_Vec = 0:2:50;
BER_Vec = zeros(size(SNR_Vec));

N = 2^24;
data = randi([0,1], 1, N);
tran = pskmod(data, 2);

RayleighNoise = genRayChan(N, 120, 2.4e9);

for i = 1:length(SNR_Vec)  
    %tx_ray = tran .* RayleighNoise;
    %rx = awgn(tran, SNR_Vec(i), 1);
    %rx = tran .* RayleighNoise;
    %rx = awgn(tran, SNR_Vec(i));
    
    rx = awgn(tran .* RayleighNoise * 2, 2*SNR_Vec(i));
    
    rx_data = pskdemod(rx, 2);
    BER_Vec(i) = sum(rx_data ~= data)/N;
end

semilogy(SNR_Vec, BER_Vec);
hold on;
xlim([0, 50]);
ylim([1e-6, 1]);