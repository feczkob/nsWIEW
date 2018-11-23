function avg_spikes_mean(file)
%adatok kib�ny�sz�sa
Cell = load(file);
s = Cell.spikes;
%m�retek
[m, n] = size(s);
%
db = (Cell.par.w_pre + Cell.par.w_post) / Cell.par.sr;
t = linspace(0, db, n);
c = Cell.cluster_class(:,1);

%sz�nez�s markerez�s, �gy majd men�bbnek t�nik
plotStyle = {'r-', 'b:', 'k.', 'c-.', 'yo-', 'm*-'};

figure; hold on; grid on;
legendInfo = {};
%indexek szerinti halad�s
for x = 0 : max(c)
    indexek = (c == x);
    %összes x index-szel rendelkező spike
    osszes = s(indexek, :);
    %átlagolás
    abrazolni = mean(osszes, 1); 
    %plottolás
    plot(t, abrazolni, plotStyle{x+1});
    %színezés
    legendInfo{end + 1} = ['cluster #' num2str(x)];
end
legend(legendInfo);
%kozmetikázás, ha már Balu ezt úgyis mindig elfelejti
title('Average of spikes by clusters');
xlabel('t [ms]', 'FontSize',12,'FontWeight','bold');
ylabel('voltage [who knows]', 'FontSize',12,'FontWeight','bold');

%és hogy tanuljak ma is valami újat a Stokes tételen kívül:
%txt = ['\leftarrow \color{green} \it Itt olyan, mintha zöld lenne :)' ];
%t = text(0.00050, -0.7907, txt, 'FontSize', 10);
end


