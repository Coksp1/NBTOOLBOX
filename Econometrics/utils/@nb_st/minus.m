function obj = minus(obj,another)
% Syntax:
%
% obj = minus(obj,another)
%
% Description:
%
% Minus operator (-).
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
% nb_stTerm, nb_stParam, nb_st.plus, nb_st.uminus
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

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
    
    str = [obj.string '-' nb_mySD.addPar(another.string,true)]; 
    if isa(obj,'nb_stParam') && isa(another,'nb_stParam') 
        obj.value  = obj.value - another.value;
        obj.string = str;
    else
        if abs(obj.trend - another.trend) > 1e-14
            if isa(obj,'nb_stParam') && obj.value == 0
                obj = another;
            elseif not(isa(another,'nb_stParam') && another.value == 0)
                obj.error = [mfilename ':: If you substract one term from another, they need to trend at the same rate; '...
                                       obj.string ' - ' another.string];
                return     
            end
        end
        obj = nb_stTerm(str,obj.trend);
    end

end
