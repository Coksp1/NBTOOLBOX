function [out,data_nb_ts] = callDynareFilter(obj,inputs)
% Syntax:
%
% [out,data_nb_ts] = callDynareFilter(obj,inputs)
%
% Description:
%
% Run filtering with Dynare model.
% 
% See also:
% nb_dsge.filter, nb_dynareSmoother
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    M_       = obj.estOptions.M_;
    oo_      = obj.estOptions.oo_;
    options_ = obj.estOptions.options_;
    out      = obj.results;

    % Get the data to filter
    data_nb_ts  = window(obj.options.data,inputs.startDate,inputs.endDate);
    data        = double(data_nb_ts);
    [found,ind] = ismember(options_.varobs,data_nb_ts.variables);
    if ~all(found)
        error([mfilename ':: Some of the observables is not found to be in the dataset (options.data); '....
            toString(cellstr(options_.varobs(~found,:))')])
    end
    data = data(:,ind);

    % Set the filter options
    if ~isempty(inputs.diffuse_filter)
        options_.diffuse_filter = inputs.diffuse_filter;
    end
    if ~isempty(inputs.lik_init)
        options_.lik_init = inputs.lik_init;
    end
    if ~isempty(inputs.kalman_algo)
        options_.kalman_algo = inputs.kalman_algo;
    end
    if ~isempty(inputs.Harvey_scale_factor)
        options_.Harvey_scale_factor = inputs.Harvey_scale_factor;
    end
    options_.first_obs = 1;
    options_.nobs      = size(data,1);

    % Run the filter/smoother
    try
        [~,oo_,~] = nb_dynareSmoother(M_,options_,oo_,data,inputs.variables{:});
    catch Err
        if strcmp(Err.identifier,'MATLAB:UndefinedFunction')
            error([mfilename ':: This version of NB toolbox does not support filtering of a ',...
                             'dynare parsed and solved model after dynare has finished running. Change you model ',...
                             'file to filter you model, and use the nb_dsge.getFiltered method.'])
        else
            rethrow(Err);
        end
    end
    
    % Convert output to wanted format
    level      = {'Smoothed','Filtered','Updated'};
    lLevel     = lower(level);
    goThrough  = {'Variables','Shocks'};
    goThroughL = lower(goThrough);
    for ll = 1:3

        for gt = 1:4

            try
                value = oo_.([level{ll},goThrough{gt}]);
            catch %#ok<CTCH>
                continue
            end
            vars  = fields(value)';
            data  = structToDoubleDynare(value);

            out.(lLevel{ll}).(goThroughL{gt}) = struct('data',data,'startDate',toString(data_nb_ts.startDate),'variables',{vars});
            if strcmpi(goThrough{gt},'variables') && ~isempty(inputs.variables)
                ind = ismember(vars,inputs.variables);
                out.(lLevel{ll}).(goThroughL{gt}).data      = out.(lLevel{ll}).(goThrough{gt}).data(:,ind,:);
                out.(lLevel{ll}).(goThroughL{gt}).variables = out.(lLevel{ll}).(goThrough{gt}).variables(ind);
            end

        end

    end

    out.likelihood = [];

end

%==========================================================================
function dataT = structToDoubleDynare(value)

    fields = fieldnames(value);
    nvars  = length(fields);
    nobs   = length(double(value.(fields{1})));
    dataT  = nan(nobs,nvars);
    for ii = 1:nvars
        data        = double(value.(fields{ii}));
        dataT(:,ii) = data(:); 
    end

end
