function [decomp,decompBand,plotter] = shock_decomposition(obj,varargin)
% Syntax:
%
% [decomp,decompBand,plotter] = shock_decomposition(obj,varargin)
%
% Description:
%
% Shock decomposition of a vector of nb_model_generic objects.
%
% Caution : For recursivly estimated model only the full sample estimation
%           results is used.
%
% Input:
% 
% - obj         : A vector of nb_model_generic objects
%
% - 'packages'  : Cell matrix with groups of shocks and 
%                 the names of the groups. If you have not
%                 listed a shock it will be grouped in a    
%                 group called 'Rest' 
%         
%                 Must be given in the following format:
%         
%                 {'shock_group_name_1',...,'shock_group_name_N';
%                  'shock_name_1'      ,...,'shock_name_N'}
%        
%                 Where 'shock_name_x' must be a string with 
%                 a shock name or a cellstr array with the 
%                 shock names. E.g 'E_X_NW' or {'E_X_NW','E_Y_NW'}.
%
%                 Caution: Two special identifiers can be used; 
%                          'Initial Conditions' and 'Steady-state'. The 
%                          first represent the impact of all shocks that  
%                          hit the system before the decomposition/
%                          estimation started. The second summarizes the 
%                          impact of steady-state changes on the system, 
%                          i.e. the impact of  break points.
%                          
%                 If empty no packing will be done.
% 
% - 'variables' : The variables to decompose. Default is the 
%                 dependent variables defined by the first model.
%
% - 'startDate' : Start date of the decomposition. As a string. If
%                 different models has different frequency this date will
%                 be converted.
%
% - 'endDate'   : End date of the decomposition. As a string. If
%                 different models has different frequency this date will
%                 be converted.
%
% - 'perc'      : Error band percentiles. As a 1 x numErrorBand double.
%                 E.g. [0.3,0.5,0.7,0.9]. Default is not to provide error
%                 bands.
%
% - 'method'    : The selected method to create error bands.
%                 Default is ''. See help on the method input of the
%                 nb_model_generic.parameterDraws method for more 
%                 this input. An extra option is:
%                                        
%                 > 'identDraws' : Uses the draws of the matrix with
%                 	the map from structural shocks to dependent variables. 
%                   See nb_var.set_identification. Of course this option
%                   only makes sence for VARs identified with sign 
%                   restrictions.
%
% - 'replic'        : The number of simulation for posterior, bootstrap and 
%                     MC methods. Default is 1. Only used when 'perc' is 
%                     provided.
%
%                     Caution: Will not have anything to say for the method
%                              'identDraws'. See the option 'draws' of the
%                              method nb_var.set_identification for more.
%
% - 'stabilityTest' : Give true if you want to discard the draws 
%                     that give rise to an unstable model. Default
%                     is false.
%
% - 'parallel'      : Give true if you want to do the shock decomp in 
%                     parallel. Default is false.
%
% - 'fcstDB'        : An object of class nb_ts with the forecast to 
%                     decompose. must contain all model variables and 
%                     shocks/residuals, and must start the period after  
%                     the estimation/filtering end date or at the 
%                     estimation/filtering start date. See
%                     the nb_model_generic.getForecast method.
%
% - 'type'          : Choose 'updated' or 'smoothed'. 'smoothed' is
%                     default.
%
% - 'anticipationStartDate' : Start date of anticipating shocks. As a  
%                             string. If different models has different  
%                             frequency this date will be converted. 
%
% - 'model2'                : A struct with the solution of the second
%                             model to use for decomposition.
%
% - 'secondModelStartDate'  : Start date of second model. As a string.   
%                             If different models has different frequency 
%                             this date will be converted. 
%
% Output:
% 
% - decomp      : A structure of nb_ts objects with the shock 
%                 decomposition for each model.
%
% - decompBand  : A nested structure of nb_ts objects with the uncertainty 
%                 bounds of the shock decomposition for each model at each 
%                 percentile.
%
% - plotter     : A 1 x nModel vector of nb_graph_ts objects. Use the
%                 graph method to produce the graphs or use the 
%                 nb_graphPagesGUI on each element of the graph objects.
%
% See also:
% nb_model_generic.parameterDraws, nb_shockDecomp
%
% Written by Kenneth Sæterhagen Paulsen    

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if any(~issolved(obj))
        error([mfilename ':: All the models must be solved to do shock decomposition'])
    end

    % Parse the arguments
    %--------------------------------------------------------------
    methods = {'bootstrap','wildBootstrap','blockBootstrap',...
               'mBlockBootstrap','rBlockBootstrap','wildBlockBootstrap',...
               'posterior',''};   
    types   = {'updated','smoothed'};       
    default = {'parallel',              false,      {@islogical,'||',@isnumeric};...
               'startDate',             '',         {@ischar,'||',{@isa,'nb_date'},'||',@isempty};...
               'endDate',               '',         {@ischar,'||',{@isa,'nb_date'},'||',@isempty};...
               'method',                '',         {{@nb_ismemberi,methods}};...
               'perc',                  [],         {@isnumeric,'||',@isempty};...
               'packages',              {},         {@iscell,'||',@isempty};...
               'variables',             {},         {@iscellstr,'||',@ischar,'||',@isempty};...
               'stabilityTest',         false,      @islogical;...
               'replic',                1,          {@nb_iswholenumber,'&&',@isscalar,'||',@isempty};...
               'fcstDB',                [],         {{@isa,'nb_ts'},'||',@isempty};...
               'model2',                [],         {@isstruct,'||',@isempty};...
               'anticipationStartDate', '',         {@ischar,'||',{@isa,'nb_date'},'||',@isempty};...
               'secondModelStartDate',  '',         {@ischar,'||',{@isa,'nb_date'},'||',@isempty};...
               'type',                  'smoothed', @(x)nb_ismemberi(x,types)};...
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    
    perc = inputs.perc;
    if ischar(inputs.variables)
        inputs.variables = cellstr(inputs.variables);
    end
    
    % Check the fcstDB input.
    %--------------------------------------------------------------
    if ~isempty(inputs.fcstDB)
        inputs = checkFcstDBInput(obj,inputs);
    end
    
    % Produce the shock decomp
    %--------------------------------------------------------------
    obj     = obj(:);
    nobj    = size(obj,1);
    decomp  = cell(1,nobj);
    models  = {obj.solution};
    opt     = {obj.estOptions};
    res     = {obj.results};
    
    % Get start and end indicies of each model
    [sInd,eInd,indM] = nb_model_generic.getDates(opt,inputs);
    iter             = 1:nobj;
    parallel         = inputs.parallel;
    
    % Get the inputs for each model
    inputsW = replicateInputs(opt,inputs);    
    if parallel
        ret = nb_openPool();
        parfor ii = 1:nobj
            decomp{ii} = nb_shockDecomp(models{ii},opt{ii}(end),res{ii},sInd(ii),eInd(ii),inputsW(ii));
        end
        nb_closePool(ret);
    else
        for ii = iter(indM) % Remove the models that are outside bounds
            decomp{ii} = nb_shockDecomp(models{ii},opt{ii}(end),res{ii},sInd(ii),eInd(ii),inputsW(ii));  
        end
    end
    
    % Pack output
    %--------------------------------------------------------------
    vars = inputs.variables;
    if isempty(vars)
        if isa(obj(1),'nb_mfvar')
            vars = obj(1).solution.endo(1:obj(1).dependent.number);
        elseif isa(obj(1),'nb_ecm')
            vars = obj(1).solution.endo;
        else
            vars = obj(1).dependent.name;
        end
    end
    [decomp,decompBand] = packOutput(decomp,models,res,opt,vars,inputs.packages,sInd,perc);
    
    % Plot if wanted
    %--------------------------------------------------------------
    if nargout > 2
        
        settings         = {'plotType','dec','noTitle',2};
        fields           = fieldnames(decomp);
        nModels          = length(fields);
        plotter(nModels) = nb_graph_ts();
        for ii = 1:nModels
            plotter(ii) = nb_graph_ts(decomp.(fields{ii})); 
        end
        plotter.set(settings{:});
        
    end

