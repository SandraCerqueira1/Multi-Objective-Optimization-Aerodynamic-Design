function metrics = compute_metrics(F_eps, F_ga)
% COMPUTE_METRICS
% Calcula métricas de desempenho para comparar

% Conjuntos não dominados
nd_eps = naodominados(F_eps);
nd_ga  = naodominados(F_ga);

Fep = F_eps(nd_eps,:);
Fga = F_ga(nd_ga,:);


% Conjunto de referência
todas = [Fep; Fga];
ND = naodominados(todas);
F_true = todas(ND,:);

% Métricas
metrics.GD_eps  = generationalDistance(Fep, F_true, 'p', 2, 'Normalize', false);
metrics.GD_ga   = generationalDistance(Fga, F_true, 'p', 2, 'Normalize', false);

metrics.IGD_eps = inverseGenerationalDistance(Fep, F_true, 'p', 2, 'Normalize', false);
metrics.IGD_ga  = inverseGenerationalDistance(Fga, F_true, 'p', 2, 'Normalize', false);

metrics.S_eps   = spacingMetric(Fep);
metrics.S_ga    = spacingMetric(Fga);

metrics.Delta_eps = Spread(Fep, F_true, 'Normalize', false);
metrics.Delta_ga  = Spread(Fga, F_true, 'Normalize', false);

ref = max(todas,[],1) + 1;
metrics.HV_eps = hypervolume(Fep, ref);
metrics.HV_ga  = hypervolume(Fga, ref);

% Mostrar resultados
disp('========== MÉTRICAS ==========')
disp(['GD  ε: ',num2str(metrics.GD_eps),' | GA: ',num2str(metrics.GD_ga)])
disp(['IGD ε: ',num2str(metrics.IGD_eps),' | GA: ',num2str(metrics.IGD_ga)])
disp(['S   ε: ',num2str(metrics.S_eps),' | GA: ',num2str(metrics.S_ga)])
disp(['Δ   ε: ',num2str(metrics.Delta_eps),' | GA: ',num2str(metrics.Delta_ga)])
disp(['HV  ε: ',num2str(metrics.HV_eps),' | GA: ',num2str(metrics.HV_ga)])

end

% FUNÇÃO AUXILIAR – não dominados
function isPareto = naodominados(F)
isPareto = true(size(F,1),1);
for i = 1:size(F,1)
    dominated = all(F <= F(i,:),2) & any(F < F(i,:),2);
    if any(dominated)
        isPareto(i) = false;
    end
end
end
