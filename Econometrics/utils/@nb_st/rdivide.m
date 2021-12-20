function obj = rdivide(obj,another)
% Syntax:
%
% obj = rdivide(obj,another)
%
% Description:
%
% Right division operator (./), which is the same as using /.
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
% nb_stTerm, nb_stParam, nb_st.mrdivide
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
    
    str = [nb_mySD.addPar(obj.string,true) '/' nb_mySD.addPar(another.string,true)]; 
    if isa(obj,'nb_stParam') && isa(another,'nb_stParam') 
        obj.value  = obj.value/another.value;
        obj.string = str;
    elseif isa(obj,'nb_stParam') 
        obj = nb_stTerm(str,-another.trend);
    elseif isa(another,'nb_stTerm')
        trend = obj.trend - another.trend; 
        obj   = nb_stTerm(str,trend);
    else
        obj.string = str; 
    end
        
end
