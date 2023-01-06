function obj = setPrior(obj,prior)
% Syntax:
%
% obj = setPrior(obj,prior)
%
% Description:
%
% Set priors of a vector of nb_dsge objects. The prior input must either
% be a struct or nb_struct with same size as obj or have size 1.
% 
% The provided struct will be added to the property options as the field
% prior. 
%
% The supported prior distributions for the NB Toolbox are:
% - For backing out from mean and std. See the mean and variance 
%   only supported distribution listed in the static method
%   nb_distribution.parametrization.
% - For the parametrized prior distribution option see the
%   help on the type property of the nb_distribution class, as
%   well as the help on the parameters property for how many
%   parameters each distribution takes.
%
% Caution : If no priors are set maximum likelihood is done when the
%           estimate method is called. Initial values must then be set by 
%           the nb_model_generic.assignParameters method. 
%
% Input:
% 
% - obj   : A vector of nb_dsge objects.
%
% - prior : One of;
%
%   > A struct or a nb_struct with either matching numel of  
%     obj or size 1. If size is 1 all models gets the same prior 
%     settings.
%
%     For each element of the struct array:
%     > The fieldnames should be names of the parameters to estimate.
%     > The fields must be one of the following:
%
%       * Uniform prior:
%         {startValue,lowerBound,upperBound}
%       * Prior distribution backed out from mean and standrard 
%         deviation:
%         {startValue,priorMean,priorSTD,'distribution'}
%       * Same as above, but adds a lower bound to the prior
%         distribution:
%         {startValue,priorMean,priorSTD,'distribution',lowerBound}
%       * Same as above, but adds a upper bound to the prior distribution:
%         {startValue,priorMean,priorSTD,'distribution',lowerBound,...
%          upperBound}
%       * Parametrized prior distribution:
%         {startValue,parameters,'distribution'}
%       * Same as above, but adds a lower bound to the prior distribution:
%         {startValue,parameters,'distribution',lowerBound}
%       * Same as above, but adds a upper bound to the prior distribution:
%         {startValue,parameters,'distribution',lowerBound,upperBound}
%         where parameters is a 1 x nParam cell array given as the
%         parameters of the selected distribution.
%
%     > To estimate the the timing of break point use 'break_dateOfBreak' 
%       as the fieldname and the field on the the following syntax:
%       {lowerBound,upperBound}
%       where both lowerBound and upperBound either must be a date as
%       string or a nb_date object. Example: 
%       prior.break_2001Q1 = {'1999Q1','2001Q1'};
%
%   > A nParam x 1 nb_distribution object. Set the name property of the
%     nb_distribution objects to link it to a parameter and use the
%     userData property to set the starting value of the optimization (if
%     it is empty it will use the prior mean as the starting value).
% 
% Output:
% 
% - obj   : A vector of nb_dsge objects with the priors set.
%
% See also:
% nb_model_generic.assignParameters, rise_generic.setup_priors,
% nb_model_estimate.set
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nb_isempty(prior)
        return
    end

    if isa(prior,'nb_distribution')
        if ~all(isNB(obj(:)))
            error([mfilename ':: Cannot set the prior to a nb_distribution object when the model is not parsed with the NB Toolbox.'])
        end
        obj = setPriorWhenNBDistribution(obj,prior);
        return
    elseif isa(prior,'nb_struct')
        prior = get(prior); % Convert to struct
    end
    prior = prior(:);
    obj   = obj(:);
    nobj  = size(obj,1);
    if numel(prior) == 1
        for ii = 1:nobj
           obj(ii) = setOneObj(obj(ii),prior);
        end
    elseif numel(prior) == nobj
        for ii = 1:nobj
           obj(ii) = setOneObj(obj(ii),prior(ii));
        end
    else
       error([mfilename ':: The prior input does not match the number of models in the vector of ' class(obj) ' models.']) 
    end

end

%==========================================================================
function obj = setOneObj(obj,prior)

    if ~isNB(obj)
        error([mfilename ':: Cannot set priors of a model which is not parsed with NB toolbox.'])
    end

    % Initial checks
    estimated  = fieldnames(prior);
    param      = obj.parameters;
    paramInUse = param.name(param.isInUse);
    if obj.isBreakPoint
        breakParams = nb_dsge.getBreakPointParameters(obj.parser,false);
        breakDates  = nb_dsge.getBreakTimingParameters(obj.parser,false);
        paramInUse  = [paramInUse;breakParams;breakDates];  
    end
    test = ismember(estimated,paramInUse);
    if ~any(test)
        error([mfilename ':: The following parameters are not part of the model and can therefore not be estimated: ' toString(estimated(~test))])
    end
    
    % Interpret priors
    priorOut = cell(length(estimated),4);
    for ii = 1:length(estimated)
        priorOut(ii,:) = setOnePrior(obj,prior.(estimated{ii}),estimated{ii});
    end

    % Assign to object
    obj.options.prior = priorOut; 

