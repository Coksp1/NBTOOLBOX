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
% - obj : An object of class nb_eq2Latex.
%
% Output:
% 
% - obj : An object of class nb_eq2Latex.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    obj.values = ['-' nb_mySD.addPar(obj.values,true)];
    obj.latex  = ['-' nb_eq2Latex.addLatexPar(obj.latex,true)];
    
end
