function [obj,valid] = forecast(obj,nSteps,varargin)
% Syntax:
%
% obj         = forecast(obj,nSteps,varargin)
% [obj,valid] = forecast(obj,nSteps,varargin)
%
% Description:
%
% Produced conditional point and density forecast of nb_model_generic 
% objects. 
%
% The conditional forecasting routines in this code is based on work by
% Junior Maih. As in his code it also handle anticipated shocks (only
% for foward looking models!). See Junior Maih (2010), Conditional 
% forecast in DSGE models.
%
% If the 'condDB' input is set to a nb_distribution object the code uses 
% the algorithm given in the paper Kenneth S. Paulsen (2010), Conditional   
% forecasting with DSGE models - A conditional copula approach.
%
% Input:
% 
% - obj        : A vector of nb_model_generic objects. 
% 
% - nSteps     : Number of forecasting steps. As a 1x1 double. Default 
%                is 8.
%
% Optional input:
%
% - 'waitbar'  : Give 'waitbar' anywhere as an optional input to create
%                a waitbar that iterates the models being forecasted.
%
% - 'write'    : Give 'write' anywhere as an optional input to write errors
%                to a file instead of throwing them. This input is not
%                stored to the forecastOutput property of the objects. 
%
% - 'remove'   : Give 'remove' to remove the models that return errors 
%                from the obj output. This input is not stored to the 
%                forecastOutput property of the objects. 
%
% - 'fcstEval' : - ''     : No forecast evaluation. Default
%                - 'se'   : Square error forecast evaluations.
%                - 'abs'  : Absolute forecast error
%                - 'diff' : Forecast error 
%
%                Only for density forecast:
%
%                - 'logScore' : Log score  
%
%                Can also be a cellstr with the above listed evaluation
%                types.
%
%                Caution: If you have done recursive estimation, this
%                         option, if not empty, will do out of sample
%                         forecasting. Else it will do in sample 
%                         forecasting, i.e. use the estimated parameters 
%                         for the whole sample.
%
% - 'estDensity'     : The method to estimate the density. As a string.
%                      Either:
%
%                      - 'normal' : Normal density approximation.
%
%                      - 'kernel' : Kernel density estimation. Default.
%
% - 'varOfInterest'  : A char with the variable to produce the forecast of.
%                      Default is '', i.e. all variables. Can also be given
%                      a cellstr with the variables to forecast. Variables
%                      provided which is not part of the model will be
%                      discarded and no error will be given! 
%
% - 'parallel'       : Give true if you want to do the forecast in 
%                      parallel. I.e. spread models to different threads.
%                      Default is false.
%
% - 'cores'          : The number of cores to open, as an integer. Default
%                      is to open max number of cores available. Only an 
%                      option if 'parallel' is set to true. 
%
% - 'parameterDraws' : Number of draws of the parameters. When set to 1
%                      it will discard parameter uncertainty. Default is 1.
%
% - 'draws'          : Number of residual/innovation draws per parameter
%                      draw. Default is 1, i.e. only produce point 
%                      forecast.
%
% - 'regimeDraws'    : Number of drawn regime paths when doing density
%                      forecast. This will have no effect if the states
%                      input is providing the full path of regimes. Default
%                      is 1.
%
% - 'newDraws'       : When out of parameter draws, this factor decides how
%                      many new draws are going to be made. Default is 0.1.
%                      I.e. 1/10 of the parameterDraws input. 
%
% - 'perc'           : Error band percentiles. As a 1 x numErrorBand 
%                      double. E.g. [0.3,0.5,0.7,0.9]. Default is 0.9.
%
%                      If set to empty, all simulations will be returned.
%
%                      Caution: 'draws' must be set to produce density
%                               forecast.
%
% - 'method'         : The selected method to create density forecast.
%                      Default is ''. See help on the method input of the
%                      nb_model_generic.parameterDraws method for more 
%                      this input.
%
% - 'bins'           : The length of the bins og the domain of the density.
%                      Either;
%      
%                      > []    : The domain will be found. See 
%                                nb_getDensityPoints (default is that 1000
%                                observations of the density is stored).
%
%                      > integer : The min and max is found but the length
%                                  of the bins is given by the provided
%                                  integer.
%
%                      > cell    : Must be on the format:
%
%                                  {'Var1',lowerLimit1,upperLimit1,binsL1;
%                                   'Var2',lowerLimit2,upperLimit2,binsL2;
%                                   ...}
%
%                                  - lowerLimit1 : An integer, can be nan,
%                                                  i.e. will be found.
%
%                                  - upperLimit1 : An integer, can be nan,
%                                                  i.e. will be found.
%
%                                  - binsL1      : An integer with the 
%                                                  length of the bins. Can
%                                                  be nan. I.e. bins length
%                                                  will be adjusted to
%                                                  create a domain of 1000
%                                                  elements.
%
%                      Caution : The variables not included will be given
%                                the default domain. No warning will be
%                                given if a variable is provided in the
%                                cell but not forecast by the model. (This 
%                                because different models can forecast 
%                                different variables)
%
%                      Caution : The combineForecast  method of the
%                                nb_model_group class is much faster if the
%                                lower limit, upper limit! Or else 
%                                it must simulate new draws and do kernel
%                                density estimation for each model again
%                                with the shared domain of all models
%                                densities.
%
% - 'startDate'      : The start date of forecast. Must be a string or an
%                      object of class nb_date. If empty the estim_end_date
%                      + 1 will be used.
%
%                      Caution: If 'fcstEval' is not empty this will set
%                               the start date of the recursive forecast. 
%                               Default is to start from the first possible 
%                               date.
%
% - 'endDate'        : The end date of forecast. Must be a string or an
%                      object of class nb_date. If empty the estim_end_date
%                      + 1 will be used.
%
%                      Caution: If 'fcstEval' is empty this input will 
%                               have nothing to say.
%
% - 'saveToFile'     : Logical. Save densities and domains to files. One 
%                      file for each model. Default is false (do not).
%
% - 'observables'    : A cellstr with the observables you want the
%                      forecast of. Only for factor models. Will be
%                      discared for all other types of models.
%
% - 'condDB'         : One of the following:
%
%                      > A nb_ts object with size nSteps x nCondVar    
%                        with the information to condition on.
%
%                        If you condition on endogenous variables (possibly 
%                        residuals/shocks also) this function will find  
%                        the linear combination of the shock that minimize 
%                        its variance.
%
%                      > A nb_data object with size nSteps x nCondVar x    
%                        nPeriods with the information to condition on.
%                        The dataNames property must be set to the start
%                        dates of the recursive conditional information.
%                        nPeriods will be the number of recursive 
%                        periods.
%                        
%                      > A nb_ts object with size nSteps x nCondVar x 3   
%                        with the information to condition on. Page 2 must   
%                        include the upper bound and page 3 the lower bound   
%                        of the truncated normal distribution for the given 
%                        conditional information. Both bound can be given 
%                        as nan (-inf or inf). Be aware that it is also 
%                        possible to use truncated distribution with the 
%                        next input type, but that the algorithm used by 
%                        this options is much faster. (Of cource here all  
%                        conditional information must be either normal or 
%                        truncated normal.)
%
%                      > A nb_distribution object with size nSteps x   
%                        nCondVar x 1 with the distributions to condition 
%                        on. The defualt is to assume that the shock are
%                        iid with mean = 0 and std = sqrt(diag(model.vcv))
%
%                        If you condition on endogenous variables (possibly 
%                        residuals/shocks also) this function will find the  
%                        linear combination of the shock that minimize its 
%                        variance for each draw from the multivariate 
%                        distribution created by using a copula with the 
%                        provided marginals and the correlation matrix 
%                        (See inputs.sigma).           
% 
%                      All the variables in the x_t matrix must be provided. 
%                      I.e. model.exo variables. (Except seasonals,   
%                      constant and time-trend). The data  must be ordered  
%                      accordingly to condDBVars (second dimension), and  
%                      the first observation is taken to be startInd, as
%                      long as the input is not nb_ts or nb_data.
%                
%                      To be able to match your restrictions on endogenous
%                      variables to a specified group of shock use the 
%                      shockProps input.
%
%                      Caution : If empty unconditional forecast will be 
%                                produced.
%
% - 'condDBVars'     : A cellstr with the variables to condition on. Can 
%                      include both endogenous, exogenous and shock 
%                      variables. Only needed when condition on a
%                      nb_distribution object.
%
% - 'condDBStart'    : Do the conditional information contain intial values
%                      or not. Set to 0 to indicate that the conditional 
%                      information also contain inital values. In this case
%                      all variables that have missing observation for the
%                      initial values are replaced with the data
%                      supplied by the condDB input. Otherwise the
%                      estimated initial observations for missing data is
%                      used (default).
%
% - 'shockProps'     : A 1 x nRes struct with fields:
%   
%                      > Name              : The name of the shock/residual   
%                                            to use to match the 
%                                            conditional information. If an 
%                                            shock/residual is not 
%                                            included here, it means that 
%                                            it is not activated.
%
%                      > StandardDeviation : Standard deviation of the 
%                                            shock. This option can be used 
%                                            to adjust the standard 
%                                            deviation away from the 
%                                            estimated one. If given as nan 
%                                            the estimated one is used.
%
%                                            Caution: If a shock is
%                                            included in the condDB input, 
%                                            and it is a nb_distribution
%                                            object. The std is taken from
%                                            that distribution instead.
%
%                                            If not provided. Model stds
%                                            are used.
%
%                      > Horizon           : Anticipated horizon of the 
%                                            shocks/residual. 1 is default.
%
%                      > Periods           : The active periods of the  
%                                            shocks/residual. If nan, the   
%                                            shocks/residual is active for 
%                                            all periods. Must be given!
%
% - 'kalmanFilter'   : Set to true to use a Kalman filter to do conditional
%                      forecasting (on endogenous variables). Only
%                      supported for the nb_var and nb_pitvar classes.
%
% - 'sigma'          : A nCondVar*nSteps x nCondVar*nSteps double with the 
%                      correlation matrix of the endogneous variables to  
%                      condition on. Used when drawing from the copula.
%
%                      This must be the stacked autocorrelation matrix
%                      of the multivariate distribution to draw the
%                      endogenous variables from. As the endogneous
%                      variables are autocorrelated all variables for all
%                      periods must be draw at the same time, using this
%                      autocorrelation matrix. 
%
% - 'sigmaType'      : Type of correlation calculated. For more on this
%                      input see nb_copula.type.
%
% - 'output'         : Either 'endo' (default), 'fullendo' or 'all'. This 
%                      input indicates which variables to return the 
%                      simulation of. 
%
%                      > 'endo'     : All the endogenous variables are 
%                                     returned.
%
%                      > 'fullendo' : All the endogenous variables are 
%                                     returned included the lag variables.
%
%                      > 'full'     : All the variables are returned
%                                     included the lag variables. Also  
%                                     including exogenous and shocks.
%
%                      > 'all'      : All variables are returned (but not 
%                                     the lags). Including exogenous and 
%                                     shocks.
%    
% - 'startingValues' : Either a double or a char:
%
%                      This option is mainly used for making simulations
%                      from a model.
%
%                      > double        : A nPeriods x nVar or a 1 x nVar 
%                                        double. nPeriods refer to the 
%                                        number of recursive periods to 
%                                        forecast. 
%
%                      > 'mean'        : Start from the mean of the data
%                                        observations. Default.
%
%                      > 'steadystate' : Start from the steady state. For 
%                                        now only an option for nb_dsge
%                                        models. If you are dealing with a
%                                        MS-model or break-point model you 
%                                        can indicate the regime by 
%                                        'steadystate(regime)'. E.g. to 
%                                        start in regime 1 give; 
%                                        'steadystate(1)'. If the regime 
%                                        is not given, you will start in 
%                                        the ergodic steady-state for 
%                                        MS-model, and in the last regime
%                                        for break-point models.
%
%                      > 'zero'        : Start from zero on all variables
%                                        (Except for the deterministic 
%                                        exogenous variables)
%
% - 'startingProb'   : Either a double or a char:
%
%                      > []            : If the model is filtered the
%                                        starting value is calculated
%                                        on filtered transition
%                                        probabilities. Otherwise the
%                                        ergodic mean is used.
%
%                      > double        : A nPeriods x nRegime or a 1 x  
%                                        nRegime double. nPeriods refer to  
%                                        the number of recursive periods to 
%                                        forecast. 
%
%                      > 'ergodic'     : Start from the ergodic transition 
%                                        probabilities.
%
% - 'stabilityTest'  : Give true if you want to discard the parameter draws 
%                      that give rise to an unstable model. Default
%                      is false.
%
% - 'states'         : Either an integer with the regime to 
%                      forecast/simulate in, or an object of class nb_ts  
%                      with the regimes to condition on. The name of the  
%                      variable must be 'states'. 
%
%                      Caution: For break-point models this is decided by
%                               the dates of the breaks, and cannot be set
%                               by this option!
%
% - 'compareToRev'   : Which revision to compare to. Default is final
%                      revision, i.e. []. Give 5 to get fifth revision.
%                      must be an integer. Keep in mind that this number 
%                      should be larger than the nSteps input.
%
% - 'compareTo'      : Sometime you want to evaluate the forecast of one
%                      variable against another variable which is not
%                      part of the model. E.g. if you use the first release
%                      of a variable and want to compare it against the
%                      final release. To do this you can give a cellstr
%                      with size n x 2, where n is the number of variables
%                      to change the the actual observations to test
%                      against. {'VAR_1','VAR_FINAL',...}.
%
% - 'estimateDensities' : true or false. true if you want to do a
%                         kernel density estimation of the density
%                         forecast. 
%
% - 'exoProj'        : Tolerate missing exogenous variables by projecting
%                      them by a fitted model. Only when the 'condDB'
%                      input is empty!
%
%                      Options are:
%
%                      - ''   : No projection are done. Error will be
%                               given if some exogneous variables are
%                               not given any conditional information.
%                               Default.
%
%                      - 'ar' : The exogenous variables will be fitted by
%                               a univaiate AR model with the lag length
%                               chosen with a 'aicc' criterion.
%
%                               Caution : If density forecast are produced 
%                                         the AR estimates will be 
%                                         bootstrapped, and the exogenous 
%                                         variables will be re-sampled 
%                                         based on the bootstrapped values.
%
%                               Caution : If forecast are beeing produced 
%                                         recursivly with recursivly 
%                                         estimated parameters, the 
%                                         forecast/bootstrapping of the 
%                                         exogenous variables will be done 
%                                         based on recursivly estimated AR 
%                                         cofficients as well.
%
% - 'exoProjHist'    : If this option is set to true, it will first try to
%                      get the data on the exogenous variables for the full
%                      forecast horizon from the data assign to the model 
%                      object. If the data is not found it will 
%                      extrapolate the exogenous variables by the 
%                      method given to the 'exoProj' option.
%
% - 'exoProjDiff'    : Set to a cell array on the format {'Var1',1,
%                      'Var2',1} to apply 1st difference to the series
%                      'Var1' and 'Var2'. If a variable is not given a
%                      value it is not 1st differences (or the value is 
%                      set to 0).
%
%                      Caution: Only applies to the nb_exprModel class.
%
% - 'exoProjAR'      : Set the number of lags of the AR(X) models when
%                      exogenous variables are projected, i.e. set X.
%                      Default is nan, i.e. a information criterion is used
%                      to select the number of lags (Set this option to 
%                      nan).
%
%                      Caution: Only applies when exoProj is set to 'AR'.
%
% - 'exoProjDummies' : A cellstr with the dummie variables to include in
%                      the AR model when projecting exogenous variables.
%                      These dummies are assumed to be predicted by 0.
%
%                      Caution: Only applies when exoProj is set to 'AR'.
%
% - 'exoProjCalib'   : Calibrate the AR process to extrapolate the
%                      exogenous variables with. As a 1 x 2*N cell array.
%                      N is equal to the number of exogenous variables
%                      you extrapolate. An example
%                      {'exoVar1',[0,0.8],'exoVar2',[0.2,0.7]}. Here the
%                      'exoVar1' variable is extrapolated with an AR model
%                      with a constant term equal to 0 and AR coefficent
%                      0.8, while 'exoVar2' with a constant term equal to 
%                      0.2 and AR coefficent 0.8. The exogenous variables
%                      not listed will be estimated.
%
%                      Caution: Only applies when exoProj is set to 'AR'.
%
% - 'bounds'         : A struct. Each fieldname must be the name of the
%                      variable to add bounds on. Each field must again be
%                      a struct with the following fields:
%           
%                      - 'shock' : Name of the shock to match the 
%                                  restriction on the bounds of the given
%                                  variable.
%
%                      - 'lower' : The lower bound of the selected
%                                  variable. Either a 1x1 double value
%                                  or a function handle to a probability
%                                  distribution to draw from.
%
%                      - 'upper' : The upper bound of the selected
%                                  variable. Either a 1x1 double value
%                                  or a function handle to a probability
%                                  distribution to draw from.
%
%                      Caution : The function handles must take one input.
%                                I.e. the vector of current observations
%                                of the endogneous variables, as a nVar x
%                                nSteps double matix. For the order of the
%                                variables see; obj.solution.endo. The
%                                value return by the function must be
%                                either a 1x1 double or a nSteps x 1
%                                double.
%
%                      This input can be used to use anticipated shocks
%                      to restrict variables to inside a range. E.g.
%                      effective lower bound on the interest rate.
%
% - 'inputs'         : This is a special input the overwrites all
%                      other inputs. This must be given by a struct with
%                      fields that include all the other optional options.
%
% - 'foundReplic'    : A struct with size 1 x parameterDraws. Each element
%                      must be on the same format as obj.solution. I.e.
%                      each element must be the solution of the model
%                      given a set of drawn parameters. See the 
%                      parameterDraws method of the nb_model_generic class.
%
%                      Caution: You still need to set 'parameterDraws'
%                               to the number of draws you want to do.
%
% - 'condAssumption' : Set to 'after' to make the conditional information
%                      be interpreted in the states simulated or 
%                      conditioned on. Otherwise the conditional 
%                      information is interpreted in the state of end of
%                      history.
%
% - 'seed'           : Set simulation seed. Default is 2.0719e+05.
%
% Output:
%
% - obj    : A vector of nb_model_generic objects. See the property 
%            forecastOutput.
%  
% - valid  : A logical with size nObj x 1. true at location ii if 
%            forecasting of model ii succeded, otherwise false.  If
%            'write' is not used an error will be thrown instead, so
%            in this case this output will be true for all models.
%
% See also:
% nb_model_generic.parameterDraws
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        nSteps = 8;
    end
    
    obj  = obj(:);
    nobj = numel(obj);
    if nobj == 0
        error('Cannot forecast an empty vector of nb_model_generic objects.')
    end
    
    % Get needed information on the models
    opt = cell(1,nobj);
    for ii = 1:nobj
        if isa(obj(ii),'nb_dsge')
            % Secure that all the options are stored in the opt{ii}
            % struct passed to the nb_forecast function
            opt{ii} = createEstOptionsStruct(obj(ii));
        else
            opt{ii} = obj(ii).estOptions;
        end
    end
    sol = {obj.solution};
    res = {obj.results};
    
    % Parse the arguments
    %--------------------------------------------------------------
    [inp,others] = nb_model_generic.parseOptional(varargin{:});
    inp          = nb_logger.openLoggerFile(inp,obj);
    if isempty(inp.inputs)   
        % Default parsing of inputs
        [inputsW,startInd,endInd,condDB,condDBVars,shockProps,cores,opt,inp.inputs] = parseWhenSameInputs(opt,others,nSteps);
    else
        % Parse when inputs differ
        [inputsW,startInd,endInd,condDB,condDBVars,shockProps,cores,opt] = parseWhenDifferentInputs(opt,inp.inputs,nSteps);
    end
    [inputsW(:).waitbar] = deal(inp.waitbar);   
    
    % Matrix on how to transform reporting variables, and shift/trend
    % variables
    reporting              = {obj.reporting};
    [inputsW(:).reporting] = reporting{:};
    for ii = 1:nobj
        if isfield(obj(ii).options,'shift')
            inputsW(ii).shift          = obj(ii).options.shift.data;
            inputsW(ii).shiftVariables = obj(ii).options.shift.variables;
        end
        if ~isempty(reporting{ii})
            if isa(obj(ii),'nb_dsge') || isa(obj(ii),'nb_mfvar')
                opt{ii} = appendSmoothed(obj(ii),opt{ii});
            end
        end
    end

    % Check that the models are solved
    %-----------------------------------
    names = getModelNames(obj);
    for ii = 1:nobj
        if ~isfield(sol{ii},'class')
            error([mfilename ':: ' names{ii} ' is not solved!']);
        end
        cl = sol{ii}.class;
        if any(strcmpi(cl,{'nb_var','nb_favar','nb_pitvar'}))
            condDBVarsM = condDBVars{ii};
            if any(ismember(condDBVarsM,sol{ii}.endo))
                if nb_isempty(sol{ii}.identification) && ~isempty(condDB{ii})
                    error([mfilename ':: ' names{ii} ':: VAR models must be identified to do conditional forecasting!'])
                end
            end
        end
    end

    % Do conditional forecast
    %------------------------------------------------------
    fcst = nb_model_generic.loopForecast(names,sol,opt,res,startInd,endInd,nSteps,inputsW,...
        condDB,condDBVars,shockProps,cores,false,inp);

    % Remove forecasted objects that failed
    %------------------------------------------------------
    valid = ~cellfun(@isempty,fcst)';
    if inp.write
        validObj = obj(valid);
        fcst     = fcst(valid);
    else
        validObj = obj;
    end
    
    % Assign objects
    %------------------------------------------------------
    for ii = 1:length(fcst)

        % Translate start index to dates
        if isa(validObj(ii),'nb_midas')
            startD = nb_date.date2freq(validObj(ii).estOptions.estim_start_date_low) - (validObj(ii).estOptions.start_low_in_low - 1);
        else
            startD = validObj(ii).options.data.startDate;
        end
        if isempty(startD)
            startD = nb_year(1);
        end
        start  = fcst{ii}.start;
        nStart = size(start,2);
        startN = cell(1,nStart);
        for jj = 1:nStart
            startN{jj} = toString(startD + (start(jj) - 1));
        end
        fcst{ii}.start = startN;
        
        % Store the conditional data in the object format
        if ~isempty(condDB{ii})
            if isscalar(inp.inputs)
                fcst{ii}.inputs.condDB     = inp.inputs.condDB;
                fcst{ii}.inputs.condDBVars = inp.inputs.condDBVars;
            else
                fcst{ii}.inputs.condDB     = inp.inputs(ii).condDB;
                fcst{ii}.inputs.condDBVars = inp.inputs(ii).condDBVars;
            end
        end
        
        % Assign to object
        validObj(ii).forecastOutput = fcst{ii};

    end
    
    if inp.remove && inp.write
        obj = validObj;
    else
        obj(valid) = validObj;
    end
            
