function obj = filter(obj,varargin)
% Syntax:
%
% obj = filter(obj,varargin)
%
% Description:
%
% Run the kalman filter on the DSGE model.
%
% Caution : The data field of the options property must include all the
%           observables of the model.
% 
% This method uses the RISE filter if the nb_dsge model represent a
% RISE object, and it uses the dynare developed filter if the underlying
% object is a dynare solved DSGE model (not supported in all versions of 
% the NB toolbox). All credits should go to the authors of those codes in
% these cases.
%
% Caution: Use obj = set(obj,'data',data) to assign the data on the
%          observables.
%
% Input:
% 
% - obj : An object of class nb_dsge
%
% Optional Inputs:
%
% - varargin : Will depend on the underlying software used:
%
%   > All:
%
%     - 'variables'           : A cellstr with the endogenous variables to
%                               store. Are you going to do shock
%                               decomposition you need all!
%
%     - 'startDate'           : Start date of filtering, as a string or a
%                               nb_date object. Defualt is the start date
%                               of the options.data property.
%
%     - 'endDate'             : End date of filtering, as a string or a
%                               nb_date object. Defualt is the end date
%                               of the options.data property.
%
%   > NBTOOLBOX:
%
%     - 'kf_init_variance'    : See nb_dsge.help('kf_init_variance'). 
%                               Default is given by the option 
%                               'kf_init_variance'.
%                               
%     - 'kf_kalmanTol'        : See nb_dsge.help('kf_kalmanTol'). Default 
%                               is given by the option 'kf_kalmanTol'. 
%
%     - 'kf_method'           : See nb_dsge.help('kf_method'). Default is 
%                               given by the option 'kf_method'. 
%
%     - 'kf_warning'          : See nb_dsge.help('kf_warning'). Default is 
%                               given by the option 'kf_warning'. 
%
%     - 'smoother'            : true or false. If false only the
%                               filter is ran. Default is true.
%
%     - 'shockProps'          : A 1 x nRes struct with fields:
%   
%                               > Name    : The name of the shock/residual   
%                                           to use to match the conditional 
%                                           information. If an 
%                                           shock/residual is not 
%                                           included here, it means that 
%                                           it is not anticipated. I.e
%                                           all shocks/resiudals not 
%                                           provided by this input has 
%                                           anticipated horizon set to 1, 
%                                           which means that only
%                                           contemporaneous  
%                                           shocks/residuals are seen.
%
%                               > Horizon : Anticipated horizon of the 
%                                           shocks/residual. 1 is default.
%
%   > RISE (Must be added separatly):
%
%     - 'kf_ergodic'          : Initialization at the ergodic distribution. 
%                               True or false. true is default.
%
%     - 'kf_init_variance'    : Initial variance factor (Harvey scale 
%                               factor). If not empty, the information in 
%                               T and R is ignored. Either empty or an
%                               integer.
%
%     - 'kf_user_init'        : As a cell. User-defined initialization. 
%                               When not empty, it can take three forms. 
%                               {a0}, {a0,cov_a0}, {a0,cov_a0,PAI00} where
%                               a0 is the initial state vector with the
%                               same order as the rows of T, cov_a0 is the 
%                               initial covariance of the state vector
%                               (same order as a0) and PAI00 is the initial 
%                               vector of regime probabilities. Default is
%                               {}.
%
%     - 'kf_householder_chol' : If true, return the cholesky decomposition
%                               when taking the householder transformation. 
%                               This option is primarily used in the 
%                               switching divided difference filter.
%                               Default is false.
% 
%   > Dynare (May not be supported in all version of NB toolbox):
%
%     - 'diffuse_filter'      : Either 0 or 1. See dynare documentation. 
%
%     - 'lik_init'            : An integer between 1 and 3. See dynare
%                               documentation.
%
%     - 'kalman_algo'         : An integer between 1 and 4. See dynare
%                               documentation.
%
%     - 'Harvey_scale_factor' : See 'kf_init_variance' above.
%
%     Caution : If not provided (or empty) the default is to use the
%               settings return while running dynare.
%
% Output:
% 
% - obj : The results will be saved to the results property:
%
%         A struct with the filtering of each model stored in separate
%         fields. Each field for each model then consist of a struct with
%         the follwing fields:
%
%         > 'smoothed'   : A struct consisting of fields of struct objects
%                          storing the smoothed estimates.
%
%         > 'filtered'   : A struct consisting of fields of struct objects
%                          storing the filtered estimates.
%
%         > 'updated'    : A struct consisting of fields of struct objects
%                          storing the updated estimates.
%
%         > 'likelihood' : The log likelihood. Only return when RISE is
%                          used.
%
% See also:
% dsge.smoother, dsge.filter, nb_dynareSmoother
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Parse optional inputs
    opt = obj.options;
    opt = nb_defaultField(opt,'kf_warning',false);
    default = {'condDB',                [],                   {{@isa,'nb_data'},'||',@isempty};...
               'diffuse_filter',        [],                   {{@ismember,{0,1,true,false,[]}}};...
               'endDate',               '',                   {@ischar,'||',{@isa,'nb_date'}};...
               'Harvey_scale_factor',   [],                   {@isnumeric,'||',@isempty};...
               'kalman_algo',           [],                   {{@ismember,{1,2,3,4,[]}}};...
               'kf_householder_chol',  	false,                {@islogical,'||',@isnumeric};...
               'kf_user_init',          {},                   @iscell;...
               'kf_init_variance',      opt.kf_init_variance, {@isnumeric,'||',@isempty};...
               'kf_ergodic',            true,                 {@islogical,'||',@isnumeric};...
               'kf_kalmanTol',          opt.kf_kalmanTol,     {@islogical,'||',@isnumeric};...
               'kf_method',             opt.kf_method,        {{@ismember,{'normal','diffuse','univariate'}}};...
               'kf_warning',            opt.kf_warning,       @nb_isScalarLogical;...
               'lik_init',              [],                   {{@ismember,{1,2,3,[]}}};...
               'realTime',              false,                {{@ismember,[0,1]}};...
               'shockProps',            [],                   {@isstruct,'||',@isempty};...
               'smoother',              true,                 {{@ismember,[0,1]}};...
               'startDate',             '',                   {@ischar,'||',{@isa,'nb_date'}};...
               'states',                [],                   {@isnumeric,'||',@isempty};...
               'variables',             {},                   @iscellstr};
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end

    % Test stuff
    if isempty(obj.options.data)
        error([mfilename ':: No data to filter. Please set the ''data'' property.'])
    end
    
    if ~isempty(inputs.endDate) && ~isempty(inputs.startDate)
        if ~isa(inputs.endDate,'nb_date')
            inputs.endDate = nb_date.toDate(inputs.endDate,obj.options.data.frequency);
        end
        if ~isa(inputs.startDate,'nb_date')
            inputs.startDate = nb_date.toDate(inputs.startDate,obj.options.data.frequency);
        end
        if inputs.endDate < inputs.startDate
            error([mfilename ':: The selected end date (' toString(inputs.endDate) ') cannot be before the selected start date (' toString(inputs.startDate) ').'])
        elseif inputs.endDate - inputs.startDate < 4
            error([mfilename ':: The selected data sample must at least contain 5 observations (is ' int2str((inputs.endDate - inputs.startDate) + 1) ').'])
        end
    end
    
    % Filter each model at a time
    obj  = obj(:);
    nobj = numel(obj);
    for ii = 1:nobj 
        obj(ii) = filterEngine(obj(ii),inputs);
    end
    
