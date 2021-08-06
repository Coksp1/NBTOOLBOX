function [obj,plotter] = createVariables(obj,expressions,fcstHorizon)
% Syntax:
%
% obj = createVariables(obj,expressions,fcstHorizon)
% [obj,plotter] = createVariables(obj,expressions,fcstHorizon)
%
% Description:
%
% Create model variables given input data. 
%
% Caution : Only for time-series models!
% 
% Input:
% 
% - obj         : A NxM nb_modelData object
%
% - expressions : A N x 4 cell matrix of how to transform input data to  
%                 model variables. First column is the model variable name,
%                 while the second column is the expression to convert the 
%                 input data to model variable. The third column is the  
%                 expression on how to calculate the shift variable. While 
%                 the fourth column is for comments. 
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
% - fcstHorizon : The forcast horizon. As an integer. Default is 8. It is
%                 important that this option is higher than the number of
%                 forcasting/irf steps, or else the output will be nan!
%
% Output:
% 
% - obj       : The NxM object itself added the model variables. The  
%               expressions input is stored in the property 
%               transformations.
%
% - plotter   : A NxM nb_graph_ts object with a graph with the de-trending.
%               Use the graphInfoStruct method or the nb_graphInfoStruct 
%               class to produce the graph.
%
% Examples:
%
% expressions = {% Name,  input,  shift,   description 
%  'VAR1_G',    'pcn(VAR1)', 'avg',  'VAR1 growth'
%  'VAR2_G',    'pcn(VAR2)', 'avg',  'VAR2 growth'
%  'VAR3_G',    'pcn(VAR3)', 'avg',  'VAR3 growth'};
% 
% model = model.createVariables(expressions)
%
% See also:
% nb_model_generic.transformations, nb_model_generic.reporting
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isa(obj,'nb_model_vintages')
        error([mfilename ':: Cannot call this method on a nb_model_vintages object. This is done '...
                         'automatically inside the estimate method in this case.'])
    end
    
    if nargin < 3
        fcstHorizon = 8;
    end

    if numel(obj) ~= 1
        error([mfilename ':: The input obj must be a scalar nb_model_generic object.'])
    end
    
    if isempty(obj.options.data)
        error([mfilename ':: The object is not assign any data. Set the ''data'' option.'])
    end
    
    if ~isa(obj.options.data,'nb_ts')
        error([mfilename ':: This method only support time-series models.'])
    end
    
    if ~iscell(expressions)
        error([mfilename ':: The expressions input must be a cell'])
    end
    
    if ~nb_sizeEqual(expressions,[nan,4,nan])
        error([mfilename ':: The expressions input must have 4 columns'])
    end
    
    % Create variables
    siz = size(obj);
    obj = obj(:);
    if nargout > 1
    
        plotter(length(obj),1) = nb_graph_ts;
        for ii = 1:length(obj)
            
            obj(ii).transformations = expressions;
            obj(ii).fcstHorizon     = fcstHorizon;
            [obj(ii),plotter(ii)]   = updateOptionsData(obj(ii));
            
            if plotter(ii).DB.numberOfDatasets > 1
                plotter(ii).DB = plotter(ii).DB(:,:,end);
            end
            
        end 
        plotter = reshape(plotter,siz);
        
    else
        
        for ii = 1:length(obj)
            obj(ii).transformations = expressions;
            obj(ii).fcstHorizon     = fcstHorizon;
            obj(ii)                 = updateOptionsData(obj(ii));
        end 
        
    end
    obj = reshape(obj,siz);
    
end
