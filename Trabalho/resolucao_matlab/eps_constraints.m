function [c, ceq] = eps_constraints(x, epsCL, epsCost)

f = wing_objectives(x);

% f(2) = -CL
CL = -f(2);
Cost = f(3);

[c_base, ~] = wing_constraints(x);

c = [
    c_base;
    epsCL - CL;      % CL >= epsCL
    Cost - epsCost   % Custo <= epsCost
];

ceq = [];
end
