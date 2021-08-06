function plotter = getRecursiveEstimationGraph(obj)
% Syntax:
%
% plotter = getRecursiveEstimationGraph(obj)
%
% Description:
%
% Get recursive estimation graph from the given estimator. The 
% returned will be an object of class nb_graph, which you can call 
% the graphSubPlots method on to get the figure(s).
% 
% Input:
% 
% - obj     : An object of class nb_model_generic (or a subclass of  
%             this class).
% 
% Output:
% 
% - plotter : An object of class nb_graph_ts. Use the graphSubPlots method
%             or the nb_graphSubplotGUI class to produce the graphs.
%
% Examples:
%
% plotter = getRecursiveEstimationGraph(obj);
% plotter.graphSubPlots();
%
% See also:
% nb_graph_ts
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: This function does not support a vector of nb_model_generic inputs.'])
    end
    opt    = obj.options;
    estopt = obj.estOptions(end);
    if isa(obj,'nb_singleEq')
        if strcmpi('tsls',obj.options.estim_method)
            estopt = estopt.mainEq;
        end
    end
    if ~estopt.recursive_estim 
        error([mfilename ':: Recursive estimation not done. Set the ''recursive_estim'' option and then call the estimate method.'])
    end
    
    res = obj.results;
    if isa(obj,'nb_singleEq')
        if strcmpi('tsls',obj.options.estim_method)
            res = res.mainEq;
        end
    end
    if isempty(fieldnames(res))
        error([mfilename ':: Recursive estimation not done. Call the estimate method.'])
    end
    
    % Get the data to plot
    %--------------------------------------------------------------
    if isa(obj,'nb_exprModel')
        beta    = vertcat(res.beta{:});
        stdBeta = vertcat(res.stdBeta{:});
        numEq   = size(beta,2);
    else
        beta    = res.beta;
        stdBeta = res.stdBeta;
        numEq   = size(beta,2);
    end
    if size(beta,3) == 1
        error([mfilename ':: Recursive estimation not done. Set the ''recursive_estim'' option and then call the estimate method.'])
    end
    
    % Get the start of the recursive estimation
    start = estopt.recursive_estim_start_ind;
    start = opt.data.startDate + start;

    % Get the names of the coefficients
    estimator = obj.estOptions.estimator;
    if isa(obj,'nb_exprModel')
        nDep = size(res.beta,2);
        exo  = cell(1,nDep);
        for ii = 1:nDep
            exo{ii} = strcat(obj.estOptions.dependent{ii},{' @ '},...
                             nb_exprEstimator.getCoeff(obj.estOptions,ii)');
        end
        exo = vertcat(exo{:});
    else
        func = str2func([estimator '.getCoeff']);
        exo  = func(obj.estOptions)';
    end
    
    % Transform from numCoeff x numeq x time to time x numCoeff x numeq
    beta = permute(beta,[3,1,2]);
    if ~isempty(stdBeta)     
        stdBeta = permute(stdBeta,[3,1,2]);
    else
        stdBeta = nan(size(beta));
    end
    upperD  = beta + 1.96*stdBeta;
    lowerD  = beta - 1.96*stdBeta;
    if size(beta,3) > 1
    
        dataN             = strtrim(cellstr(num2str([1:numEq]'))); %#ok<NBRAK>
        dataN             = strcat('Eq',dataN,'')';
        recData           = nb_ts(beta,'',start,exo);
        recData.dataNames = dataN;
        recData           = squeeze(recData);
        upperD            = nb_ts(upperD,'',start,exo);
        upperD.dataNames  = dataN;
        upperD            = squeeze(upperD);
        lowerD            = nb_ts(lowerD,'',start,exo);
        lowerD.dataNames  = dataN;
        lowerD            = squeeze(lowerD);
        recData           = addPages(recData,lowerD,upperD);
        recData.dataNames = {'Estimated coefficient','Lower','Upper'};
        
    else
        
        recData           = nb_ts(beta,'',start,exo);
        upperD            = nb_ts(upperD,'',start,exo);
        lowerD            = nb_ts(lowerD,'',start,exo);
        recData           = addPages(recData,lowerD,upperD);
        recData.dataNames = {'Estimated coefficient','Lower','Upper'};
        
    end
    
    if strcmpi(estimator,'nb_fmEstimator')
        % Append coefficients of observation eq??
    end
    
    % Initilize nb_graph_ts object
    %----------------------------------------------------------
    plotter = nb_graph_ts(recData);
    plotter.set('colors',   {'Estimated coefficient','orange','Lower','black','Upper','black'},...
                'noLegend', 1);   
        
end
