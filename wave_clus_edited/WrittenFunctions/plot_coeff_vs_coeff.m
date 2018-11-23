function plot_coeff_vs_coeff(fajl,X,Y)

Cell = load(fajl);

x = Cell.inspk(:,X);
y = Cell.inspk(:,Y);

figure;
hold on;
grid on;

plot(x,y,'.');
title('plot coeff vs coeff');

end