end

%==========================================================================
function priorOut = setOnePrior(obj,prior,name)

    err = [mfilename ':: The prior settings given to the parameter ' name];
    if ~iscell(prior)
        error([err ' must be a cell array.'])
    end
    [r,c] = size(prior);
    if r > 1
        if c > 1
            error([err ' is not a vector.'])
        else
            prior = prior';
            c     = r;
        end
    end
    
    if c < 3
        priorOut = setTimingOfBreak(obj,prior,name);
        return
    elseif c < 2
        error([err ' does not have enough columns. Needs at least 2 and has ' int2str(c) '.'])
    end
    startValue = prior{1};
    if ~nb_isScalarNumber(startValue)
        error([err ' is wrong. The first element must be the initial value, but it is not a number.'])
    end
    prior2 = prior{2};
    if iscell(prior2)
        priorOut = setOneParametrizedPrior(prior,name,c,err);
    else
        priorOut = setOneMeanSTDPrior(prior,name,c,err);
    end
    
end

%==========================================================================
function priorOut = setOneParametrizedPrior(prior,name,c,err)

    if c > 5
        error([err ' has to many columns for using a parametrized prior. Max is 5 and is ' int2str(c) '.'])
    end
    appended = {};
    if c < 5
        appended = {nan};
        if c < 4
            appended = [{nan},appended];
            if nargin < 3
                error([err ' must have at least 3 columns when using a parametrized prior; {startValue,parameters,''distribution''}.'])
            end
        end
    end
    prior       = [prior,appended];
    priorOut    = cell(1,4);
    priorOut{1} = name;
    startValue  = prior{1};
    dist        = prior{3};
    if c == 3
        func   = str2func(['@nb_distribution.' dist]); 
        inputs = prior{2};
    else
        
        % Bounds are given
        lowerB = prior{4};
        if ~isempty(lowerB)
            if ~nb_isScalarNumber(lowerB)
                error([err ' has not been supplied a proper lower bound.'])
            end
            if isnan(lowerB)
                lowerB = [];
            end
        end
        upperB = prior{5};
        if ~isempty(upperB)
            if ~nb_isScalarNumber(upperB)
                error([err ' has not been supplied a proper upper bound.'])
            end
            if isnan(upperB)
                upperB = [];
            end
        end
        if isempty(lowerB) && isempty(upperB)
            func   = str2func(['@nb_distribution.' dist '_pdf']); 
            inputs = prior{2};
        else
            func   = @nb_distribution.truncated_pdf;  
            inputs = {dist,prior{2},lowerB,upperB};
        end
        
    end
    
    try % Test prior
        func(startValue,inputs{:});
    catch Err
        nb_error([err ' cannot be evaluated at the initial value.'],Err)
    end
    
    priorOut{2} = startValue;     
    priorOut{3} = func;
    priorOut{4} = inputs;
    
end

%==========================================================================
function priorOut = setOneMeanSTDPrior(prior,name,c,err)

    if c > 6
        error([err ' has to many columns for using a prior backed out from mean and STD. Max is 6 and is ' int2str(c) '.'])
    end
    startValue  = prior{1};
    priorOut    = cell(1,4);
    priorOut{1} = name;
    
    appended = {};
    if c < 6
        appended = {nan};
        if c < 5
            appended = [{nan},appended];
            if c < 4
                if c < 3
                    error([err ' must have at least 3 columns when using a parametrized prior; {startValue,parameters,''distribution''}.'])
                else
                    % Uniform prior
                    func   = @nb_distribution.uniform_pdf;
                    inputs = [prior(2),prior(3)];                   
                    try % Test prior
                        func(startValue,inputs{:});
                    catch Err
                        nb_error([err ' cannot be evaluated at the initial value.'],Err)
                    end
                    priorOut{2} = startValue;     
                    priorOut{3} = func;
                    priorOut{4} = inputs;
                    return
                end
            end
        end
    end
    prior = [prior,appended];
    
   
    me = prior{2};
    if ~nb_isScalarNumber(me)
        error([err ' has not been supplied a proper mean.'])
    end
    
    std = prior{3};
    if ~nb_isScalarNumber(me)
        error([err ' has not been supplied a proper standard deviation.'])
    end
    v = std^2;
    
    dist = lower(prior{4});
    if strcmpi(dist,'inv_gamma')
        dist = 'invgamma';
    end
    lowerB = prior{5};
    if ~isempty(lowerB)
        if ~nb_isScalarNumber(lowerB)
            error([err ' has not been supplied a proper lower bound.'])
        end
        if isnan(lowerB)
            lowerB = [];
        end
    end
    
    upperB = prior{6};
    if ~isempty(upperB)
        if ~nb_isScalarNumber(upperB)
            error([err ' has not been supplied a proper upper bound.'])
        end
        if isnan(upperB)
            upperB = [];
        end
    end
    
    [~, inputs] = nb_distribution.parametrization(me,v,dist);
    func        = str2func(['@nb_distribution.' dist '_pdf']);
    if ~isempty(lowerB) || ~isempty(upperB)
        func   = @nb_distribution.truncated_pdf;  
        inputs = {dist,inputs,lowerB,upperB};
    end
   
    try % Test prior
        func(startValue,inputs{:});
    catch Err
        nb_error([err ' cannot be evaluated at the initial value.'],Err)
    end
    
    priorOut{2} = startValue;     
    priorOut{3} = func;
    priorOut{4} = inputs;

