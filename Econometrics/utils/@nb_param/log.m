function obj = log(obj)
% Syntax:
%
% obj = log(obj)
%
% Description:
%
% Natural logarithm.
% 
% Input:
% 
% - obj : An object of class nb_param.
%
% Output:
% 
% - obj : An object of class nb_param.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    paramStr      = nb_mySD.addPar(obj.parameter,false);
    obj.parameter = ['log' paramStr];
    
end
