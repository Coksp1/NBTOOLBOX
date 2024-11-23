function X = set2nan(X,startDate,observables,set2nan)
% Syntax:
%
% X = nb_estimator.set2nan(X,observables,set2nan)
%
% Description:
%
% Set observations of the data to nan.
% 
% Input:
% 
% - X           : A T x N double.
%
% - startDate   : The start date of the data in X.
%
% - observables : A 1 x N cellstr with the names of the variables.
%
% - set2nan     : A struct on the format struct('VarName1',dates1,
%                 'VarName2',dates2). Se examples on the use of this input
%                 under examples. If you use the name 'all', then the
%                 data of all variables are set to nan!
% 
% Output:
% 
% - X           : A T x N double.
%
% Examples:
%
% set2nanA = struct('all',{nb_quarter(2,2000):nb_quarter(4,2001)})
% set2nan1 = struct('VarName',{nb_quarter(2,2000):nb_quarter(4,2001)})
% set2nan2 = struct('VarName1',{nb_quarter(2,2000):nb_quarter(4,2001)},...
%                   'VarName2',{nb_quarter(2,2000):nb_quarter(2,2001)})
%
% See also:
% nb_tvpmfsvEstimator.normalEstimation, nb_dfmemlEstimator.normalEstimation
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    T     = size(X,1);
    dates = startDate.toDates(0:T-1);

    fields = fieldnames(set2nan);
    for ii = 1:length(fields)
        
        datesThis = set2nan.(fields{ii});
        indD      = ismember(dates,datesThis);
        if strcmpi(fields{ii},'all')
            X(indD,:) = nan;
            break
        else
            indVar = strcmp(fields{ii},observables);
            if ~any(indVar)
                error(['Cannot locate the variable ' fields{ii} ' among the ',...
                       'observables that is a field of the set2nan option.'])
            end
            X(indD,indVar) = nan;
        end
        
    end
      
end
