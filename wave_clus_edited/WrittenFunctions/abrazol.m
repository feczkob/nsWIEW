function abrazol(fajl,honnan)

Cell = load(fajl);

t = Cell.cluster_class(:,2);
y = Cell.cluster_class(:,1);

figure;
a = max(Cell.spikes,[],2);

hold on;
grid on;
szin = char(['r','g','b','k','c','y','m','r','g','b']);

for x = honnan: max(y)
ind = find(y == x);
vektor = ones(length(ind),1).*x;
plot3(t(ind),vektor,a(ind),'.','MarkerSize', 15,'MarkerFaceColor', szin(x+1));
view([-110,15])
ylim([-0.5,max(y)+0.5]);
title('Amplitude of clusters','FontSize',14,'FontWeight','bold');
xlabel('t','FontSize',12,'FontWeight','bold');
ylabel('Clusters','FontSize',12,'FontWeight','bold');
zlabel('Amplitude','FontSize',12,'FontWeight','bold');
end

figure;
hold on;
grid on;
for z = honnan: max(y)
ind = find(y == z);
plot(y(ind),a(ind),'.','MarkerSize', 15,'MarkerFaceColor', szin(z+1));

xlim([-0.5,max(y)+0.5]);
title('Amplitude of clusters 2D','FontSize',14,'FontWeight','bold');
xlabel('Clusters','FontSize',12,'FontWeight','bold');
ylabel('Amplitude','FontSize',12,'FontWeight','bold');
end

figure;
hold on;
grid on;
for z = honnan:max(y)
ind = find(y == z);
plot(t(ind),y(ind),'.','MarkerSize', 15,'MarkerFaceColor', szin(z+1));
ylim([-0.5,max(y)+0.5]);
title('Cluster class','FontSize',14,'FontWeight','bold');
xlabel('t','FontSize',12,'FontWeight','bold');
ylabel('Clusters','FontSize',12,'FontWeight','bold');
end

end
