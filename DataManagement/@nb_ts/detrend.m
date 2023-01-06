function [obj,trendObj,plotter] = detrend(obj,method,output,varargin)
% Syntax:
%
% obj                    = detrend(obj,method)
% obj                    = detrend(obj,method,output,varargin)
% [obj,trendObj,plotter] = detrend(obj,method,output,varargin)
%
% Description:
%
% Detrending nb_ts object.
% 
% Input:
% 
% - obj      : As a nb_ts object.
% 
% - method   : Either {'linear'}, 'linear1s', 'mean', 'hpfilter', 
%              'hpfilter1s', 'bkfilter', 'bkfilter1s', 'baiPerron' or
%              'exponentialsmoother'.
%
% - output   : If given as 'trend' the first output will be the
%              trend output instead. 'Normal' is default.
%
% - varargin : Additional inputs. When:
%
%   > 'exponentialsmoother'      : One more input must be given. I.e. 
%                                  weight on previous value. See exptrend
%                                  function for more.
%
%   > 'hpfilter' or 'hpfilter1s' : One more input must be given. I.e. 
%                                  lambda.
%
%   > 'bkfilter' or 'bkfilter1s' : Two more inputs must be given. I.e. 
%                                  lowFreq and highFreq.
%
%   > 'baiPerron'                : Two input may be given:
%                                             
%      The first:
%      * 'bic'   : Bayesian information criterion is used to select the 
%                  breaks. Default.
%      * 'lwz'   : The Liu, Wu and Zidek information criterion is used to 
%                  select the breaks.
%      * integer : An integer with the number of breaks to identify.
% 
%      The second:
%      * integer : The maximum number of breaks to allow when using a
%                  information criterion to choose the number of breaks.
%                  Default is 2.
%
% Output:
% 
% - obj      : As a nb_ts object with the detrended data.
%
% - trendObj : As a nb_ts object with the trend.
%
% - plotter  : A nb_graph_ts object. Use the graphInfoStruct method or
%              the nb_graphInfoStructGUI class on the returned object.
%
% Examples:
% 
% obj = nb_ts.rand('2012Q1',10,3);
% obj = detrend(obj,'linear');
% obj = detrend(obj,'hpfilter','',1600);
% obj = detrend(obj,'bkfilter','',6,32);
%
% See also:
% createShift
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        output = 'normal';
        if nargin < 2
            method = 'linear';
        end
    end
    
    % Convert to nb_math_ts
    trendObj = obj;
    objMath  = nb_math_ts(obj);
    
    % Do de-trending
    [objMath,trendObjMath] = detrend(objMath,method,output,varargin{:});
    
    % Convert back to nb_ts
    obj.data      = objMath.data;
    trendObj.data = trendObjMath.data;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@detrend,[{method,''},varargin]);
        
        trendObj.links      = obj.links;
        trendObj.updateable = 1;
        trendObj            = trendObj.addOperation(@detrend,[{method,'trend'},varargin]);
        
    end
    
    if strcmpi(output,'trend')
        obj = trendObj;
    end
    
    if nargout > 2
        
        % Construct all variables
        %-------------------------------------------------------------
        level = obj + trendObj;
        gap   = addPostfix(obj,'_gap');
        trend = addPostfix(trendObj,'_trend');
        full  = [gap,level,trend];
        
        % Get the expression to be graphed
        %--------------------------------------------------------------
        vars       = obj.variables;
        plottedVar = cell(1,length(vars)*2);
        for ii = 1:length(vars)
            plottedVar{ii*2 - 1} = ['[' vars{ii} ',' vars{ii} '_trend]'];
            plottedVar{ii*2}     = [vars{ii},'_gap'];
        end
        
        % Create the GraphStruct input to the nb_graph_ts class
        %----------------------------------------------------------
        GraphStruct = struct();
        for ii = 1:length(vars)
            field = strrep(vars{ii},' ','_');
            GraphStruct.(field) = {plottedVar{ii*2 - 1},  {'title', vars{ii}, 'colorOrder',{'black','red'},'legends',{'Raw Data','Trend'}};
                                   plottedVar{ii*2},{'title', vars{ii}, 'colorOrder',{'blue'},'legends',{'Gap'}}};
        end
        
        % Initilize nb_graph_ts object
        %----------------------------------------------------------
        plotter = nb_graph_init(full);
        plotter.set('GraphStruct',GraphStruct,'baseline',0);
        
    end
    
end
