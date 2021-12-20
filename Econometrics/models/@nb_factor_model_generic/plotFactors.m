function plotter = plotFactors(obj,errBands)
% Syntax:
%
% plotter = plotFactors(obj,errBands)
%
% Description:
%
% Get factors from a estimated nb_factor_model_generic object
% 
% Input:
% 
% - obj      : An object of class nb_factor_model_generic
% 
% - errBands : Give true to add one std bands around the factor estimates.
%              Default is false.
%
% Output:
% 
% - plotter  : A nb_graph_ts object to use to plot the factors. Use the
%              graphSubPlots method or the nb_graphSubPlotGUI.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        errBands = false;
    end

    if numel(obj) > 1
        error([mfilename ':: This function is only supported for a single nb_factor_model_generic object as input'])
    end
    
    factors = getFactors(obj);
    if isempty(factors)
        error([mfilename ':: The model has not been estimated, so cannot plot factors.'])
    end
    if errBands
        if ~isa(obj,'nb_fmdyn')
            error([mfilename ':: Cannot plot factor estimates with error bands for an model of class ' class(obj)])
        end
        varF      = obj.results.smoothed.variances.data;
        stdF      = nb_ts(sqrt(varF),'',factors.startDate,factors.variables);
        stdFUpp68 = factors + stdF;
        stdFLow68 = factors - stdF;
        stdFUpp90 = factors + 1.645*stdF;
        stdFLow90 = factors - 1.645*stdF;
        stdFUpp95 = factors + 1.96*stdF;
        stdFLow95 = factors - 1.96*stdF;
        stdF      = addPages(stdFLow95,stdFLow90,stdFLow68,stdFUpp68,stdFUpp90,stdFUpp95);
    end
    plotter = nb_graph_ts(factors);
    if errBands
        plotter.set('fanDatasets',stdF,'fanPercentiles',[0.68,0.9,0.95]);
    end
    
end
