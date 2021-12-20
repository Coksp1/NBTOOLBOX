function [obj,shift,plotter]= doTransformations(obj,expressions,fcstHorizon,varargin)
% Syntax:
%
% [obj,shift,plotter] = doTransformations(obj,expressions,fcstHorizon,varargin)
%
% Description:
%
% Do transformations on the variables of the object. 
% 
% Input:
% 
% - obj         : A nb_ts object
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
% - fcstHorizon : The forcast horizon. As an integer. Default is 0. 
%
% Optional input:
%
% - 'warning'         : true or false. Set to true to give warning if
%                       expressions fail (instead of error). Will
%                       result in series having all nan value, when warning
%                       is thrown.
%
% Output:
% 
% - obj       : A nb_ts object storing the de-trended created variables.
%
% - shift     : A nb_ts object storing the shifts/trend of the created 
%               variables.
%
% - plotter   : A nb_graph_ts object with a graph with the de-trending.
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
% obj = obj.doTransformations(expressions)
%
% See also:
% nb_ts.createVariable, nb_ts.createShift
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        fcstHorizon = 0;
    end

    if numel(obj) ~= 1
        error([mfilename ':: The input obj must be a scalar nb_ts object.'])
    end
    
    if ~iscell(expressions)
        error([mfilename ':: The expressions input must be a cell'])
    end
    
    if ~nb_sizeEqual(expressions,[nan,4,1])
        error([mfilename ':: The expressions input must have 4 columns'])
    end
    
    % Create variables
    obj = createVariable(obj,expressions(:,1)',expressions(:,2)',[],'overwrite',true,varargin{:});

    % Create shift variables
    if nargout > 2
        [obj,shift,plotter] = createShift(obj,fcstHorizon,expressions(:,1)',expressions(:,3)');
    else
        [obj,shift] = createShift(obj,fcstHorizon,expressions(:,1)',expressions(:,3)'); 
    end
    
end
