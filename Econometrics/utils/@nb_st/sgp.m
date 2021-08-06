function obj = sgp(obj)
% Syntax:
%
% obj = sgp(obj)
%
% Description:
%
% Stochastic growth path operator.
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    if ~isempty(obj.error)
        return
    end
    
    if isa(obj,'nb_stParam')
        error([mfilename ':: Cannot call sgp on a nb_stParam object.'])
    else
        test = regexp(obj.string,'(?<![\(\w\d])[\+-\*/\^\(\)]','once');
        if ~isempty(test)
            varName    = obj.string(1:test-1);
            expr       = [nb_dsge.growthPrefix(),varName];
            obj.string = strrep(obj.string,expr,'');
            obj.string = strrep(obj.string,'*','');
            if ~strcmpi(varName,obj.string)
                error([mfilename ':: The sgp operator cannot be called on a expression, ',...
                                 'only a single variable.'])
            end
        end
        obj.string = [nb_dsge.growthPrefix(), obj.string]; 
        obj.trend  = 0;
    end

end
