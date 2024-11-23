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
% - obj : An object of class nb_eq2Latex.
%
% Output:
% 
% - obj : An object of class nb_eq2Latex.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.latex    = ['\sqrt{' obj.latex '}'];
    objStrInFunc = nb_mySD.addPar(obj.values,false);
    obj.values   = ['sqrt' objStrInFunc];
    
end
