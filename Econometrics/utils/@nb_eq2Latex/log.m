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
% - obj : An object of class nb_eq2Latex.
%
% Output:
% 
% - obj : An object of class nb_eq2Latex.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    objLatex     = nb_eq2Latex.addLatexPar(obj.latex,false);
    obj.latex    = ['log' objLatex];
    objStrInFunc = nb_mySD.addPar(obj.values,false);
    obj.values   = ['log' objStrInFunc];
    
end
