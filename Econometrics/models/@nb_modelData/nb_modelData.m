classdef (Abstract) nb_modelData < nb_model_options
% Description:
%
% A abstract superclass for all models that support transformations of 
% variables for use in the model, as well as reporting (transforming back  
% to original form when forecasted etc.).
%
% Constructor:
%
%   No constructor. This class is abstract.
% 
% See also: 
% nb_model_generic, nb_model_selection_group
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties (SetAccess = protected)
        
        % A N x 3 cell matrix of how to transform model variables to 
        % reported variables. First column is the reported variable name,
        % while the second column is the expression to convert the model
        % variable to reported variable. The last column is for comments.
        % 
        % All methods of the nb_math_ts class that perserve the time span 
        % are supported in expression. You can also call user defined 
        % functions, as long as they take and return a nb_math_ts object. 
        % A nb_math_ts object is just a double with a time dimension!
        % To get a list of all the methods of the nb_math_ts class use;
        % methods('nb_math_ts').
        %
        % Caution: During reporting, 20 periods of history of the input
        % variables are appended to the forecast.
        %
        % Can also be empty.
        %
        % See also: nb_ts.checkExpressions.
        reporting       = {};
        
        % A N x 4 cell matrix of how to transform input data to model 
        % variables. First column is the model variable name,
        % while the second column is the expression to convert the input
        % data to model variable. The third column is the expression on 
        % how to calculate the shift variable. While the fourth column is
        % for comments.
        %
        % All methods of the nb_math_ts class that perserve the time span 
        % are supported in expression. You can also call user defined 
        % functions, as long as they take and return a nb_math_ts object. 
        % A nb_math_ts object is just a double with a time dimension!
        % To get a list of all the methods of the nb_math_ts class use;
        % methods('nb_math_ts').
        %
        % Can also be empty.
        %
        % See also: nb_ts.createVariable and nb_ts.createShift.
        transformations = {};
        
    end
    
    properties (Hidden=true)
      
        % A property to store the original data given to the object, i.e.
        % before createVariables are called on the object.
        dataOrig    = nb_ts;
        
        % Call updateOptionsData in set.dataOrig or not.
        doUpdate    = true;

        % The forecast horizon selected when calling createVariables.
        fcstHorizon = 8;
       
   end
    
    methods    
        varargout = checkReporting(varargin)
        varargout = createVariables(varargin)
        
        function obj = set.dataOrig(obj,value)    
            obj.dataOrig = value;
            if obj.doUpdate %#ok<MCSUP>
                obj = updateOptionsData(obj);
            end
        end
        
    end
    
    methods (Hidden = true)  
        
        function obj = setReporting(obj,input)
            obj.reporting = input;
        end
        function obj = setTransformations(obj,input,fcstHorizon) 
            obj.transformations = input;
            if nargin == 3
                obj.fcstHorizon = fcstHorizon;
            end
        end
        
        function newOrig = getOrigData(obj,dataT)  
        % Caution: In old version we needed to remove past called  
        % createShift and createVariable methods. We need to secure 
        % backward compability so we construct dataOrig here once!
        %
        % This is called inside unstruct methods!
        
            if ~isempty(obj.transformations)
        
                if isUpdateable(dataT)

                    links = get(dataT,'links');
                    if numel(links) > 1
                        error([mfilename ':: Contact Kenneth Sæterhagen Paulsen.'])
                    end
                    operations  = links.subLinks(1).operations;
                    shiftFound  = false;
                    createFound = false;
                    removeInd   = false(1,length(operations));
                    for ii = length(operations):-1:1
                        opTemp = operations{ii};
                        if ischar(opTemp{1})
                            strFun = opTemp{1};
                        else
                            strFun = func2str(opTemp{1});
                        end
                        if strcmpi(strFun,'checkExpressions')
                            removeInd(ii) = true;
                        end
                        if strcmpi(strFun,'createShift')
                            shiftFound    = true;
                            removeInd(ii) = true;
                        end
                        if shiftFound
                            if strcmpi(strFun,'createVariable')
                                createFound   = true;
                                removeInd(ii) = true;
                                break
                            end
                        end
                    end
                    if shiftFound && createFound
                        operations = operations(~removeInd);
                        links.subLinks(1).operations = operations;
                        dataT = setLinks(dataT,links);
                        dataT = update(dataT);
                    end

                else
                    % Must delete previously created variables 
                    dataT = deleteVariables(dataT,obj.transformations(:,1)');
                end
                
            end
            
            if ~isempty(obj.reporting)
            
                if isUpdateable(dataT)
                
                    links = get(dataT,'links');
                    if numel(links) > 1
                        error([mfilename ':: Contact Kenneth Sæterhagen Paulsen.'])
                    end
                    operations = links.subLinks(1).operations;
                    checkFound = false;
                    removeInd  = false(1,length(operations));
                    for ii = length(operations):-1:1
                        opTemp = operations{ii};
                        if ischar(opTemp{1})
                            strFun = opTemp{1};
                        else
                            strFun = func2str(opTemp{1});
                        end
                        if strcmpi(strFun,'checkExpressions')
                            checkFound    = true;
                            removeInd(ii) = true;
                            break
                        end
                    end
                    if checkFound
                        operations = operations(~removeInd);
                        links.subLinks(1).operations = operations;
                        dataT = setLinks(dataT,links);
                        dataT = update(dataT);
                    end

                else
                    % Must delete previously created variables 
                    dataT = deleteVariables(dataT,obj.reporting(:,1)');
                end
                
            end
            
            % Assign output
            newOrig = dataT;

        end
        
    end
    
    methods (Access=public,Hidden=true)
       
        function [obj,plotterC] = updateOptionsData(obj,dataNew)
        
            if nargin == 2
                obj.doUpdate = false;
                obj.dataOrig = dataNew;
                obj.doUpdate = true;
            end
            
            plotterC               = [];
            obj.preventSettingData = false;
            obj.options.data       = breakLink(obj.dataOrig);
            if ~isempty(obj.transformations)
                
                % Create model variables 
                obj.options.data = createVariable(obj.dataOrig,obj.transformations(:,1,end)',obj.transformations(:,2,end)');

                % Crate shift variables
                if nargout > 1
                    [obj.options.data,obj.options.shift,plotterC] = createShift(obj.options.data,obj.fcstHorizon,obj.transformations(:,1,end)',obj.transformations(:,3,end)');
                else
                    [obj.options.data,obj.options.shift] = createShift(obj.options.data,obj.fcstHorizon,obj.transformations(:,1,end)',obj.transformations(:,3,end)'); 
                end
                
            end
            
            if ~isempty(obj.reporting)
                
                % Check reporting
                if isfield(obj.options,'shift')
                    shift = obj.options.shift;
                else
                    shift = [];
                end
                if isa(obj,'nb_dsge')
                    
                    % In the case of DSGE model we also want to make it
                    % possible to report variables that are function of 
                    % unobserved variables as well
                    try
                        smoothed = getFiltered(obj);
                    catch
                        smoothed = nb_ts;
                    end
                    
                    if ~isempty(smoothed)
                        indRemove = ismember(smoothed.variables,obj.options.data.variables);
                        smoothed  = deleteVariables(smoothed,smoothed.variables(indRemove));
                        if ~isempty(smoothed)
                            if obj.options.data.startDate > smoothed.startDate
                                startDate = obj.options.data.startDate;
                            else
                                startDate = '';
                            end
                            if obj.options.data.endDate < smoothed.endDate
                                endDate = obj.options.data.endDate;
                            else
                                endDate = '';
                            end
                            smoothed = window(smoothed,startDate,endDate);
                        end
                    end
                    
                    % Merge smoothed and actual data
                    obj.options.data = merge(obj.options.data,smoothed);
                    obj.options.data = checkExpressions(obj.options.data,obj.reporting,shift);
                    
                else
                    obj.options.data = checkExpressions(obj.options.data,obj.reporting,shift);
                end
                 
            end
            obj.preventSettingData = true;
            
        end
        
    end
    
end