end

%==========================================================================
% SUB
%==========================================================================
function obj = filterEngine(obj,inputs)

    if ~isempty(obj.options.timeVarying)
        if isNB(obj)
            [out,data_nb_ts] = callTVNBFilter(obj,inputs);
        else
            error([mfilename ':: The timeVarying input is only supported for models solved with the NB toolbox.'])
        end   
    else
        if isNB(obj)
            [obj,out,data_nb_ts] = callNBFilter(obj,inputs);
        elseif isRise(obj) 
            [out,data_nb_ts] = callRISEFilter(obj,inputs);
        else % Dynare
            [out,data_nb_ts] = callDynareFilter(obj,inputs);
        end
    end
    
    % Report filtering/estimation dates
    out.filterStartDate = toString(data_nb_ts.startDate);
    out.filterEndDate   = toString(data_nb_ts.endDate);
    out.realTime        = false;

    % Assign the results to the object
    obj.results = out;

    % Many functions later assumes that these fields are filled in
    data                           = obj.options.data;
    obj.estOptions.data            = double(data);
    obj.estOptions.dataVariables   = data.variables;
    obj.estOptions.dataStartDate   = data.startDate;
    obj.estOptions.estim_start_ind = (data_nb_ts.startDate - data.startDate) + 1;
    obj.estOptions.estim_end_ind   = (data_nb_ts.endDate - data.startDate) + 1;
    obj.estOptions.class           = 'nb_dsge';
    obj.options.estim_start_date   = data_nb_ts.startDate;
    obj.options.estim_end_date     = data_nb_ts.endDate;
    
end
