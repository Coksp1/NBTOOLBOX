function obj = logncdf(obj,m,k)
% Syntax:
%
% obj = logncdf(obj,m,k)
%
% Description:
%
% Log normal cdf.
% 
% Input:
% 
% - obj : An object of class nb_st.
%
% - m   : A parameter such that the mean of the lognormal is
%         exp((m+k^2)/2). Either as a scalar double or a nb_stParam 
%         object.
%
% - k   : A parameter such that the mean of the lognormal is k 
%         exp((m+k^2)/2). Either as a scalar double or a nb_stParam 
%         object.
%
% Output:
% 
% - obj : An object of class nb_stTerm or nb_stParam.
%
% See also:
% nb_stTerm, nb_stParam, nb_st.lognpdf
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
    str    = strcat('logncdf', objStr ,',', mStr, ',', kStr, ')');
    if isa(obj,'nb_stParam')
        obj.value  = logncdf(obj.value,mValue,kValue);
        obj.string = str;
    else
        if isTrending(obj)
            obj.error = [mfilename ':: It is not possible to take logncdf on a trending ',...
                                   'variable/term; ', obj.string];
            return   
        end
        obj = nb_stTerm(str,obj.trend);
    end
    
end
