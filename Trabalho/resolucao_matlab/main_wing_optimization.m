clc; clear; close all;

% FUNÇÃO AUXILIAR – pontos não dominados
function isPareto = naodominados(F)
isPareto = true(size(F,1),1);
for i = 1:size(F,1)
    dominated = all(F <= F(i,:),2) & any(F < F(i,:),2);
    if any(dominated)
        isPareto(i) = false;
    end
end
end

%% Limites das variáveis
lb = [0, 0, 5, 0];
ub = [15, 15, 50, 0.1];

nvars = 4;

%  MÉTODO 1: ε-CONSTRAINT

% Minimizar CD sujeito a limites em CL e indice de custo
eps_CL   = linspace(1.2, 2.2, 10);     % níveis de downforce
eps_cost = linspace(100, 200, 10);     % limites do indice custo

opts_fmin = optimoptions('fmincon', ...
    'Display','none', ...
    'Algorithm','sqp');

X_eps = [];
F_eps = [];

for i = 1:length(eps_CL)
    for j = 1:length(eps_cost)

        fun = @(x) wing_objectives(x);

        % função escalar (minimizar CD)
        obj = @(x) fun(x);

        % restrições adicionais do ε-constraint
        nonlcon = @(x) eps_constraints(x, eps_CL(i), eps_cost(j));

        x0 = lb + rand(1,nvars).*(ub-lb);

        try
            xsol = fmincon(@obj_CD, x0, [], [], [], [], lb, ub, nonlcon, opts_fmin);
            fsol = wing_objectives(xsol);

            X_eps = [X_eps; xsol];
            F_eps = [F_eps; fsol];
        catch
        end
    end
end

%  MÉTODO 2: GAMULTIOBJ

opts_ga = optimoptions('gamultiobj', ...
    'PopulationSize', 150, ...
    'MaxGenerations', 150, ...
    'Display','iter');

[X_ga, F_ga] = gamultiobj(@wing_objectives, nvars, ...
    [], [], [], [], lb, ub, @wing_constraints, opts_ga);


% Gráficos

% Conversão para interpretação física
F_eps_plot = [F_eps(:,1), -F_eps(:,2), F_eps(:,3)];
F_ga_plot  = [F_ga(:,1),  -F_ga(:,2),  F_ga(:,3)];


%ε-CONSTRAINT

%Scater plot
isPareto_eps = naodominados([F_eps(:,1), F_eps(:,2), F_eps(:,3)]);

F = F_eps_plot(isPareto_eps,:);
NOTF = F_eps_plot(~isPareto_eps,:);

figure
scatter3(F(:,1), F(:,2), F(:,3), 70, 'r', 'filled')
hold on
scatter3(NOTF(:,1), NOTF(:,2), NOTF(:,3), 30, 'b', 'filled')
xlabel('C_D')
ylabel('C_L')
zlabel('Custo')
title('ε-constraint – Scatter 3D')
grid on
view(35,20)
legend('Soluções não dominadas','Soluções dominadas')

%Bubble plot

F = F_eps_plot(isPareto_eps,:);

sizes = 20 + 0.2*F(:,3);

figure
scatter(F(:,2), F(:,1), sizes, F(:,3), 'filled')
xlabel('C_L')
ylabel('C_D')
title('ε-constraint – Bubble plot (Custo)')
colorbar
grid on

%Gamultiobj

%Scatter

isPareto_ga = naodominados([F_ga(:,1), F_ga(:,2), F_ga(:,3)]);

F = F_ga_plot(isPareto_ga,:);
NOTF = F_ga_plot(~isPareto_ga,:);

figure
scatter3(F(:,1), F(:,2), F(:,3), 70, 'r', 'filled')
hold on
scatter3(NOTF(:,1), NOTF(:,2), NOTF(:,3), 30, 'b', 'filled')
xlabel('C_D')
ylabel('C_L')
zlabel('Custo')
title('gamultiobj – Scatter 3D')
grid on
view(35,20)
legend('Soluções não dominadas','Soluções dominadas')

% Bubble

F = F_ga_plot(isPareto_ga,:);

sizes = 20 + 0.2*F(:,3);

figure
scatter(F(:,2), F(:,1), sizes, F(:,3), 'filled')
xlabel('C_L')
ylabel('C_D')
title('gamultiobj – Bubble plot (Custo)')
colorbar
grid on

%% Comparação entre os algortimos 

% não dominadas
nd_eps = naodominados(F_eps);
nd_ga  = naodominados(F_ga);

Fep = F_eps(nd_eps,:);
Fga = F_ga(nd_ga,:);

figure
scatter(Fep(:,1), -Fep(:,2), 70, 'r', 'filled')
hold on
scatter(Fga(:,1), -Fga(:,2), 70, 'b', 'filled')

xlabel('C_D (min)')
ylabel('C_L (max)')
legend('\epsilon-constraint','gamultiobj','Location','best')
grid on
title('Comparação: C_D vs C_L (não dominadas)')

%Path Value

%gamultobj

Fn_ga = (Fga - min(Fga)) ./ (max(Fga) - min(Fga)); 

figure 
parallelcoords(Fn_ga, 'Group', 1:size(Fn_ga,1), ... 
    'Labels', {'C_D','-C_L','Custo'}) 
title('gamultiobj – Path Value (normalizado)') 
grid on

% MÉTRICAS DE DESEMPENHO (ficheiro externo)

metrics = compute_metrics(F_eps, F_ga);
