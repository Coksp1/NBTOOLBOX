function obj = steady_state(obj)
% Syntax:
%
% obj = steady_state(obj)
%
% Description:
%
% Steady-state operator.
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
% nb_stTerm, nb_stParam
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen
    
    if ~isempty(obj.error)
        return
    end
    
    str = ['steady_state', nb_mySD.addPar(obj.string,false)]; 
    if isa(obj,'nb_stParam')
        obj.value  = obj.value;
        obj.string = str;
    else
        obj = nb_stTerm(str,obj.trend);
    end

end