end

%==========================================================================
% SUB
%==========================================================================
function inputsW = replicateInputs(opt,inputs)

    nobj = length(opt);

    inputsW             = rmfield(inputs,{'startDate','endDate','anticipationStartDate','secondModelStartDate'});
    inputsW             = inputsW(1,ones(1,nobj));
    inputsW(nobj).nObj  = [];
    inputsW(nobj).index = [];
    nObjRep             = num2cell(ones(1,nobj)*nobj);
    index               = num2cell(1:nobj);
    [inputsW(:).nObj]   = nObjRep{:};
    [inputsW(:).index]  = index{:};
    
    if ~isempty(inputs.anticipationStartDate)
        aDate = nb_date.date2freq(inputs.anticipationStartDate);
        for ii = 1:nobj
            [dateS,freq] = nb_date.date2freq(opt{ii}(end).dataStartDate);
            aDateM       = convert(aDate,freq);
            inputsW(ii).anticipationStartInd = aDateM - dateS + 1;
        end 
    else
        [inputsW(1:end).anticipationStartInd] = deal([]);
    end
    
    if ~isempty(inputs.secondModelStartDate)
        mDate = nb_date.date2freq(inputs.secondModelStartDate);
        for ii = 1:nobj
            [dateS,freq] = nb_date.date2freq(opt{ii}(end).dataStartDate);
            aDateM       = convert(mDate,freq);
            inputsW(ii).secondModelStartInd = aDateM - dateS + 1;
        end  
    else
        [inputsW(1:end).secondModelStartInd] = deal([]);
    end

end

