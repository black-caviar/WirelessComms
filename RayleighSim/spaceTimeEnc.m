function tran = spaceTimeEnc(signal, order)
    % Split signal into symbol sets 
    s0 = signal(1:2:end);
    s1 = signal(2:2:end);

    ant0 = zeros(size(signal)); % contents at antenna 0
    ant1 = zeros(size(signal)); % contents at antenna 1

    ant0(1:2:end) = s0;
    ant0(2:2:end) = -1 * conj(s1);

    ant1(1:2:end) = s1;
    ant1(2:2:end) = conj(s0); 

    tran = [ant0; ant1];
end