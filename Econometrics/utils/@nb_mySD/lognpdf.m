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
% - obj : An object of class nb_mySD.
%
% - m   : A parameter such that the mean of the lognormal is
%         exp((m+k^2)/2). Either as a scalar double, a one line char
%         representing a number or a nb_param object.
%
% - k   : A parameter such that the mean of the lognormal is k 
%         exp((m+k^2)/2). Either as a scalar double, a one line char
%         representing a number or a nb_param object.
%
% Output:
% 
% - obj : An object of class nb_mySD.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nb_isOneLineChar(m)
        mStr = m;
    elseif isa(m,'nb_param')
        mStr = char(m);    
    else
        mStr = nb_num2str(m,obj.precision);
    end
    
    if nb_isOneLineChar(k)
        kStr = k;
    elseif isa(k,'nb_param')
        kStr = char(k);     
    else
        kStr = nb_num2str(k,obj.precision);
    end
    
    objDeriv        = nb_mySD.addPar(obj.derivatives,true); 
    objStrInFunc    = nb_mySD.addPar(obj.values,false);
    objStrInFunc    = objStrInFunc(1:end-1);
    obj.derivatives = strcat(objDeriv ,'.*nb_lognormal_deriv', objStrInFunc ,',', mStr, ',', kStr, ')');
    obj.values      = strcat('nb_distribution.lognormal_pdf', objStrInFunc,',', mStr, ',', kStr, ')');
    
end

