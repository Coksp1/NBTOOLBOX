function data = getFiltered(obj,type,normalize,econometricians,varargin)
% Syntax:
%
% data = getFiltered(obj,type)
% data = getFiltered(obj,type,normalize)
% data = getFiltered(obj,type,normalize,econometricians,varargin)
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
% - obj             : An object of class nb_model_generic
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
% Optional input:
%
% - 'reporting'     : Either 'stored' or a N x 3 cell array on the format
%                     of the reporting property. If 'stored' it will use
%                     the reporting property stored in the object. If that
%                     is empty, no reporting is done. Default is not to do
%                     any reporting.
%
% Output:
% 
% - data : A nb_ts object with size nobs x nvars included the filtered
%          variables.
%
% See also:
% nb_dsge.filter, nb_model_generic.estimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c)  2019, Norges Bank

    if nargin < 4
        econometricians = false;
        if nargin < 3
            normalize = false;
        end
        if nargin < 2
            type = 'smoothed';
        end
    end
    
    % Parse the arguments      
    default = {...
        'pages',         [],     {@nb_iswholenumber,'||',@isempty};...
        'reporting',     {},     {@nb_isOneLineChar,'||',@iscell,'||',@isempty};...    
    };
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end

    if numel(obj) > 1
        error([mfilename ':: This method only support a 1x1 nb_model_generic object.'])
    end
    
    if ~isFiltered(obj)
        error([mfilename ':: The model is not filtered.'])
    end
    results = obj.results;
    if isfield(results,'realTime')
        realTime = results.realTime;
    else
        realTime = false;
    end
    
    try
        filtered = results.(type);
    catch %#ok<CTCH>
        error([mfilename ':: Unsupported type ' type])
    end
    
    if isa(obj,'nb_dsge')
        if ~isfield(obj.solution,'A')
            obj = solve(obj);
        end
        % Rise/NB/realTime is already normalized
        needNotBeNormalized = isRise(obj) || isNB(obj) || realTime;
        isMarkovSwitching   = iscell(obj.solution.A) && isRise(obj);
    else
        needNotBeNormalized = false;
        isMarkovSwitching   = false;
    end
    
    
    if isa(obj,'nb_fmdyn')
        if strcmpi(obj.options.estim_method,'tvpmfsv')
            goThrough = {'variables','shocks','errors'};
        else
            goThrough = {'variables','shocks'};
        end
    else
        if isfield(obj.options,'estim_method') && strcmpi(obj.options.estim_method,'tvpmfsv')
            goThrough = {'variables','shocks','errors'};
        elseif isMarkovSwitching
            goThrough = {'variables','shocks','regime_probabilities','state_probabilities'};
        else
            goThrough = {'variables','shocks'};
        end
        if isNB(obj) && strcmpi(type,'filtered')
            goThrough = [goThrough(1),goThrough(3:end)];
        elseif isa(obj,'nb_mfvar') && strcmpi(type,'updated')
            goThrough = goThrough(1);
        end
    end
    if isNB(obj) 
        if isa(obj,'nb_dsge')
            if obj.options.stochasticTrend
                goThrough = [goThrough,'steadyState','parameters'];
            end
        end
    end
    data = [];
    vars = {};
    if isempty(inputs.pages)
        indP = 1:size(filtered.variables.data,3);
    else
        indP = inputs.pages(:);
    end
    for ii = 1:length(goThrough)
        
        filtT = filtered.(goThrough{ii});
        if strcmpi(goThrough{ii},'shocks')
            if normalize && ~needNotBeNormalized
                vcv = obj.estOptions.M_.Sigma_e;
                if ~isfield(obj.solution,'CE')
                    sig  = diag(vcv);
                    indS = sig ~= 0;
                    res  = obj.solution.res(indS);
                else
                    res = obj.solution.res;
                end
                [~,ind]      = ismember(res,obj.estOptions.M_.exo_names);
                vcv          = transpose(chol(vcv(ind,ind)));
                dataT        = filtT.data(:,:,1); 
                dataT(:,ind) = dataT(:,ind)/vcv;
                data         = [data,dataT]; %#ok<AGROW>
                vars         = [vars,filtT.variables]; %#ok<AGROW>
            else
                if realTime
                    nAnt = size(filtT.data,3);
                    data = [data,filtT.data(:,:)]; %#ok<AGROW>
                    newV = [filtT.variables,nb_cellstrlead(filtT.variables,nAnt-1,'varFast')];
                    vars = [vars,newV]; %#ok<AGROW>
                else
                    data = [data,filtT.data(:,:,indP)]; %#ok<AGROW>
                    vars = [vars,filtT.variables]; %#ok<AGROW>
                end
            end
        elseif strcmpi(goThrough{ii},'regime_probabilities') 
            data = [data,permute(filtT.data,[1,3,2])]; %#ok<AGROW>
            vars = [vars,goThrough(ii)]; %#ok<AGROW>
        elseif strcmpi(goThrough{ii},'state_probabilities')
            data = [data,filtT.data(:,:,ones(1,length(indP)))]; %#ok<AGROW>
            vars = [vars,filtT.variables]; %#ok<AGROW>
        else
            data = [data,filtT.data(:,:,indP)]; %#ok<AGROW>
            vars = [vars,filtT.variables]; %#ok<AGROW>
        end
        
    end
    
    if econometricians && isMarkovSwitching
        % Get econometricians view of the smoothed variables
        indR  = find(strcmpi('regime_probabilities',vars));
        sVars = vars(indR+1:end);
        sData = data(:,indR+1:end,1);
        vars  = vars(1:indR-1);
        rData = data(:,indR,:);
        data  = data(:,1:indR-1,:);
        dataT = zeros(size(data,1),size(data,2));
        for ii = 1:size(data,3)
            dataT = dataT + bsxfun(@times,data(:,:,ii),rData(:,:,ii));
        end
        data = [dataT,sData];
        vars = [vars,sVars];
        data = nb_ts(data,'',obj.results.filterStartDate,vars);
        if isMarkovSwitching
            data.dataNames = {'Econometricians'};
        end
    else
        data = nb_ts(data,'',obj.results.filterStartDate,vars);
        if isMarkovSwitching
            data.dataNames = filtered.regime_probabilities.variables;
        end
    end
    
    % Add recursive dates as pages
    if ~isMarkovSwitching
        estOpt = obj.estOptions(end);
        if isfield(estOpt,'recursive_estim')
            if estOpt.recursive_estim
                dataStart      = nb_date.date2freq(estOpt.dataStartDate);
                recDates       = dataStart.toDates(estOpt.recursive_estim_start_ind-1:estOpt.estim_end_ind-1);
                if length(recDates) == data.numberOfDatasets
                    data.dataNames = recDates';
                end
            end
        end
    end
    
    if strcmpi(inputs.reporting,'stored')
        inputs.reporting = obj.reporting;
    end
    if ~isempty(inputs.reporting)
        data = append(data,obj.options.data);
        data = createVariable(data,inputs.reporting(:,1)',inputs.reporting(:,2)',[],'overwrite',true);
    end
    
end