end

%==========================================================================
function [inputsW,startInd,endInd,condDB,condDBVars,shockProps,cores,opt,inputs] = parseWhenSameInputs(opt,others,nSteps)

    default          = nb_model_generic.defaultInputs(false);  
    [inputs,message] = nb_parseInputs(mfilename,default,others{:});
    if ~isempty(message)
        error(message)
    end

    nobj           = length(opt);
    cores          = inputs.cores;
    inputs         = rmfield(inputs,'cores');
    inputs.density = false; % This option is used by the nb_model_generic.simulate method.

    [startDate,endDate,condDB,condDBVars] = parseConditionalInfo(inputs.startDate,inputs.endDate,nSteps,inputs.condDB,inputs.condDBVars,opt{1});
    shockProps                            = inputs.shockProps;
    if ~isempty(endDate)
        if endDate < startDate
            error([mfilename ':: The forecast start date must come before or be the same as the forecast end date.'])
        end
    end

    % Get start/end index of all model objects
    dates = cell(1,nobj);
    for ii = 1:nobj
        opt{ii} = nb_defaultField(opt{ii},'estimator','');
        if strcmpi(opt{ii}(end).estimator,'nb_midasEstimator')
            dates{ii} = nb_date.date2freq(opt{ii}(end).estim_start_date_low);
        elseif strcmpi(opt{ii}(end).estimator,'nb_tslsEstimator')
            dates{ii} = nb_date.date2freq(opt{ii}.mainEq.dataStartDate);
            opt{ii}   = opt{ii}.mainEq; % TSLS stores things differently
        else
            dates{ii} = nb_date.date2freq(opt{ii}(end).dataStartDate);
        end
    end
    
    if isempty(startDate)
        startInd = cell(1,nobj);
    else
        startInd = cell(1,nobj);
        for ii = 1:nobj
            startInd{ii} = startDate - dates{ii} + 1;
        end
    end

    if isempty(endDate)
        endInd = cell(1,nobj);
    else
        endInd = cell(1,nobj);
        for ii = 1:nobj
            endInd{ii} = endDate - dates{ii} + 1;
        end
    end

    % Check the states input
    if isa(inputs.states,'nb_ts')
        if ~isempty(condDB)
            if inputs.states.startDate > condDB.startDate 
                error([mfilename ':: The provided start date of the states input is to late.'])
            end
            if inputs.states.endDate < condDB.endDate
                error([mfilename ':: The provided end date of the states input is to short.'])
            end
            inputs.states = double(window(inputs.states,condDB.startDate,condDB.endDate,{'states'}));
        else
            inputs.states = double(inputs.states);
        end  
        inputs.states = inputs.states(1:nSteps,:);
    end
    
    % Get the inputs for each model (used by saving and waitbar)
    if isempty(inputs.nObj)
        inputs.nObj = nobj;
    end
    if isempty(inputs.index)
        inputs.index = 1;
        given        = false;
    else
        given = true;
    end
    inputs.reporting = {};
    inputsW          = rmfield(inputs,{'condDB','condDBVars'});
    inputsW          = inputsW(:,ones(1,nobj));

    if given
        cNobj = num2cell(ones(1,nobj)*inputsW.index);
    else
        cNobj = num2cell(1:nobj);
    end
    [inputsW(:).index] = cNobj{:};

    % Replicate some inputs 
    condDB     = {condDB};
    condDB     = condDB(:,ones(1,nobj));
    condDBVars = {condDBVars};
    condDBVars = condDBVars(:,ones(1,nobj));
    shockProps = {shockProps};
    shockProps = shockProps(:,ones(1,nobj));
    
