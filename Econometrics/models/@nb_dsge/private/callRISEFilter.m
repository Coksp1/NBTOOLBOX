function [out,data_nb_ts] = callRISEFilter(obj,inputs)
% Syntax:
%
% [out,data_nb_ts] = callRISEFilter(obj,inputs)
%
% Description:
%
% Run filtering with RISE model.
% 
% See also:
% nb_dsge.filter
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    out = obj.results;

    % Get the data to filter
    data_nb_ts = window(obj.options.data,inputs.startDate,inputs.endDate,obj.estOptions.riseObject.observables.name);
    allNan     = all(isnan(double(data_nb_ts)),1);
    data_nb_ts = deleteVariables(data_nb_ts,data_nb_ts.variables(allNan));
    data_ts    = toRise_ts(data_nb_ts,'struct');
    rise_obj   = set(obj.estOptions.riseObject,'data',data_ts);

    % Filter the model
    [rise_obj,likelihood] = filter(rise_obj,...
                            'kf_householder_chol',   inputs.kf_householder_chol,...
                            'kf_user_init',          inputs.kf_user_init,...
                            'kf_init_variance',      inputs.kf_init_variance,...
                            'kf_ergodic',            inputs.kf_ergodic);

    if isempty(rise_obj.filtering)
        error([mfilename ':: Filtering by RISE has not worked out!'])
    end

    % Convert output to wanted format
    level     = {'smoothed','filtered','updated'};
    goThrough = {'variables','shocks','measurement_errors','regime_probabilities','state_probabilities'};
    regNum    = rise_obj.markov_chains.regimes_number;
    for ll = 1:length(level)

        for gt = 1:length(goThrough)

            try
                value = rise_obj.filtering.([level{ll},'_',goThrough{gt}]);
                vars  = fieldnames(value)';
                if gt > 3
                    data = structToDouble(value,1);
                else
                    data = structToDouble(value,regNum);
                end
            catch %#ok<CTCH>
                continue
            end

            out.(level{ll}).(goThrough{gt}) = struct('data',data,'startDate',toString(data_nb_ts.startDate),'variables',{vars});
            if strcmpi(goThrough{gt},'variables') && ~isempty(inputs.variables)
                ind = ismember(vars,inputs.variables);
                out.(level{ll}).(goThrough{gt}).data      = out.(level{ll}).(goThrough{gt}).data(:,ind,:);
                out.(level{ll}).(goThrough{gt}).variables = out.(level{ll}).(goThrough{gt}).variables(ind);
            end

        end

    end

    out.likelihood = likelihood;
                
end

%==========================================================================
function dataT = structToDouble(value,regNum)

    fields = fieldnames(value);
    nvars  = length(fields);
    nobs   = size(double(value.(fields{1})),1);
    dataT  = nan(nobs,nvars,regNum);
    for ii = 1:nvars
       dataT(:,ii,:) = permute(double(value.(fields{ii})),[1,3,2]); 
    end

end
