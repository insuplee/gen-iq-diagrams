constDiagram = comm.ConstellationDiagram('ShowGrid', true);



% BPSK
n_psk = 4;
n_iq_imbal =0;
snr = 20;
n_samples = 128;

data = randi([0 n_psk-1],n_samples,1);
modData = pskmod(data,n_psk,pi/n_psk);



txSig = iqimbal(modData,n_iq_imbal);  % IQ imbalance, default 5
rxSig = awgn(txSig, snr);
%constDiagram(rxSig);

i = real(rxSig);
q = imag(rxSig);

sz = 0.1;
color = 'black';
marker = '.';
scatter(i, q, sz, color, marker);  % k==black

set(gca,'visible','off');
set(gca,'xtick',[]);

pixel = 64/150;
set(gcf,'PaperUnits','inches','PaperPosition',[64 64 pixel pixel]);
print -dpng constellations/temp.png -r100;
saveas(gcf, 'constellations/temp.png');


%{
qpsk = comm.QPSKModulator;
sps = 16;
txfilter = comm.RaisedCosineTransmitFilter('Shape','Normal', ...
    'RolloffFactor',0.22, ...
    'FilterSpanInSymbols',20, ...
    'OutputSamplesPerSymbol',sps);
data = randi([0 3],200,1);
modData = qpsk(data);
txSig = txfilter(modData);
scatterplot(txSig,sps)

constDiagram = comm.ConstellationDiagram('SamplesPerSymbol',sps, ...
    'SymbolsToDisplaySource','Property','SymbolsToDisplay',100);
constDiagram(txSig)

release(txfilter)
txfilter.Gain = sqrt(sps);
txSig = txfilter(modData);
scatterplot(txSig,sps)
constDiagram(txSig);

rxSig = awgn(txSig,20,'measured');
constDiagram(rxSig)
%}



%screen2jpeg('temp.png');
%imwrite(a, 'your_image.tif','TIFF','Resolution',[1360 768])



%{
for snr=0:8:17 % x는 1부터 10까지 2씩 증가한다.	
    rxSig = awgn(txSig,snr);
    constDiagram(rxSig)
end
%}

%{
M = 16;
refC = qammod(0:M-1,M);
constDiagram = comm.ConstellationDiagram('ReferenceConstellation',refC, ...
    'XLimits',[-4 4],'YLimits',[-4 4]);
%}


function screen2jpeg(filename)
    if nargin < 1
         error('Not enough input arguments!');
    end
    oldscreenunits = get(gcf,'Units');
    oldpaperunits = get(gcf,'PaperUnits');
    oldpaperpos = get(gcf,'PaperPosition');
    set(gcf,'Units','pixels');
    scrpos = get(gcf,'Position');
    newpos = scrpos/100;
    set(gcf,'PaperUnits','inches',...
         'PaperPosition',newpos);
    print('-djpeg', filename, '-r100');
    drawnow;
    set(gcf,'Units',oldscreenunits,...
         'PaperUnits',oldpaperunits,...
         'PaperPosition',oldpaperpos);
end