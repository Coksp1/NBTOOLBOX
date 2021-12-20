function [reported,raw] = reportFiltered(obj,expression,extra,type,normalize,econometricians)
% Syntax:
%
% [reported,raw] = reportFiltered(obj,expression)
% [reported,raw] = reportFiltered(obj,expression,extra)
% [reported,raw] = reportFiltered(obj,expression,extra,type,normalize,...
%                           econometricians)
%
% Description:
%
% 
% 
% Input:
% 
% - obj             : An object of class nb_dsge.
%
% - expression      : See the documentation of the reporting property of
%                     the nb_dsge class.
%
% - extra           : An object of class nb_ts with additional variables
%                     used for reporting purposes.
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
% - reprted         : An object of class nb_ts with the reported variables.
%
% - raw             : An object of class nb_ts with the raw filtered 
%                     variables.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 6
        econometricians = false;
        if nargin < 5
            normalize = false;
            if nargin < 4
                type = 'smoothed';
                if nargin < 3
                    extra = [];
                end
            end
        end
    end

    raw      = getFiltered(obj,type,normalize,econometricians);
    reported = doReporting(obj,raw,expression,extra);

end

function reported = doReporting(obj,raw,reporting,extra)

    % Get historical values
    variables = raw.variables;
    data      = double(raw);
    pages     = raw.numberOfDatasets;
    nobs      = raw.numberOfObservations;
    
    % Add shift variables
    if isfield(obj.options,'shift')
        shift = obj.options.shift;
        if shift.endDate < raw.endDate
            shift = expand(shift,'',raw.endDate,'obs');
        end
        [ind,indS]     = ismember(shift.variables,variables);
        indS           = indS(ind);
        shiftData      = double(window(shift,raw.startDate,raw.endDate));
        shiftData      = shiftData(:,ind,ones(1,pages));
        data(:,indS,:) = data(:,indS,:) + shiftData;
    end
    
    % Get other variables not estimated by the filter
    dataOther = window(obj.options.data,raw.startDate,raw.endDate);
    if dataOther.endDate < raw.endDate
        dataOther = expand(dataOther,'',raw.endDate,'nan');
    end
    dataOther = dataOther.deleteVariables(variables);
    variables = [variables,dataOther.variables];
    data      = [data,double(dataOther)];

    % Merge with additional variables
    if ~isempty(extra)
        if extra.endDate < raw.endDate
            extra = expand(extra,'',raw.endDate,'nan');
        end
        extra     = window(extra,raw.startDate,raw.endDate);
        extra     = extra.deleteVariables(variables);
        variables = [variables,extra.variables];
        data      = [data,double(extra)];
    end
    
    % Check each expressions
    nNewVars = size(reporting,1);
    reported = nan(nobs,nNewVars,pages);
    for ii = 1:nNewVars
        
        expression = reporting{ii,2};
        try 
            reported(:,ii,:) = nb_eval(expression,variables,data); 
        catch Err
            message = [[mfilename ':: Error while evaluation expression; ' char(10) char(10) reporting{ii,1} ' = ' expression],...
                       char(10),char(10), getReport(Err,'extended','hyperLinks','on')];
            disp('----------------------------------------------------------')
            disp(message)
            disp('----------------------------------------------------------')
        end 
        
        % To make it possible to use newly created variables in the 
        % expressions to come, we must append it in this way
        found = strcmpi(reporting{ii,1},variables);
        if ~any(found)
            data      = [data,reported(:,ii,:)]; %#ok<AGROW>
            variables = [variables,reporting{ii,1}]; %#ok<AGROW>
        else
            data(:,found,:) = reported(:,ii,:);
        end
    end
    
    % Merge reported variables with model forecast
    reported = nb_ts(reported,'',raw.startDate,reporting(:,1)');

end
