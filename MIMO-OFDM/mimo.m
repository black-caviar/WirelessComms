DATAL = 1e6;

rayChan = comm.RayleighChannel('SampleRate', 1e6, 'MaximumDopplerShift', 100, ...
    'DopplerSpectrum', doppler('Flat'));
%'Visualization', 'Frequency response',
%'NumTransmitAntennas', 2);
%doppFlat = doppler('Flat');
%rayChan.DopplerSpectrum = doppFlat;
%rayChan.DopplerSpectrum
%%
mimoChan = comm.MIMOChannel('SampleRate', 1e6, 'MaximumDopplerShift', 100, ...
    'DopplerSpectrum', doppler('Flat'), 'PathGainsOutputPort', true)

%%
uvec = ones(DATAL,1);
ray1 = [rayChan(uvec)'; rayChan(uvec)'; rayChan(uvec)'; rayChan(uvec)';];
plot(1:100000, abs(ray1(:, 1:100000)));

ray2 = rayChan(uvec)';

%% Zero Forcing
data = randi([0 3], 2, DATAL);
dataenc = qammod(data,4);

sig1 = dataenc(1,:) .* ray1(1,:) + dataenc(2,:) .* ray1(2,:); 
sig2 = dataenc(1,:) .* ray1(3,:) + dataenc(2,:) .* ray1(4,:); 

rx1 = awgn(sig1, 200);
rx2 = awgn(sig2, 200);

[sig, pathgain] = mimoChan(dataenc');
rx = awgn(sig, 200)';
%% This clearly works and is horrible slow
rx_sym = zeros(size(dataenc));
for i = 1:DATAL
    H = [ray1(1,i), ray1(2,i); ray1(3,i), ray1(4,i)];
    %HH = inv(H);
    HH = inv(H' * H) * H';
    rx_sym(:,i) = HH * [rx1(i); rx2(i)];
    i
end
%%
rx_sym = zeros(size(dataenc));
H = zeros(4,4);
for ii = 1:DATAL
    H = squeeze(pathgain(ii,1,:,:));
    W = inv(H' * H) * H';
    rx_sym(:,ii) = W * rx(:,ii);
    ii
end
rx_data = qamdemod(rx_sym, 4);
isequal(rx_data, data)
%%



%%
rx_data = spaceTimeDec([rx1;rx2], ray1);

%%
%chan = [1 .2 .4]
%tran = filter(1, chan, data);
rx = tx .* ray1;
zf = rx ./ ray1;

isequal(data, qamdemod(zf,4))

