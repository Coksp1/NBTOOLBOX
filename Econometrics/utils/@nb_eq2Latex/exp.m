function obj = exp(obj)
% Syntax:
%
% obj = exp(obj)
%
% Description:
%
% Exponential.
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

    objLatex     = nb_eq2Latex.addLatexPar(obj.latex,true);
    obj.latex    = ['e^{' objLatex '}'];
    objStrInFunc = nb_mySD.addPar(obj.values,false);
    obj.values   = ['exp' objStrInFunc];
    
end