end

%==========================================================================
function [startDate,endDate,condDB,condDBVars] = parseConditionalInfo(startDate,endDate,nSteps,condDB,condDBVars,options)

    if isempty(condDB)
        
        condDB     = [];
        condDBVars = {};
        if ischar(startDate) && ~isempty(startDate)
           startDate = nb_date.date2freq(startDate);
        end
        if ischar(endDate) && ~isempty(endDate)
           endDate = nb_date.date2freq(endDate);
        end
        
    elseif isa(condDB,'nb_ts') 
        
        condDBVars = condDB.variables;
        if isempty(startDate)
            startDate = condDB.startDate;
        else
            if ischar(startDate)
               startDate = nb_date.date2freq(startDate);
            end
            if startDate < condDB.startDate || startDate > condDB.endDate
                error([mfilename ':: The provided start date is not part of the conditional data window.'])
            end
        end
        condDB  = expand(condDB,'',startDate + (nSteps - 1),'nan','off');
        condDB  = window(condDB,startDate,endDate);
        condDB  = double(condDB);
        
    elseif isa(condDB,'nb_data')
        
        % Recursive conditional information
        condDBVars = condDB.variables;
        try
            sDate = nb_date.date2freq(condDB.dataNames{1});
        catch %#ok<CTCH>
           error([mfilename ':: The first element of condDB.dataNames property must be the start date of the recursive forecast.']) 
        end
        
        try
            eDate = nb_date.date2freq(condDB.dataNames{end});
        catch %#ok<CTCH>
            error([mfilename ':: The last element of condDB.dataNames property must be the end date of the recursive forecast.']) 
        end
        
        if isempty(startDate)
            startDate = sDate;
        else
            if ischar(startDate)
               startDate = nb_date.date2freq(startDate);
            end
            if startDate < sDate || startDate > eDate
                error([mfilename ':: The provided start date (' toString(startDate) ') is not part of the conditional data window (See condDB.dataNames property).'])
            end
        end
        
        if isempty(endDate)
            endDate = nb_date.date2freq(options(end).dataStartDate) + options(end).estim_end_ind;
        else
            if ischar(endDate)
               endDate = nb_date.date2freq(endDate);
            end
            if endDate < sDate|| startDate > eDate
                error([mfilename ':: The provided end date (' toString(endDate) ') is not part of the conditional data window (See condDB.dataNames property).'])
            end
        end
        condDB = double(condDB);
        
        periods = eDate - sDate + 1;
        if size(condDB,3) ~= periods
            error([mfilename ':: The nb_data object provided with the condDB input has not enough pages.'])
        end
        
        % Shorten the window to the periods of interest
        indE   = eDate - endDate; 
        indS   = startDate - sDate + 1;
        condDB = condDB(:,:,indS:end-indE);
             
    end