end

%==========================================================================
function obj = setPriorWhenNBDistribution(obj,prior)

    if numel(obj) > 1
        obj = nb_callMethod(obj,@setPriorWhenNBDistribution,@nb_dsge,prior);
        return
    end

    % Initial checks
    prior      = prior(:);
    estimated  = {prior.name};
    param      = obj.parameters;
    paramInUse = param.name(param.isInUse);
    test       = ismember(estimated,paramInUse);
    if ~any(test)
        error([mfilename ':: The following parameters are not part of the model and can therefore not be estimated: ' toString(estimated(~test))])
    end
    
    % Interpret priors
    priorOut = cell(length(estimated),4);
    for ii = 1:length(estimated)
        priorOut(ii,:) = setOnePriorDistribution(prior(ii));
    end

    % Assign to object
    obj.options.prior = priorOut; 

end

%==========================================================================
function priorOut = setOnePriorDistribution(prior)

    priorOut   = cell(1,4);
    name       = prior.name;
    startValue = prior.userData;
    err        = [mfilename ':: The nb_distribution object given to the parameter ' name];
    if isempty(startValue)
        startValue = mean(prior);
    elseif ~nb_isScalarNumber(startValue)
        error([err ' has not been assign a valid starting value (stored in the userData property). Is ' class(startValue)...
                   ', but must be a scalar double.'])
    end
    
    priorOut{1} = name;
    priorOut{2} = startValue;
    
    % Get the function handle
    ms = prior.meanShift;
    lb = prior.lowerBound;
    ub = prior.upperBound;
    if ~isempty(ms)
        func   = @nb_distribution.meanshift_pdf;
        inputs = {prior.type,prior.parameters,lb,ub,ms};
    else
        if isempty(lb) && isempty(ub)
            func   = str2func(['@nb_distribution.' prior.type '_pdf']);
            inputs = prior.parameters;
        else
            func   = @nb_distribution.truncated_pdf;
            inputs = {prior.type,prior.parameters,lb,ub};
        end
    end
    priorOut{3} = func;
    priorOut{4} = inputs;
    
    
end

%==========================================================================
function priorOut = setTimingOfBreak(obj,prior,name)

    % Get bound
    breakD = nb_dsge.getBreakTimingParameters(obj.parser,false);
    ind    = strcmp(name,breakD);
    if any(~ind)
        error([mfilename ':: The prior settings given to the parameter ' name,...
            ' must have at least 3 columns as long as it is not a prior for the ',...
            'timing of a break point.']);
    end
    init = obj.parser.breakPoints(ind).date;
    try
        lb = nb_date.toDate(prior{1},init.frequency);
    catch
        error([mfilename ':: The lower bound given to the prior of the timing of the break ' toString(init),...
            ' must be a date on the frequency ' nb_date.getFrequencyAsString(init.frequency) '.'])
    end
    lb = lb - init;
    if lb > 0
        error([mfilename ':: The lower bound given to the prior of the timing of the break ' toString(init),...
            ' must be lower than ' toString(init) '.'])
    end
    
    try
        ub = nb_date.toDate(prior{2},init.frequency);
    catch
        error([mfilename ':: The upper bound given to the prior of the timing of the break ' toString(init),...
            ' must be a date on the frequency ' nb_date.getFrequencyAsString(init.frequency) '.'])
    end
    ub = ub - init;
    if ub < 0
        error([mfilename ':: The upper bound given to the prior of the timing of the break ' toString(init),...
            ' must be lower than ' toString(init) '.'])
    end

    % Setup prior:
    % Here we specify a continous uniform distribution, but when the value
    % is assign to the break we use the round function. As a result we  
    % must add 0.499 to each side to make it as likely to pick the end 
    % points
    priorOut    = cell(1,4);
    priorOut{1} = name;
    priorOut{2} = 0;
    priorOut{3} = @nb_distribution.uniform_pdf;
    priorOut{4} = {lb - 0.499,ub + 0.499}; 

end
