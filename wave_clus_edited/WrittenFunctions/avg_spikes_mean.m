function avg_spikes_mean(file)
%adatok kib·ny·sz·sa
Cell = load(file);
s = Cell.spikes;
%mÈretek
[m, n] = size(s);
%
db = (Cell.par.w_pre + Cell.par.w_post) / Cell.par.sr;
t = linspace(0, db, n);
c = Cell.cluster_class(:,1);

%szÌnezÈs markerezÈs, Ìgy majd menıbbnek t˚nik
plotStyle = {'r-', 'b:', 'k.', 'c-.', 'yo-', 'm*-'};

figure; hold on; grid on;
legendInfo = {};
%indexek szerinti halad·s
for x = 0 : max(c)
    indexek = (c == x);
    %√∂sszes x index-szel rendelkez≈ë spike
    osszes = s(indexek, :);
    %√°tlagol√°s
    abrazolni = mean(osszes, 1); 
    %plottol√°s
    plot(t, abrazolni, plotStyle{x+1});
    %sz√≠nez√©s
    legendInfo{end + 1} = ['cluster #' num2str(x)];
end
legend(legendInfo);
%kozmetik√°z√°s, ha m√°r Balu ezt √∫gyis mindig elfelejti
title('Average of spikes by clusters');
xlabel('t [ms]', 'FontSize',12,'FontWeight','bold');
ylabel('voltage [who knows]', 'FontSize',12,'FontWeight','bold');

%√©s hogy tanuljak ma is valami √∫jat a Stokes t√©telen k√≠v√ºl:
%txt = ['\leftarrow \color{green} \it Itt olyan, mintha z√∂ld lenne :)' ];
%t = text(0.00050, -0.7907, txt, 'FontSize', 10);
end


