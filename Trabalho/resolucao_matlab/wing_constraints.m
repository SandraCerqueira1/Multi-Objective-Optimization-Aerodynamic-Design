function [c, ceq] = wing_constraints(x)

alpha1 = x(1);
alpha2 = x(2);
s      = x(3);
camb   = x(4);

% Downforce (para restrição CL >= 1.2) 
CL = 1.0 ...
    + 0.08*alpha1 ...
    + 0.06*alpha2 ...
    + 0.5*camb ...
    - 0.0003*s ...
    + 0.002*alpha1*alpha2 ...
    - 0.0002*alpha1^2 ...
    - 0.0001*alpha2^2;

% Restrições de desigualdade c(x) <= 0
c = [
    abs(alpha1 - alpha2) - 10;   % estabilidade aerodinâmica
    1.2 - CL                     % downforce mínima
];

ceq = [];
end
