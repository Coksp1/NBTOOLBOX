function obj = uminus(obj)
% Syntax:
%
% obj = uminus(obj)
%
% Description:
%
% Uniary minus.
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.parameter = ['-' nb_mySD.addPar(obj.parameter,true)];
    
end
