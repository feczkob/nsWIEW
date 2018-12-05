function event(filename)
load(filename, 'cluster_class', 'par');

c1 = 1:size(cluster_class, 1);
c2 = ones(1,size(cluster_class,1));
c3 = zeros(1,length(c1));
c4 = zeros(1,length(c1));
c5 = zeros(1,length(c1));
cll = cluster_class(:, 2)';
c6 = ones(1, length(c1)).*cll.*par.sr./1000;

path = '/home/botond/Documents/MATLAB/nsWIEW/adat/par1/';
fn = 'eventes.ev2';
f=fopen([path fn],'w');
fprintf(f, '%5d %4d %3d %4d %7.4f %8d\n', [c1; c2; c3; c4; c5; c6]);
fclose(f);
end