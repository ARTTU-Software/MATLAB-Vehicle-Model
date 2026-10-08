%% Script Automat de Simulare - Damping & Spring Sweep
% Ruleaza automat modelul 'suspension_model' si compara raspunsul dinamic

% 1. Incarcam parametrii initiali din init_car.m
run('init_car.m');

model_name = 'suspension_model';
load_system(model_name);

% Ne asiguram ca Simscape Logging este activat pe 'All'
set_param(model_name, 'SimscapeLogType', 'all');
set_param(model_name, 'SimscapeLogName', 'simlog');

%% SIMULAREA 1: Optimizarea Amortizorului (Damping Sweep)
damping_values = [1500, 3500, 6000]; % [Ns/m] - Sub-amortizat, Optim, Supra-amortizat
colors = {'#D95319', '#0072BD', '#77AC30'};

fig1 = figure('Name', 'Suspension Damping Sweep', 'Color', 'w', 'Position', [100, 100, 900, 500]);

% Vom afisa in paralel: (1) Unghiul Bellcrank-ului si (2) Unghiul Bratului
ax1 = subplot(1, 2, 1, 'Parent', fig1, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
hold(ax1, 'on'); grid(ax1, 'on'); box(ax1, 'on');
title(ax1, 'Raspuns Bellcrank (Revolute Joint 4)', 'Color', 'k', 'FontWeight', 'bold');
xlabel(ax1, 'Time (s)', 'Color', 'k');
ylabel(ax1, 'Angle (deg)', 'Color', 'k');

ax2 = subplot(1, 2, 2, 'Parent', fig1, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
hold(ax2, 'on'); grid(ax2, 'on'); box(ax2, 'on');
title(ax2, 'Raspuns Brat Suspensie (Universal Joint)', 'Color', 'k', 'FontWeight', 'bold');
xlabel(ax2, 'Time (s)', 'Color', 'k');
ylabel(ax2, 'Angle (deg)', 'Color', 'k');

for i = 1:length(damping_values)
    % Modificam coeficientul de amortizare in Workspace
    Chassis.SuspA1.damping_coeff = damping_values(i);
    fprintf('>>> Rulare Damping Sweep %d/%d (c = %d Ns/m)...\n', ...
        i, length(damping_values), damping_values(i));
    
    % Rulam simularea pentru 1.5 secunde
    simOut = sim(model_name, 'StopTime', '1.5');
    
    % Extragem datele din Revolute_Joint4
    t_rev = simOut.simlog.Revolute_Joint4.Rz.q.series.time;
    q_rev = simOut.simlog.Revolute_Joint4.Rz.q.series.values('deg');
    
    % Extragem datele din Universal_Joint (axa Rx si Ry combinate ca norma sau Rx)
    t_uni = simOut.simlog.Universal_Joint.Rx.q.series.time;
    q_uni_x = simOut.simlog.Universal_Joint.Rx.q.series.values('deg');
    q_uni_y = simOut.simlog.Universal_Joint.Ry.q.series.values('deg');
    % Folosim axa care are miscarea principala
    if max(abs(q_uni_x)) >= max(abs(q_uni_y))
        q_uni = q_uni_x;
    else
        q_uni = q_uni_y;
    end
    
    % Plotam pe ambele grafice
    plot(ax1, t_rev, q_rev, 'LineWidth', 2, 'Color', colors{i}, ...
        'DisplayName', sprintf('c = %d Ns/m', damping_values(i)));
    plot(ax2, t_uni, q_uni, 'LineWidth', 2, 'Color', colors{i}, ...
        'DisplayName', sprintf('c = %d Ns/m', damping_values(i)));
end

legend(ax1, 'Location', 'best', 'TextColor', 'k', 'Color', 'w');
legend(ax2, 'Location', 'best', 'TextColor', 'k', 'Color', 'w');

% Resetam amortizarea la valoarea de baza (3500 Ns/m)
Chassis.SuspA1.damping_coeff = 3500;

%% SIMULAREA 2: Rigiditatea Arcului (Spring Rate Sweep)
spring_values = [60000, 80000, 100000]; % [N/m] -> 60, 80, 100 N/mm

fig2 = figure('Name', 'Suspension Spring Rate Sweep', 'Color', 'w', 'Position', [150, 150, 600, 450]);
ax3 = axes('Parent', fig2, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
hold(ax3, 'on'); grid(ax3, 'on'); box(ax3, 'on');

for i = 1:length(spring_values)
    Chassis.SuspA1.spring_rate = spring_values(i);
    fprintf('>>> Rulare Spring Sweep %d/%d (k = %d N/m)...\n', ...
        i, length(spring_values), spring_values(i));
    
    simOut = sim(model_name, 'StopTime', '1.5');
    
    t_uni = simOut.simlog.Universal_Joint.Rx.q.series.time;
    q_uni_x = simOut.simlog.Universal_Joint.Rx.q.series.values('deg');
    q_uni_y = simOut.simlog.Universal_Joint.Ry.q.series.values('deg');
    if max(abs(q_uni_x)) >= max(abs(q_uni_y))
        q_uni = q_uni_x;
    else
        q_uni = q_uni_y;
    end
    
    plot(ax3, t_uni, q_uni, 'LineWidth', 2, 'Color', colors{i}, ...
        'DisplayName', sprintf('k = %d N/mm', spring_values(i)/1000));
end

title(ax3, 'Suspension Deflection - Spring Rate Sweep', 'Color', 'k', 'FontWeight', 'bold');
xlabel(ax3, 'Time (s)', 'Color', 'k');
ylabel(ax3, 'Wishbone Angle (deg)', 'Color', 'k');
legend(ax3, 'Location', 'best', 'TextColor', 'k', 'Color', 'w');

% Resetam arcul la valoarea initiala
Chassis.SuspA1.spring_rate = 80000;
disp('>>> Toate simularile s-au finalizat cu succes!');