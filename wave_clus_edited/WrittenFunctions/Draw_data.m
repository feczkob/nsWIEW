function Draw_data(file)

%fajlok = cell(load(file))
%
data = load(file);
figure;
n = length(data.data);
t = linspace(0,n/20000,n);

plot(t,data.data);
xlim ([0,0.2]);
ylim ([-500,500]);

end

