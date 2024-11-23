function obj = lognpdf(obj,m,k)
% Syntax:
%
% obj = lognpdf(obj,m,k)
%
% Description:
%
% Log normal pdf.
% 
% Input:
% 
% - obj : An object of class nb_eq2Latex.
%
% - m   : A parameter such that the mean of the lognormal is
%         exp((m+k^2)/2). Either as a scalar double or a one line char
%         representing a number.
%
% - k   : A parameter such that the mean of the lognormal is k 
%         exp((m+k^2)/2). Either as a scalar double or a one line char
%         representing a number.
%
% Output:
% 
% - obj : An object of class nb_eq2Latex.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nb_isOneLineChar(m)
        mStr = m;  
    else
        mStr = nb_num2str(m,obj.precision);
    end
    
    if nb_isOneLineChar(k)
        kStr = k;    
    else
        kStr = nb_num2str(k,obj.precision);
    end
    
    objLatex     = nb_eq2Latex.addLatexPar(obj.latex,false); 
    objLatex     = objLatex(1:end-7);
    obj.latex    = strcat('\phi_{log}', objLatex,',', mStr, ',', kStr, '\right)');
    objStrInFunc = nb_mySD.addPar(obj.values,false);
    objStrInFunc = objStrInFunc(1:end-1);
    obj.values   = strcat('nb_distribution.lognormal_pdf', objStrInFunc,',', mStr, ',', kStr, ')');
    
end

