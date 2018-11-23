function plot_coeff_t(fajl, i)
Cell = load(fajl);
%egy akciós potenciál kirajzolása
figure;
y1 = Cell.spikes(i,:);
t0 = Cell.cluster_class(i, 2);

t_pre = Cell.par.w_pre / Cell.par.sr;
t_post = Cell.par.w_post / Cell.par.sr;
[m, n] = size(Cell.spikes);
t1 = linspace(t0 -t_pre, t0 + t_post, n);
plot(t1, y1, '.-');
title('Az i-edik akciós potenciál', 'FontSize',14,'FontWeight','bold');
xlabel('t [ms]', 'FontSize',12,'FontWeight','bold');
ylabel('feszültség', 'FontSize',12,'FontWeight','bold');
% coeffs vs t
t = Cell.cluster_class(:, 2).*1000;
coeffs = Cell.inspk(:, i);
figure; hold on; grid on;

plot(t, coeffs, '.');
title('Coeffs vs t', 'FontSize',14,'FontWeight','bold');
xlabel('t [s]', 'FontSize',12,'FontWeight','bold');
ylabel('Coeffs', 'FontSize',12,'FontWeight','bold');
end