function obj = steady_state_first(obj)
% Syntax:
%
% obj = steady_state_first(obj)
%
% Description:
%
% Steady-state (first regime) operator.
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    if ~isempty(obj.error)
        return
    end
    
    str = ['steady_state_first', nb_mySD.addPar(obj.string,false)]; 
    if isa(obj,'nb_stParam')
        obj.value  = obj.value;
        obj.string = str;
    else
        obj = nb_stTerm(str,obj.trend);
    end

end
