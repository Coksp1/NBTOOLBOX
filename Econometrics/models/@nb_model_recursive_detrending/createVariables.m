function [obj,plotter] = createVariables(obj,expressions,fcstHorizon)
% Syntax:
%
% obj = createVariables(obj,expressions,fcstHorizon)
%
% Description:
%
% Create model variables given input data. 
%
% Caution : Only for time-series models!
% 
% Input:
% 
% - obj         : A 1x1 nb_model_recursive_detrending object
%
% - expressions : A N x 4 x nPeriods cell matrix of how to transform input   
%                 data to model variables recursivly. First column is the 
%                 model variable name, while the second column is the  
%                 expression to convert the input data to model variable.   
%                 The third column is the expression on how to calculate  
%                 the shift variable. While the fourth column is for 
%                 comments. 
%
%                 More on:
%
%                 > second column : Any expression that can be interpreted
%                                   by the nb_ts.createVariable method.
% 
%                 > third column  : Any expression that can be interpreted
%                                   by the nb_ts.createShift method.
%
%                 > fourth column : Comments
%
%                 The third dimension of this input refers to the number
%                 of recursive period you want to estimate or forecast your
%                 model. This allow for time-varying detrending, as for
%                 example real-time hp-filtering.
%
%                 Caution : The size of the third dimension must be equal
%                           to recursive period given by the 
%                           recursive_start_date and recursive_end_date
%                           options.
%
% - fcstHorizon : The forcast horizon. As an integer. Default is 8. It is
%                 important that this option is higher than the number of
%                 forcasting/irf steps, or else the output will be nan!
%
% Output:
% 
% - obj       : The object itself added the model variables. The  
%               expressions input is stored in the property 
%               transformations.
%
% - plotter   : A 1 x nPeriods vector of nb_graph_ts object with a graph 
%               with the detrending of each recursive period. Use the 
%               graphInfoStruct method to produce the graph of each object.
%               Do not call it on the hole vector!!
%
% Examples:
%
% expressions = {% Name,  input,  shift,   description                                                                                                                                 'CPI adj. for tax changes and excl. temp. changes in energy prices'
%  'QSA_DPQ_YMN',     'log(QSA_YMN)',         {{'hpfilter',1600}}, ''
%  'QSA_DPQ_PCPIJAE', 'log(QSA_DPQ_PCPIJAE)', {{'hpfilter',1600}}, ''
%  'QSA_DPQ_CP',      'log(QSA_DPQ_CP)',      {{'hpfilter',1600}}, ''};
% 
% modelRec = modelRec.createVariables(expressions)
%
% See also:
% nb_model_recursive_detrending.reporting
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        fcstHorizon = 8;
    end

    if numel(obj) ~= 1
        error([mfilename ':: The input obj must be a scalar nb_model_generic object.'])
    end
    
    % Set up the models for data transformation and
    [periods,~,obj] = getRecursivePeriods(obj);
    modelI          = obj.model(ones(periods,1),:);
    if periods ~= size(expressions,3)
        error([mfilename ':: The expressions input has ' int2str(size(expressions,3)) ' pages, but needs ' int2str(periods) '.'])
    end
    
    plotter(1,periods) = nb_graph_ts;
    dataOrig           = obj.model.options.data;
    if dataOrig.numberOfDatasets > 1 % Real-time data
        
        dataOrig  = expand(dataOrig,'',obj.options.recursive_start_date + (periods + fcstHorizon - 1),'nan','off');
        variables = [obj.model.dependent.name,obj.model.exogenous.name];
        if isa(obj.model,'nb_var')
            variables = [variables, obj.model.block_exogenous.name]; 
        end
        realEndDates = getRealEndDatePages(dataOrig,'default','all',variables);
        indStart     = find(strcmpi(toString(obj.options.recursive_start_date),realEndDates),1,'first');
        dataOrig     = window(dataOrig,'','','',indStart:dataOrig.numberOfPages);
        for ii = 1:periods
            % Shorten the data sample recursivly 
            dataT                    = window(dataOrig,'',obj.options.recursive_start_date + (ii + fcstHorizon - 1),ii);
            modelI(ii)               = setTransformations(modelI(ii),expressions(:,:,ii),fcstHorizon);
            modelI(ii)               = setReporting(modelI(ii),obj.reporting);
            [modelI(ii),plotter(ii)] = updateOptionsData(modelI(ii),dataT);
        end
        
    else % Not real-time
        
        dataOrig = expand(dataOrig,'',obj.options.recursive_start_date + (periods + fcstHorizon - 1),'nan','off');
        for ii = 1:periods
            % Shorten the data sample recursivly 
            dataT                    = window(dataOrig,'',obj.options.recursive_start_date + (ii + fcstHorizon - 1));
            modelI(ii)               = setTransformations(modelI(ii),expressions(:,:,ii),fcstHorizon);
            modelI(ii)               = setReporting(modelI(ii),obj.reporting);
            [modelI(ii),plotter(ii)] = updateOptionsData(modelI(ii),dataT);
        end
        
    end
    
    % Assign to object
    obj.transformations = expressions;
    obj.modelIter       = modelI;
    if ~isempty(obj.reporting)
        obj.reported = true;
    end
    
end
