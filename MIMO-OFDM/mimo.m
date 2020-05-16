DATAL = 1e4;

rayChan1 = comm.RayleighChannel('SampleRate', 1e3, 'MaximumDopplerShift', 100, ...
    'DopplerSpectrum', doppler('Flat'));
rayChan2 = comm.RayleighChannel('SampleRate', 1e3, 'MaximumDopplerShift', 10, ...
    'DopplerSpectrum', doppler('Flat'));
riceChan = comm.RicianChannel('SampleRate', 1e3, 'MaximumDopplerShift', 100);

uvec = ones(DATAL,1);
chan1 = [rayChan1(uvec)'; rayChan1(uvec)'; rayChan1(uvec)'; rayChan1(uvec)'];
chan2 = [rayChan2(uvec)'; rayChan2(uvec)'; rayChan2(uvec)'; rayChan2(uvec)'];
chan3 = [riceChan(uvec)'; riceChan(uvec)'; riceChan(uvec)'; riceChan(uvec)'];
plot(1:100, abs(chan1(:, 1:100)));

%% Pre-Coding
M = 16;
data = randi([0 M-1], 2, DATAL);
datamod = qammod(data,M);

chan1pre = pre_code(datamod, chan1);
rx1 = transmit(chan1pre, chan1);
rec1 = qamdemod(rx1,M);
sum(sum(data ~= rec1))/DATAL
scatterplot(rx1(1,:))

chan2pre = pre_code(datamod, chan2);
rx2 = transmit(chan2pre, chan2);
rec2 = qamdemod(rx2,M);
sum(sum(data ~= rec2))/DATAL
scatterplot(rx2(1,:))

chan3pre = pre_code(datamod, chan3);
rx3 = transmit(chan3pre, chan3);
rec3 = qamdemod(rx3,M);
sum(sum(data ~= rec3))/DATAL
scatterplot(rx3(1,:))

%% Zero Forcing

M = 4;
data = randi([0 M-1], 2, DATAL);
datamod = qammod(data,M);

rx1 = transmit(datamod, chan1);
zf1 = zero_forcing(rx1, chan1);
rec1 = qamdemod(zf1, 4);
sum(sum(rec1 ~= data))/DATAL
scatterplot(zf1(1,:));

rx2 = transmit(datamod, chan2);
zf2 = zero_forcing(rx2, chan2);
rec2 = qamdemod(zf2, 4);
sum(sum(rec2 ~= data))/DATAL
scatterplot(zf2(1,:));

rx3 = transmit(datamod, chan3);
zf3 = zero_forcing(rx3, chan3);
rec3 = qamdemod(zf3, 4);
sum(sum(rec3 ~= data))/DATAL
scatterplot(zf3(1,:));

%% MMSE
M = 4;
data = randi([0 M-1], 2, DATAL);
datamod = qammod(data,M);

rx1 = transmit(datamod, chan1);
zf1 = mmse(rx1, chan1, .01);
rec1 = qamdemod(zf1, 4);
sum(sum(rec1 ~= data))/DATAL
scatterplot(zf1(1,:));

rx2 = transmit(datamod, chan2);
zf2 = mmse(rx2, chan2, .01);
rec2 = qamdemod(zf2, 4);
sum(sum(rec2 ~= data))/DATAL
scatterplot(zf2(1,:));

rx3 = transmit(datamod, chan3);
zf3 = mmse(rx3, chan3, .01);
rec3 = qamdemod(zf3, 4);
sum(sum(rec3 ~= data))/DATAL
scatterplot(zf3(1,:));

%%

function rx = transmit(sig, chan) 
    sig1 = sig(1,:) .* chan(1,:) + sig(2,:) .* chan(2,:); 
    sig2 = sig(1,:) .* chan(3,:) + sig(2,:) .* chan(4,:); 

    pow = -10;
    %n1 = awgn(sig1, SNR, 'measured');
    %n2 = awgn(sig2, SNR, 'measured');
    n1 = sig1 + wgn(1,length(sig),pow, 'complex');
    n2 = sig2 + wgn(1,length(sig),pow, 'complex');
    rx = [n1;n2];
end

function tx_sym = pre_code(dataenc, chan)
    tx_sym = zeros(size(dataenc));
    H = zeros(2);
    tic
    for i = 1:length(dataenc)
        H = [chan(1,i), chan(2,i); chan(3,i), chan(4,i)];
        W = inv(H);
        tx_sym(:,i) = W * dataenc(:,i);
        if floor(i/1000) == i/1000
            i;
        end
    end
    toc
end

function rx_sym = zero_forcing(rx_sig, chan) 
    rx_sym = zeros(size(rx_sig));
    H = zeros(2);
    for i = 1:length(rx_sig)
        H = [chan(1,i), chan(2,i); chan(3,i), chan(4,i)];
        %W = inv(H' * H) * H';
        W = inv(H);
        rx_sym(:,i) = W * [rx_sig(1,i); rx_sig(2,i)];
        if floor(i/1000) == i/1000
            i;
        end
    end
end

function rx_sym = mmse(rx_sig, chan, lambda) 
    rx_sym = zeros(size(rx_sig));
    H = zeros(2);
    %lambda = 0.5
    for i = 1:length(rx_sig)
        H = [chan(1,i), chan(2,i); chan(3,i), chan(4,i)];
        W = inv(H' * H + lambda * eye(2)) * H';
        rx_sym(:,i) = W * [rx_sig(1,i); rx_sig(2,i)];
        if floor(i/1000) == i/1000
            i;
        end
    end
end