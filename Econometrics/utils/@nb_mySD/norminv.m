function obj = norminv(obj,m,k)
% Syntax:
%
% obj = norminv(obj,m,k)
%
% Description:
%
% Inverse normal cdf.
% 
% Input:
% 
% - obj : An object of class nb_mySD.
%
% - m   : The mean of the distribution. Either as a scalar double, a 
%         one line char representing a number or a nb_param object.
%
% - k   : The std of the distribution. Either as a scalar double, a one 
%         line char representing a number or a nb_param object.
%
% Output:
% 
% - obj : An object of class nb_mySD.
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
    obj.derivatives = strcat(objDeriv ,'./nb_distribution.normal_pdf', objStrInFunc ,',', mStr, ',', kStr, ')');
    obj.values      = strcat('norminv', objStrInFunc,',', mStr, ',', kStr, ')');
    
end
