function obj = normcdf(obj,m,k)
% Syntax:
%
% obj = normcdf(obj,m,k)
%
% Description:
%
% Normal cdf.
% 
% Input:
% 
% - obj : An object of class nb_eq2Latex.
%
% - m   : The mean of the distribution. Either as a scalar double or a 
%         one line char representing a number.
%
% - k   : The std of the distribution. Either as a scalar double or a one 
%         line char representing a number.
%
% Output:
% 
% - obj : An object of class nb_eq2Latex.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        k = 1;
        if nargin < 2
            m = 0;
        end
    end

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
    obj.latex    = strcat('\Phi', objLatex,',', mStr, ',', kStr, '\right)');
    objStrInFunc = nb_mySD.addPar(obj.values,false);
    objStrInFunc = objStrInFunc(1:end-1);
    obj.values   = strcat('nb_distribution.normal_cdf', objStrInFunc,',', mStr, ',', kStr, ')');
    
end
