function obj = detrend(obj)
% Syntax:
%
% obj = detrend(obj)
%
% Description:
%
% De-trend operator.
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
    
    if isa(obj,'nb_stParam')
        return
    else
        obj.trend = 0;
        match     = regexp(obj.string,'^\w[\w\d]+\([-+]\d\)\*D_Z_\w[\w\d]+(\([+-]\d\))?(\^-\d)?','match');
        if strcmp(match,obj.string)
            match      = regexp(obj.string,'^\w[\w\d]+\([-+]\d\)','match');
            obj.string = match{1};
        end
    end

end
