function obj = doDeriv(obj)
% Syntax:
%
% obj = doDeriv(obj)
%
% Description:
%
% Calculates symbolic first order derivatives.
% 
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Create the variables with lead and lag
    vars = [strcat(obj.variables,'_lag'),obj.variables,strcat(obj.variables,'_lead')];
    vars = strcat(obj.ssIdentifier{1},vars,obj.ssIdentifier{2});
    
    % Do symbolic derivation
    varsD     = nb_mySD(vars,obj.precision);
    parsD     = nb_param(obj.parameters,obj.precision);
    obj.deriv = obj.eqFunc(varsD,parsD);
    
    % Equations in steady-state
    varsSS   = nb_param(vars,obj.precision);
    parsSS   = nb_param(obj.parameters,obj.precision);
    ssEqObj  = obj.eqFunc(varsSS,parsSS);
    obj.ssEq = {ssEqObj.parameter}';
    for ii = 1:size(obj.ssEq,1)
        obj.ssEq{ii} = strrep(obj.ssEq{ii},'zzz_constant',obj.equations{ii});
    end
    
end
