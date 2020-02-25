PNL = [42, 35, 33, 31, 27, 26, 25, 22, 21, 19, 18, 17, 16, 10, 7, 6, 5, 3, 2, 1, 0];
PNLGEN = comm.PNSequence('Polynomial', PNL, 'InitialConditions', 1, 'SamplesPerFrame', 2^31-1, ...
    'MaskSource', 'Input Port', 'BitPackedOutput', true, 'NumPackedBits', 32);

%PNLGEN = comm.PNSequence('Polynomial', PNL, 'InitialConditions', 1, 'SamplesPerFrame', 2^31-1, ...
%    'MaskSource', 'Input Port', 'OutputDataType', 'Smallest unsigned integer');

PNLSEQ = PNLGEN(de2bi(1,42));
PNLSEQ2 = PNLGEN(de2bi(1,42));f