function [decomp,decompBands,plotter,plotterBands] = variance_decomposition(obj,varargin)
% Syntax:
%
% [decomp,decompBands,plotter,plotterBands] = ...
%               variance_decomposition(obj,varargin)
%
% Description:
%
% Variance decomposition of a vector of nb_model_generic objects.
% 
% Caution : For recursivly estimated model only the full sample estimation
%           results is used.
%
% Input:
% 
% - obj             : A vector of nb_model_generic objects
%
% - 'horizon'       : The horizons. As a 1 x nHor double. Default is 
%                     [1:8,inf].
% 
% - 'replic'        : The number of simulation for bootstrap and MC methods.
%                     Default is 1. Only used when 'perc' is provided.
%
%                     Caution: Will not have anything to say for the method
%                              'identDraws'. See the option 'draws' of the
%                              method nb_var.set_identification for more.
% 
% - 'shocks'        : Which shocks to calculate variance decomposition of.
%                     Default is the residuals defined by the first model.
%
% - 'variables'     : The variables to create variance decomp of.
%                     Default is the dependent variables defined by the  
%                     first model.
%
% - 'perc'          : Error band percentiles. As a 1 x numErrorBand double.
%                     E.g. [0.3,0.5,0.7,0.9]. Default is not to provide 
%                     error bands.
%
% - 'method'        : The selected method to create confidenc/probability 
%                     bands. Default is ''. See help on the method input of 
%                     the nb_model_generic.parameterDraws method for more 
%                     this input. An extra option is:
%                                        
%                     > 'identDraws' : Uses the draws of the matrix with
%                        the map from structural shocks to dependent 
%                        variables. See nb_var.set_identification. Of 
%                        course this option only makes sence for VARs 
%                        identified with sign restrictions.
%
% - 'output'        : Either 'closest2median' (default) or 'median'.
%
%                     > 'closest2median' : The median is represented by the  
%                                          model(s) that are closest to the 
%                                          actual median.
%
%                     > 'median'         : The median represented by the 
%                                          numerical statistic.
%
%                     Caution : Only an option when 'replic' > 1 and 'perc' 
%                               is nonempty.
%
% - 'parallel'      : Give true if you want to do the forecast in parallel. 
%                     Default is false.
%
% - 'regime'        : Select the regime to do the FEVD of. Only for Markov-
%                     switching model. If empty the ergodic mean will be 
%                     used.
%
% - 'foundReplic'   : A struct with size 1 x replic. Each element
%                     must be on the same format as obj.solution. I.e.
%                     each element must be the solution of the model
%                     given a set of drawn parameters.
%
% - 'stabilityTest' : Give true if you want to discard the draws 
%                     that give rise to an unstable model. Default
%                     is false.
%
% - 'packages'      : Cell matrix with groups of shocks and 
%                     the names of the groups. If you have not
%                     listed a shock it will be grouped in a    
%                     group called 'Rest' 
%         
%                     Must be given in the following format:
%         
%                     {'shock_group_name_1',...,'shock_group_name_N';
%                      'shock_name_1'      ,...,'shock_name_N'}
%        
%                     Where 'shock_name_x' must be a string with 
%                     a shock name or a cellstr array with the 
%                     shock names. E.g 'E_X_NW' or {'E_X_NW','E_Y_NW'}.
%
%                     If empty no packing will be done.
% 
% Output:
% 
% - decomp      : A structure of nb_ts objects with the variance 
%                 decomosition for each model. (If simulated it will store
%                 the median or closest to median dependent on the 'output'
%                 option)
%
% - decompBands : A structure of structs with the percentiles 
%                 of the variance decomosition for each model. For each 
%                 percentiles the output is as decomp.
%
% - plotter     : A 1 x nModel vector of nb_graph_cs objects. Use the
%                 graph method or the nb_graphPagesGUI class to produce 
%                 the graphs.
%
% - plotterBands: A 1 x nModel struct. Each field is a 1 x nVars vector of 
%                 nb_graph_cs objects. Use the graphSubPlots method to  
%                 produce the graphs of each of the fields. This graphs
%                 will plot the contribution of each shock to each variable
%                 with error bands.
%           
% See also:
% nb_model_generic.parameterDraws, nb_varDecomp
%
% Written by Kenneth Sæterhagen Paulsen    

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj  = obj(:);
    nobj = numel(obj);
    if any(~issolved(obj))
        error([mfilename ':: All the models must be solved to do fevd'])
    end

    % Parse the arguments
    %--------------------------------------------------------------
    methods = {'bootstrap','wildBootstrap','blockBootstrap',...
               'mBlockBootstrap','rBlockBootstrap','wildBlockBootstrap',...
               'posterior',''};   
    default = {'parallel',              false,              {@islogical,'||',@isnumeric};...
               'horizon',               [1:8,inf],          {@isnumeric,'||',@isempty};...
               'perc',                  [],                 {@isnumeric,'||',@isempty};...
               'method',                '',                 {{@nb_ismemberi,methods}};...
               'output',                'closest2median',   {{@nb_ismemberi,{'closest2median','median'}}};...
               'packages',              {},                 {@iscell,'||',@isempty};...
               'variables',             {},                 {@iscellstr,'||',@isempty};...
               'stabilityTest',         false,              @islogical;...
               'shocks',                {},                 {@iscellstr,'||',@isempty};...
               'regime',                [],                 {@nb_iswholenumber,'&&',@isscalar,'||',@isempty};...
               'foundReplic',           [],                 {@isstruct,'||',@isempty};...
               'replic',                1,                  {@nb_iswholenumber,'&&',@isscalar,'||',@isempty}};
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
          
    if isempty(inputs.shocks)
       inputs.shocks = obj(1).solution.res; 
    end
    if isempty(inputs.variables)
        if isa(obj,'nb_mfvar')
            inputs.variables = obj(1).solution.endo(1:length(obj(1).dependent.name));
        else
            inputs.variables = obj(1).dependent.name;
        end
    end
    if ~isempty(inputs.foundReplic)
        if nobj ~= 1
            error([mfilename ':: The ''foundReplic'' options only work for scalar nb_model_generic object.'])
        end
    end
    
    % Get the inputs for each model (used by waitbar)
    inputsW             = inputs(1,ones(1,nobj));
    inputsW(nobj).nObj  = [];
    inputsW(nobj).index = [];
    nObjRep             = num2cell(ones(1,nobj)*nobj);
    index               = num2cell(1:nobj);
    [inputsW(:).nObj]   = nObjRep{:};
    [inputsW(:).index]  = index{:};
    
    % For DSGE models we need the object itself stored in the parser field
    for ii = 1:nobj
       if isa(obj(ii),'nb_dsge')
           if isNB(obj(ii))
               obj(ii).estOptions.parser.object = set(obj(ii),'silent',true);
           end
       end
    end
    
    % Produce the fevd
    %--------------------------------------------------------------
    decomp   = cell(1,nobj);
    models   = {obj.solution};
    opt      = {obj.estOptions};
    res      = {obj.results};
    parallel = inputs.parallel;
    if parallel && nobj > 1
        ret = nb_openPool();
        parfor ii = 1:nobj
            decomp{ii} = nb_varDecomp(models{ii},opt{ii}(end),res{ii},inputsW(ii));
        end
        nb_closePool(ret);
    else
        for ii = 1:nobj
            decomp{ii} = nb_varDecomp(models{ii},opt{ii}(end),res{ii},inputsW(ii));
        end
    end
    
    % Merge output
    %--------------------------------------------------------------
    [decomp,decompBands] = mergeOutput(decomp,inputs);
    
    % Plot if wanted
    %--------------------------------------------------------------
    if nargout > 2
        
        if isempty(decompBands)
            figureName = 'Mean';
        else
            figureName = 'Median';
        end
        
        settings         = {'plotType','stacked','yLim',[0,1],'noTitle',2,'figureName',figureName,...
                            'lineWidth',0.5};
        fields           = fieldnames(decomp);
        nModels          = length(fields);
        plotter(nModels) = nb_graph_cs();
        for ii = 1:nModels
            plotter(ii) = nb_graph_cs(decomp.(fields{ii})); 
        end
        plotter.set(settings{:});
        
    end
    
    if nargout > 3
        
        % Get the actual lower and upper percentiles as a cellstr
        perc = nb_interpretPerc(inputs.perc,false);
        perc = strtrim(cellstr(int2str(perc')));
        
        if isempty(decompBands)
            plotterBands = [];
            return
        end
        
        plotterBands         = struct();
        settings             = {'fanColor','grey'};
        fields               = fieldnames(decompBands);
        fieldsPerc           = fieldnames(decompBands.(fields{1}));
        nVars                = objSize(decompBands.(fields{1}).(fieldsPerc{1}),3);
        nModels              = length(fields);
        nPerc                = length(fieldsPerc);
        for ii = 1:nModels

            decMedian = decomp.(fields{ii});
            decPerc   = decompBands.(fields{ii});
            
            % Create a graph object for each variables (here the different
            % shocks will be the "variables" of the nb_ts objects) 
            plotterVars(nVars) = nb_graph_cs(); %#ok<AGROW>
            for kk = 1:nVars

                decMedianVar = decMedian.window('','',kk);
                
                % Then we need to get the percentiles and add it to the
                % 'fanDatasets' property
                decPercVar = nb_cs;
                for jj = 1:nPerc
                    decPercTemp = decPerc.(fieldsPerc{jj});
                    decPercTemp = decPercTemp.window('','',kk);
                    decPercVar  = addPages(decPercVar,decPercTemp);
                end
                decPercVar.dataNames = perc';
                
                % The median is the main data to plot
                plotterVars(kk) = nb_graph_cs(decMedianVar); 
                plotterVars(kk).set('figureName', decPercTemp.dataNames{1},...
                                    'fanDatasets',decPercVar,...
                                    'colorOrder',[0,0,0],...
                                    settings{:});

            end
            
            plotterBands.(fields{ii}) = plotterVars;

        end
         
    end

end

%==========================================================================
% SUB
%==========================================================================
function [decomp,decompBands] = mergeOutput(decompC,inputs)
% Merge output and reorder things

    shocks = inputs.shocks;
    vars   = inputs.variables;
    perc   = inputs.perc;
    output = inputs.output;

    % Get the actual lower and upper percentiles
    perc = nb_interpretPerc(perc,false);

    % Get different stuff
    decomp   = struct();
    nModels  = length(decompC);
    decData  = [decompC{:}];
    nPerc    = size(decData,4) - 2;
    nVars    = length(vars);
    shocks   = [shocks,'Rest'];
    nShocks  = length(shocks);
    nHor     = size(decData,1);
    
    % Get the the primary output
    %---------------------------------------------
    % Transform from a nHor x (nShocks + 1 x nModels) x nVars 
    % to nHor x nShocks + 1 x nVars,nModels
    if nPerc == -1 % Only for one point in the distribution
        decDataM = decData;
    else
        if strcmpi(output,'closest2median')
            decDataM = decData(:,:,:,end);
        else
            decDataM = decData(:,:,:,end-1);
        end
    end
    decDataM = reshape(decDataM,nHor,nShocks,nVars,nModels);
    horNames = strtrim(cellstr(num2str(inputs.horizon'))');
    for ii = 1:nModels
        data                           = nb_cs(decDataM(:,:,:,ii),'',horNames,shocks);
        data.dataNames                 = vars;
        data                           = finalPacking(data,inputs.packages);
        decomp.(['Model' int2str(ii)]) = data; 
    end
    
    % Get the error band from models
    %----------------------------------------------
    decompBands = [];
    if nPerc > 0
        
        decompBands = struct();
        for jj = 1:nPerc
        
            fieldName   = ['Percentile_' int2str(perc(jj))];
            decDataPerc = decData(:,:,:,jj);
            decDataPerc = reshape(decDataPerc,nHor,nShocks,nVars,nModels);
            for ii = 1:nModels
               data                                 = nb_cs(decDataPerc(:,:,:,ii),'',horNames,shocks);
               data.dataNames                       = vars;
               data                                 = finalPacking(data,inputs.packages);
               fieldName2                           = ['Model' int2str(ii)];
               decompBands.(fieldName2).(fieldName) = data; 
            end
            
        end
        
    end
    
end

%==========================================================================
function decDB = finalPacking(decDB,packages)

    % Sum all the shock contributions of each group 
    if ~isempty(packages)
        
        if size(packages,1) ~= 2
            error([mfilename ':: The packages input must have only 2 rows.'])
        end
        
        allShocks     = decDB.variables;
        allShocksSel  = nb_nestedCell2Cell(packages(2,:));
        allShocksSelU = unique(allShocksSel);
        if length(allShocksSel) ~= length(allShocksSelU)
        
            % A shock has been selected for more groups, which I don't
            % allow
            num = ones(1,length(allShocksSelU));
            for ii = 1:length(allShocksSelU)
                num(ii) = sum(strcmpi(allShocksSelU{ii},allShocksSel));
            end
            
            allShocksSelErr = allShocksSelU(num > 1);
            error([mfilename ':: The following shocks has been selected more than once; ' toString(allShocksSelErr) '.'])
            
        end
        
        indRest  = ~ismember(allShocks,allShocksSelU);
        if any(indRest)
            packages = [packages,{'Rest_XXXX';allShocks(indRest)}];
        end
        nGroups     = size(packages,2);
        expressions = cell(1,nGroups);
        for ii = 1:nGroups
            shockGroup      = cellstr(packages{2,ii});
            expressions{ii} = nb_cellstr2String(shockGroup,'+');
        end
        newV  = strcat(packages(1,:),'_XXXX');
        decDB = decDB.createVariable(newV,expressions);
        decDB = window(decDB,'',newV);
        decDB = rename(decDB,'variable','*_XXXX','');
        
    end

end
