function obj = steady_state(obj)
% Syntax:
%
% obj = steady_state(obj)
%
% Description:
%
% The steady_state operator.
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

    objLatex = strrep(obj.latex,'_{t-1}','_{ss}');
    objLatex = strrep(objLatex,'_{t}','_{ss}');
    objLatex = strrep(objLatex,'_{t+1}','_{ss}');
    if strcmpi(objLatex,obj.latex)
        % Only add bar if time subscript is not used.
        objLatex  = nb_eq2Latex.addLatexPar(obj.latex,true);
        obj.latex = ['\overline{' objLatex '}'];
    else
        obj.latex = objLatex;
    end
    objStrInFunc = nb_mySD.addPar(obj.values,false);
    obj.values   = ['steady_state' objStrInFunc];
    
end
