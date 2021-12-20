function data = getFiltered(obj,type,normalize,econometricians)
% Syntax:
%
% data = getFiltered(obj,type)
% data = getFiltered(obj,type,normalize)
% data = getFiltered(obj,type,normalize,econometricians)
%
% Description:
%
% Get filtered variables as a nb_ts object. This will include endogenous,
% exogenous, shocks, states and regime probabilities, if any.
% 
% Caution: Model must already be filtered!
%
% Input:
% 
% - obj             : An object of class nb_model_recursive_detrending
% 
% - type            : Either 'filtered', 'smoothed' or 'updated'. Default
%                     is 'smoothed'. 
%
% - normalize       : Normalize the shock to be N(0,1). Default is false.
%
% - econometricians : Get econometricians view of the filtered variables.
%                     I.e. the filtered variables of each regime multiplied
%                     by the regime probabilities.
%
% Output:
% 
% - data : A nb_ts object with size nobs x nvars x nPeriods included the 
%          filtered variables.
%
% See also:
% nb_model_recursive_detrending.estimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        econometricians = false;
        if nargin < 3
            normalize = false;
        end
        if nargin < 2
            type = 'smoothed';
        end
    end

    if numel(obj) > 1
        error([mfilename ':: This method only support a 1x1 nb_model_generic object.'])
    end
    
    if ~isFiltered(obj)
        error([mfilename ':: The model is not filtered.'])
    end
    
    if nargin < 4
        econometricians = false;
        if nargin < 3
            normalize = false;
        end
        if nargin < 2
            type = 'smoothed';
        end
    end

    if numel(obj) > 1
        error([mfilename ':: This method only support a 1x1 nb_model_recursive_detrending object.'])
    end
    
    if ~isFiltered(obj)
        error([mfilename ':: The model is not filtered.'])
    end
    
    data = nb_ts();
    for tt = 1:length(obj.modelInit)
        dataTT = getFiltered(obj.modelInit(tt),type,normalize,econometricians);
        data   = addPages(data,dataTT);
    end
    data.dataNames = obj(ii).options.recursive_start_date:obj(ii).getRecursiveEndDate();
        
end
