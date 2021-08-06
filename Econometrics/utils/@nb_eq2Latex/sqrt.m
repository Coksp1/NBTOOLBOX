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
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    obj.latex    = ['\sqrt{' obj.latex '}'];
    objStrInFunc = nb_mySD.addPar(obj.values,false);
    obj.values   = ['sqrt' objStrInFunc];
    
end
