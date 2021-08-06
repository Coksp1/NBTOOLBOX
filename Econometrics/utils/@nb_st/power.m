function obj = power(obj,another)
% Syntax:
%
% obj = power(obj,another)
%
% Description:
%
% Power operator (.^), which is the same as using ^.
% 
% Input:
% 
% - obj     : A scalar number or a nb_st object.
%
% - another : A scalar number or a nb_st object.
% 
% Output:
% 
% - obj     : An object of class nb_stParam or nb_stTerm.
%
% See also:
% nb_stTerm, nb_stParam, nb_st.mpower
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nb_isScalarNumber(obj)
        obj = nb_stParam(nb_num2str(obj,another.precision),obj);
    end
    if nb_isScalarNumber(another)
        another = nb_stParam(nb_num2str(another,obj.precision),another);
    end
    
    if ~isempty(obj.error)
        return
    elseif ~isempty(another.error)
        obj = another;
        return
    end
    
    if isa(another,'nb_stTerm')
        if isTrending(another)
            obj.error = [mfilename ':: A variable/term cannot be raised with a trending variable/term; ' another.string];
            return
        end
    end
    
    str = [nb_mySD.addPar(obj.string,true) '^' nb_mySD.addPar(another.string,true)]; 
    if isa(obj,'nb_stParam') && isa(another,'nb_stParam') 
        obj.value  = obj.value^another.value;
        obj.string = str;
    elseif isa(another,'nb_stParam')
        trend = obj.trend*another.value; 
        obj   = nb_stTerm(str,trend);
    else
        trend = obj.trend; % * SS value??
        obj   = nb_stTerm(str,trend);
    end
        
end
