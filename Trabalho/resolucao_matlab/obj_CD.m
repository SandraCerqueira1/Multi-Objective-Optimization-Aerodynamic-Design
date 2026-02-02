function f = obj_CD(x)
    F = wing_objectives(x);
    f = F(1);   % minimizar apenas CD
end
