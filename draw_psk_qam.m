% =========================================================================
% Variables declaration
% mod7, xnr4에 대해 fig 1개당 5초 (500개에 2500초)
tic

n_iq_imbal = 0;
n_samples = 128;
fig_num = 20;  % FIXME to 500

target_snr = [0 8 18 25];
target_n_psk = [2 4 8 16];
target_n_qam = [16 32 64];

%target_snr = [18];
%target_n_psk = [2 4 8 16];

rot = [1 2 3 5 6 7];  % modulation 회전
% =========================================================================
% PSK modulations
for n_snr=target_snr
    for n_psk=target_n_psk 
        for cnt=1:1:fig_num
            if mod(cnt, 6) == 0
                i_rot = 6;
            else 
                i_rot = mod(cnt, 6);  % 배열 인덱스는 양의정수나 논리값
            end
            now_rot = rot(i_rot);
            data = randi([0 n_psk-1],n_samples,1);            
            modData = pskmod(data,n_psk,now_rot*pi/8);            
            txSig = iqimbal(modData,n_iq_imbal);  % IQ imbalance, default 5
            rxSig = awgn(txSig, n_snr, 'measured');            
            draw_fig_modulation("PSK", rxSig, n_psk, n_snr, cnt);
        end
    end
end

% QAM modulation
for n_snr=target_snr
    for n_qam=target_n_qam
        for cnt=1:1:fig_num
            data = randi([0 n_psk-1],n_samples,1);     
            txSig = qammod(data,n_qam, 'UnitAveragePower',true); 
            rxSig = awgn(txSig, n_snr, 'measured');            
            draw_fig_modulation("QAM", rxSig, n_qam, n_snr, cnt);
        end
    end
end

toc
% =========================================================================
% Function definition
% n_mod는 n_psk, n_qam
function draw_fig_modulation(mod_type, rxSig, n_mod, n_snr, cnt)
    i = real(rxSig);
    q = imag(rxSig);

    sz = 0.01;
    color = 'black';
    marker = '.';
    scatter(i, q, sz, color, marker);  % k==black

    set(gca,'visible','off');  % yticks 
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);  % 우로 치우치던것 해결

    pixel = 64/150;
    set(gcf,'PaperUnits','inches','PaperPosition',[64 64 pixel pixel]);
    
    % 디렉토리, 파일이름 설정 
    if n_snr == 0
        snr_str = "00";
    elseif n_snr == 8
        snr_str = "08";
    elseif n_snr == 18
        snr_str = "18";
    else
        snr_str = num2str(n_snr);
    end
    
    if mod_type == "PSK"
        if n_mod == 2
            mod_str = "BPSK";
        elseif n_mod == 4
            mod_str = "QPSK";
        elseif n_mod == 8
            mod_str = "8PSK";
        elseif n_mod == 16
            mod_str = "16PSK";
        else
            disp("Invalid n_psk");
            return 
        end    
    elseif mod_type == "QAM"
        if n_mod == 16
            mod_str = "16QAM";
        elseif n_mod == 32
            mod_str = "32QAM";
        elseif n_mod == 64
            mod_str = "64QAM";
        else
            disp("Invalid n_qam");
            return 
        end   
    end
    
    
    dirname = strcat("constellations/", snr_str, "_", mod_str);
    if not(exist(dirname, "dir"))
        mkdir(dirname); 
    end
    
    cnt_str = num2str(cnt);
    filename = strcat(dirname, "/", cnt_str, ".png");
    saveas(gcf, filename);
end



