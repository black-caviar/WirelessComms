%% Generate Rayleigh channel 
function ray = genRayChan(N, v, fc)
    % Find maximum doppeler frequency 
    fm = v/299792458 * fc;
    f = linspace(-fm, fm, N) + fc;
    
    % Generate complex Gaussian random variables 
    X0 = randn(1,N/2) + 1j*randn(1,N/2);
    X1 = randn(1,N/2) + 1j*randn(1,N/2);
    
    % Constructsig negative frequency components
    n0 = [flip(conj(X0)),X0];
    n1 = [flip(conj(X1)),X1];
    
    % -fc just takes is back to baseband
    Se = 1.5 ./ (pi * fm * sqrt(1 - ((f-fc)/fm).^2));
    % Correct infinities at extremes of Se using Smith's method
    Se(end) = Se(end-1) + diff(Se(end-2:end-1));
    Se(1) = Se(2) - diff(Se(2:3));
    Ses = sqrt(Se);
    
    % Shape quadrature noise sources
    S0 = Ses .* n0;
    S1 = Ses .* n1;
    
    % Convert to noise signal tx(1,:) .* noise1 
    s0 = ifft(S0);
    s1 = ifft(S1);
    
    % Sum quadrature noise sources 
    net = s0.^2 + (s1*1j).^2;
    
    qnet = sqrt(net);
    %ray = qnet;
    
    %mean(abs(qnet))
    
    % Normalize power to 1
    norm = modnorm(qnet, 'avpow', 1);
    
    % Rayleigh Time varying channel 
    ray = qnet * norm;    
    
    %figure; plot([1:70], abs(ray(1:70)));
    %title("Rayleigh Fading Signal Portion");
end