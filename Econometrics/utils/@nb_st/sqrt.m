function obj = sqrt(obj)
% Syntax:
%
% obj = sqrt(obj)
%
% Description:
%
% Square root.
% 
% Input:
% 
% - obj : A nb_st object.
% 
% Output:
% 
% - obj : An object of class nb_stParam or nb_stTerm.
%
% See also:
% nb_stTerm, nb_stParam, nb_st.power
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    if ~isempty(obj.error)
        return
    end
    
    str = ['sqrt', nb_mySD.addPar(obj.string,false)]; 
    if isa(obj,'nb_stParam')
        obj.value  = sqrt(obj.value);
        obj.string = str;
    else
        obj = nb_stTerm(str,0.5*obj.trend);
    end

end
