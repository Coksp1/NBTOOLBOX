function obj = bgp(obj)
% Syntax:
%
% obj = bgp(obj)
%
% Description:
%
% Balanced growth path operator.
% 
% Input:
% 
% - obj : A nb_st object.
% 
% Output:
% 
% - obj : An object of class nb_stTerm.
%
% See also:
% nb_stTerm, nb_stParam
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen
    
    if ~isempty(obj.error)
        return
    end
    
    if isa(obj,'nb_stParam')
        error([mfilename ':: Cannot call bgp on a nb_stParam object.'])
    else
        test = regexp(obj.string,'\+-\*/\^\(\)','once');
        if ~isempty(test)
            error([mfilename ':: The bgp operator cannot be called on a expression, ',...
                             'only a single variable.'])
        end
        obj.string = ['steady_state', nb_mySD.addPar([nb_dsge.growthPrefix(), obj.string],false)]; 
        obj.trend  = 0;
    end

end