function [decomp,decompBands] = packOutput(decompC,models,results,opt,vars,packages,sInd,perc)
% Group the shock contribution as the 'packages' property tells it 
% to do. The decomposition of each of the endogenous variables is
% stored as one page in a nb_ts object. (With the variable name as 
% the dataset (page) name)

    % Get the actual lower and upper percentiles
    perc = nb_interpretPerc(perc,false);

    % Start packing
    decomp      = struct();
    decompBands = struct();
    nModels     = size(decompC,2);
    nVars       = size(vars,2);
    for mm = 1:nModels
        
        optModel = opt{mm}(end);
        
        % Get the start date
        if isempty(sInd(mm)) || isnan(sInd(mm))
            sInd(mm) = optModel.estim_start_ind;
        end
        start = nb_date.date2freq(optModel.dataStartDate) + sInd(mm) - 1;
        
        % Get model properties
        cl = '';
        if isfield(optModel,'class')
            cl = optModel.class;
        end
        
        if isfield(results{mm},'smoothed') || strcmpi(cl,'nb_ecm') % The model has filtered unobservables
            dep = models{mm}.endo; 
        else
            dep = optModel.dependent;
            if isfield(optModel,'block_exogenous')
                dep = [dep,optModel.block_exogenous]; %#ok<AGROW>
            end
        end
        [fV,indV] = ismember(dep,vars);
        indV      = indV(fV);
        [~,indD]  = ismember(dep,models{mm}.endo); 
        exo       = [models{mm}.exo,models{mm}.res,'Initial Conditions','Steady-state'];%
        nExo      = length(exo);
        
        % Get the decomposition of the dependent variables
        decDB  = decompC{mm};
        decDBM = decDB(:,:,indD,end); % Get the mean
        out    = finalPacking(decDBM,packages,exo,nExo,vars,nVars,start,indV,fV);
         
        % Assign to structure
        decomp.(['Model' int2str(mm)]) = out;
        
        % Get the percentiles of the decomposition of the dependent 
        % variables
        nPerc      = length(perc);
        fieldName2 = ['Model' int2str(mm)];
        for jj = 1:nPerc
        
            fieldName   = ['Percentile_' int2str(perc(jj))];
            decDataPerc = decDB(:,:,indD,jj); % Get the percentile
            decDataPerc = finalPacking(decDataPerc,packages,exo,nExo,vars,nVars,start,indV,fV);
            decompBands.(fieldName2).(fieldName) = decDataPerc; 
            
        end
        
    end
    
    if nPerc < 1
        decompBands = [];
    end
       
end

%==========================================================================
function out = finalPacking(decDB,packages,exo,nExo,vars,nVars,start,indV,fV)

    % Sum all the shock contributions of each group 
    [T,~,nEndo] = size(decDB);
    
    if ~isempty(packages)
        
        nGroups = size(packages,2);
        values  = zeros(T,nGroups + 1,nEndo);
        found   = false(1,nExo);
        for ii = 1:nGroups

            shockGroup = cellstr(packages{2,ii});
            for jj = 1:length(shockGroup)
                shInd = find(strcmp(shockGroup{jj},exo),1);
                if ~isempty(shInd)
                    values(:,ii,:) = values(:,ii,:) + decDB(:,shInd,:); 
                    found(shInd)   = true;
                end
            end
            
        end
        values(:,end,:) = sum(decDB(:,~found,:),2);

        % Get the final packed output
        out           = nan(T,nGroups+1,nVars);
        out(:,:,indV) = values(:,:,fV);
        out           = nb_ts(out,'',start,[packages(1,:),'Rest']);
        out.dataNames = vars;
    
    else
        
        % Get the final non-packed output
        T             = size(decDB,1);
        out           = nan(T,nExo,nVars);
        out(:,:,indV) = decDB(:,:,fV);
        out           = nb_ts(out,'',start,exo);
        out.dataNames = vars;

    end

end

%==================================================================
function inputs = checkFcstDBInput(obj,inputs)

    if numel(obj) ~= 1
        error([mfilename ':: The fcstDB input is only valid when numel(obj) == 1.'])
    end

    filtDate  = nb_date.date2freq(obj.results.filterStartDate);
    index     = inputs.fcstDB.startDate - filtDate;
    fcstDB    = inputs.fcstDB;
    fcstV     = fcstDB.variables;
    [ind,loc] = ismember(obj.solution.endo,fcstV);
    if any(~ind)
        error([mfilename ':: All the endogenous variables of the model must be contained in the ''fcstDB'' input. '...
                         'Missing; ' toString(obj.solution.endo(~ind))])
    end
    fcstEndo = fcstDB.data(:,loc,end);

    try
        res = obj.results.smoothed.shocks.variables;
    catch %#ok<CTCH>
        res = obj.solution.res;
    end
    
    [ind,loc] = ismember(res,fcstV);
    if any(~ind)
        error([mfilename ':: All the shocks/residuals of the model must be contained in the ''fcstDB'' input. '...
                         'Missing; ' toString(res(~ind))])
    end
    fcstRes = fcstDB.data(:,loc,end);
    fcstRes(isnan(fcstRes)) = 0;

    inputs.fcstDB = struct('endo',fcstEndo,'res',fcstRes,'index',index);

end
