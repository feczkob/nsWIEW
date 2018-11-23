function draw_spikes(fajl)

Cell = load(fajl);
s = Cell.spikes;
[m, n] = size(s);
db = (Cell.par.w_pre + Cell.par.w_post) / Cell.par.sr;
t = linspace(0, db, n);
c = Cell.cluster_class(:,1);
szin = char(['r','g','b','k','c','y','m','r','g','b']);


figure;
hold on;
grid on;
for x = 1:length(t)/2
   plot(t,s(x,:),'-','Color',szin(c(x)+1));   
end
title('Channel 1');
xlabel('t [ms]', 'FontSize',12,'FontWeight','bold');
ylabel('Feszültség', 'FontSize',12,'FontWeight','bold');

figure;
hold on;
grid on;
for x = length(t)/2:length(t)
   plot(t,s(x,:),'-','Color',szin(c(x)+1));   
end
title('Channel 2');
xlabel('t [ms]', 'FontSize',12,'FontWeight','bold');
ylabel('Feszültség', 'FontSize',12,'FontWeight','bold');

end
