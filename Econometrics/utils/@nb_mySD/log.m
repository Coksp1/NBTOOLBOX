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
% - obj : An object of class nb_mySD.
%
% Output:
% 
% - obj : An object of class nb_mySD.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    objDeriv        = nb_mySD.addPar(obj.derivatives,true); 
    objStr          = nb_mySD.addPar(obj.values,true);
    objStrInFunc    = nb_mySD.addPar(obj.values,false);
    obj.derivatives = strcat(objDeriv ,'./', objStr);
    obj.values      = strcat('log', objStrInFunc);
    
end
