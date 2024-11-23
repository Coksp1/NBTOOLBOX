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
% - obj     : An object of class nb_model_recursive_detrending.
% 
% Output:
% 
% - plotter : An object of class nb_graph.
%
% Examples:
%
% plotter = getRecursiveEstimationGraph(obj);
% plotter.graphSubPlots();
%
% See also:
% nb_graph_ts, nb_graph_cs
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: This function does not support a vector of nb_model_recursive_detrending inputs.'])
    end

    if ~isestimated(obj)
        error([mfilename ':: The model must be estimated.'])
    end
    if isa(obj.model,'nb_dsge')
        error([mfilename ':: This method is not supported when the underlying model is of class nb_dsge.'])
    end
    
    % Get the recursive estimates
    nPeriods     = length(obj.modelInit);
    [nParam,nEq] = size(obj.modelInit(1).results.beta);
    beta         = nan(nParam,nEq,nPeriods);
    stdBeta      = beta;
    for tt = 1:nPeriods

        res = obj.modelIter(tt).results;
        if isa(obj.modelIter(tt),'nb_singleEq')
            if strcmpi('tsls',obj.modelIter(tt).options.estim_method)
                res = res.mainEq;
            end
        end
        beta(:,:,tt) = res.beta;
        if ~isempty(res.stdBeta)
            stdBeta(:,:,tt) = res.stdBeta;
        end
        
    end
    
    % Get the start of the recursive estimation
    start = obj.options.recursive_start_date + 1;

    % Get the names of the coefficients
    estimator  = obj.modelIter(1).estOptions.estimator;
    func       = str2func([estimator '.getCoeff']);
    coeffNames = func(obj.modelIter(1).estOptions)';
    
    % Transform from numCoeff x numeq x time to time x numCoeff x numeq
    beta    = permute(beta,[3,1,2]);    
    stdBeta = permute(stdBeta,[3,1,2]);
    upperD  = beta + 1.96*stdBeta;
    lowerD  = beta - 1.96*stdBeta;
    if size(beta,3) > 1
    
        dataN             = strtrim(cellstr(num2str([1:numEq]'))); %#ok<NBRAK>
        dataN             = strcat('Eq',dataN,'')';
        recData           = nb_ts(beta,'',start,coeffNames);
        recData.dataNames = dataN;
        recData           = squeeze(recData);
        upperD            = nb_ts(upperD,'',start,coeffNames);
        upperD.dataNames  = dataN;
        upperD            = squeeze(upperD);
        lowerD            = nb_ts(lowerD,'',start,coeffNames);
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
    
%     if strcmpi(estimator,'nb_fmEstimator')
%         % Append coefficients of observation eq??
%     end
    
    % Initilize nb_graph_ts object
    %----------------------------------------------------------
    plotter = nb_graph_ts(recData);
    plotter.set('colors',   {'Estimated coefficient','orange','Lower','black','Upper','black'},...
                'noLegend', 1);   
        
end
