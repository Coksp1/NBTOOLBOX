function Y0 = setInitialValues2CondDB(Y0,model,restrictions)
% Syntax:
%
% Y0 = nb_forecast.setInitialValues2CondDB(Y0,model,restrictions)
%
% Description:
%
% Set intial values to conditional information.
% 
% See also:
% nb_forecast
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    if isempty(restrictions.initDBVars)
        return
    end
    try
        [ind,loc] = ismember(restrictions.initDBVars, model.endo);
        if any(ind)
            Y0(loc(ind)) = restrictions.initDB(ind);
        end
    catch Err
        nb_error('Could not set the initial values to the provided conditional information.', Err);
    end

end