end 

%==========================================================================
function [inputsW,startInd,endInd,condDB,condDBVars,shockProps,cores,opt] = parseWhenDifferentInputs(opt,inputs,nSteps)

    cores      = [];
    nobj       = length(opt); 
    startInd   = cell(1,nobj);
    endInd     = cell(1,nobj);
    condDB     = cell(1,nobj);
    condDBVars = cell(1,nobj);
    shockProps = cell(1,nobj);
    for ii = 1:nobj
        
        try condDBT     = inputs(ii).condDB;     catch; condDBT     = []; end
        try condDBVarsT = inputs(ii).condDBVars; catch; condDBVarsT = {}; end
        [startD,endD,condDB{ii},condDBVars{ii}] = parseConditionalInfo(inputs(ii).startDate,inputs(ii).endDate,nSteps,condDBT,condDBVarsT,opt{ii});
        shockProps{ii}                          = inputs(ii).shockProps;

        % Get start/end index
        opt{ii} = nb_defaultField(opt{ii},'estimator','');
        if strcmpi(opt{ii}(end).estimator,'nb_midasEstimator')
            date = nb_date.date2freq(opt{ii}(end).estim_start_date_low);
        elseif strcmpi(opt{ii}(end).estimator,'nb_tslsEstimator')
            date    = nb_date.date2freq(opt{ii}.mainEq.dataStartDate);
            opt{ii} = opt{ii}.mainEq; % TSLS stores things differently
        else
            date = nb_date.date2freq(opt{ii}(end).dataStartDate);
        end
        if ~isempty(startD)
            startInd{ii} = startD - date + 1;
            if inputs(ii).startIndWarning
                startFcstDate = date + (startInd{ii}-1);
                startInd{ii}  = opt{ii}(end).recursive_estim_start_ind + 1;
                startRec      = date + (startInd{ii}-1);
                warning('nb_forecast:adjustStartInd',['The start (' toString(startFcstDate) ') of recursive ',...
                        'forecast where before the recursive estim start date (' toString(startRec) '). Reset to ',...
                        toString(startRec) '.'])
            end
        end
        if ~isempty(endD)
            endInd{ii} = endD - date + 1;
        end

        % Check the states input
        if isa(inputs(ii).states,'nb_ts')
            if ~isempty(condDB{ii})
                if inputs(ii).states.startDate > condDB{ii}.startDate 
                    error([mfilename ':: The provided start date of the states input is to late.'])
                end
                if inputs(ii).states.endDate < condDB{ii}.endDate
                    error([mfilename ':: The provided end date of the states input is to short.'])
                end
                inputs(ii).states = double(window(inputs(ii).states,condDB{ii}.startDate,condDB{ii}.endDate,{'states'}));
            else
                inputs(ii).states = double(inputs(ii).states);
            end  
            inputs(ii).states = inputs(ii).states(1:nSteps,:);
        end

        % Get the inputs for each model (used by saving and waitbar)
        inputs(ii).nObj      = nobj;
        inputs(ii).index     = ii;
        inputs(ii).reporting = {};
        
    end
     
    inputsW = nb_rmfield(inputs,{'condDB','condDBVars'});

end

%==========================================================================
function opt = appendSmoothed(obj,opt)

    s     = getFiltered(obj);
    s     = keepVariables(s,obj.dependent.name);
    cData = obj.options.data;
    if isa(obj,'nb_mfvar')
        tData = doTransformations(cData,obj.transformations);
        mData = append(tData,s);
    else
        indRemove = ismember(cData.variables,obj.dependent.name);
        cData     = deleteVariables(cData,cData.variables(indRemove));
        mData     = merge(cData,s);
    end
    opt.data          = double(mData);
    opt.dataStartDate = mData.startDate;
    opt.dataVariables = mData.variables;

end
