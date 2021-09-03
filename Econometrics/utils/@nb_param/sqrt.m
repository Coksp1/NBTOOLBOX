function obj = sqrt(obj)
% Syntax:
%
% obj = sqrt(obj)
%
% Description:
%
% Square root.
% 
% Input:
% 
% - obj : An object of class nb_param.
%
% Output:
% 
% - obj : An object of class nb_param.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    paramStr      = nb_mySD.addPar(obj.parameter,false);
    obj.parameter = ['sqrt' paramStr];
    
end