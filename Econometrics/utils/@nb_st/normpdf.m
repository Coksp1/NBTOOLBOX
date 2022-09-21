function obj = normpdf(obj,m,k)
% Syntax:
%
% obj = normpdf(obj,m,k)
%
% Description:
%
% Normal pdf.
% 
% Input:
% 
% - obj : An object of class nb_st.
%
% - m   : The mean of the distribution. Either as a scalar double 
%         or a nb_stParam object.
%
% - k   : The std of the distribution. Either as a scalar double or a 
%         nb_stParam object.
%
% Output:
% 
% - obj : An object of class nb_stTerm or nb_stParam.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c)  2019, Norges Bank

    if nargin < 3
        k = 1;
        if nargin < 2
            m = 0;
        end
    end

    if isa(m,'nb_stParam')
        mStr   = m.string;
        mValue = m.value;
    else
        mStr   = nb_num2str(m,obj.precision);
        mValue = m;
    end
    
    if isa(k,'nb_stParam')
        kStr   = k.string;  
        kValue = k.value;
    else
        kStr   = nb_num2str(k,obj.precision);
        kValue = k;
    end
    
    objStr = nb_mySD.addPar(obj.string,false);
    objStr = objStr(1:end-1);
    str    = strcat('normpdf', objStr ,',', mStr, ',', kStr, ')');
    if isa(obj,'nb_stParam')
        obj.value  = normpdf(obj.value,mValue,kValue);
        obj.string = str;
    else
        if isTrending(obj)
            obj.error = [mfilename ':: It is not possible to take normpdf on a trending ',...
                                   'variable/term; ', obj.string];
            return   
        end
        obj = nb_stTerm(str,obj.trend);
    end
    
end
