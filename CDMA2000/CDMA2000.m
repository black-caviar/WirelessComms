%% CDMA2000 X1 Voice Channel Simulation
PNI = 'x^15 + x^13 + x^9 + x^8 + x^7 + x^5 + 1'
PNQ = 'x^15 + x^12 + x^11 + x^10 + x^6 + x^5 + x^4 + x^3 + 1'
PNI1 = [15, 13, 9, 8, 7, 5, 0]

pnSI1 = comm.PNSequence('Polynomial', PNI, 'InitialConditions', 1, 'SamplesPerFrame', 2^15-1, 'MaskSource', 'Input Port')
% pnSI2 = cinioinimm.PNSequence('Polynomial', PNI1)

%x1 = pnSI1();
%x2 = psSI2();

seq1 = comm.PNSequence('Polynomial', [3,2,0],'InitialConditions', [0,0,1], 'SamplesPerFrame', 7, 'MaskSource', 'Input Port')
seq2 = comm.PNSequence('Polynomial', [3,2,0],'InitialConditions', 1, 'SamplesPerFrame', 7, 'MaskSource', 'Input Port')

PNIGEN = comm.PNSequence('Polynomial', PNI, 'InitialConditions', 1, 'SamplesPerFrame', 2^15-1, 'MaskSource', 'Input Port');
PNQGEN = comm.PNSequence('Polynomial', PNQ, 'InitialConditions', 1, 'SamplesPerFrame', 2^15-1, 'MaskSource', 'Input Port');

PNISEQ = PNIGEN(de2bi(1,15));
PNQSEQ = PNQGEN(de2bi(1,15)); 

SPNSEQ = [PNISEQ, PNQSEQ];


%%
zCount = 0;
zCountQ = 0;
for i = 1:length(SPNSEQ) 
    if (PNISEQ(i) == 0)
        zCountI = zCountI + 1;
    else 
        zCountI = 0;
    end
    
    if (PNQSEQ(i) == 0)
        zCountQ = zCountQ + 1;
    else 
        zCountQ = 0;
    end
    
    if (zCountI == 14)
        disp 'found it 1'
        disp(i)
        PNISEQ = [PNISEQ(1:i-1); 0; PNISEQ(i:end)];
    end
    
    if (zCountQ == 14)
        disp 'found it 2'
        disp(i)
        PNQSEQ = [PNQSEQ(1:i-1); 0; PNQSEQ(i:end)];
    end
end


%% Long PN Sequence 
PNL = [42, 35, 33, 31, 27, 26, 25, 22, 21, 19, 18, 17, 16, 10, 7, 6, 5, 3, 2, 1, 0];


%%

%Walsh = comm.WalshCode('Length', 64, 'Index', 1, 'SamplesPerFrame', 64);
%useless 

W = hadamard(64);

W(1,:)

%%
%Generate and encode the pilot channel sequence go


