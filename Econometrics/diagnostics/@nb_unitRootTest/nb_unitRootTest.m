classdef nb_unitRootTest < handle
% Description:
%
% A class for unit root testing of time-series stored in an nb_ts
% object.
%
% Constructor:
%
%   obj = nb_unitRootTest(data,type,varargin)
% 
%   Input:
%
%   - data : An object of class nb_ts. Can only consist of one
%            page (dataset).
%
%   - type : A string with either:
%
%            > 'adf'  : Augmented Dickey-Fuller Test. (nb_adf)
%                       Default.
%
%            > 'pp'   : Phillips-Peron Test. (nb_phillipsPeron)
%
%            > 'kpss' : Kwiatkowski, Phillips, Schmidt and Shin
%                       test. (nb_kpss)
%
%   Optional input:
%
%   - Depends on the type input. For information look at the 
%     documentation of the function in parentheses above.
% 
%   Output:
% 
%   - obj : An nb_unitRootTest test object.
% 
% See also: 
% nb_adf, nb_phillipsPeron, nb_kpss
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties (SetAccess=protected)
        
       % The test time-series as an nb_ts object. 
       data             = nb_ts();
        
       % A 1 x numberOfVariables struct storing the estimation
       % results (by OLS).
       estimationEq     = []; 
        
       % The test options provided to the nb_adf, nb_phillipsPeron
       % or the nb_kpss functions.
       options          = {};
       
       % A struct storing the results of the test. Will depend on 
       % the type of test. See the documentation of the functions
       % nb_adf, nb_phillipsPeron and nb_kpss for more on this 
       % structure.
       %
       % Caution : This structure will be of size 1 x 
       %           numberOfVariables. I.e. obj.results(1) stores 
       %           the test results for variable 1 in the nb_ts
       %           object.
       results          = struct();
       
       % The transformation of the input data. Either:
       %
       % > 'level'      : Do nothing (default)
       % > 'firstDiff'  : First difference
       % > 'secondDiff' : Second difference
       transformation   = 'level';
       
       % The type of test.
       type             = 'adf';
        
    end
    
    methods
        
        function obj = nb_unitRootTest(data,type,varargin)
        % Constructor    
            
            if nargin < 2
                type = 'adf';
                if nargin < 1
                    return
                end
            end
        
            if ~isa(data,'nb_ts')
                error([mfilename ':: The data input must be an nb_ts object.'])
            end
        
            if data.numberOfDatasets > 1
                error([mfilename ':: The data (nb_ts) input can only contain one page (dataset).'])
            end
            
            obj.data = data;
            obj.type = type;
            set(obj,varargin{:});
        
        end
        
        varargout = set(varargin)
        
        varargout = print(varargin)
        
    end
    
    methods(Access=protected,Hidden=true)
        
        function getTestResults(obj)
            
            if isempty(obj.data)
                warning('nb_unitRootTest:emptyData','The data property is empty.')
                return
            end
            
            % Locally transform data
            switch lower(obj.transformation)
                
                case 'level'
                    dataT = obj.data;
                case 'firstdiff'
                    dataT = diff(obj.data);
                    dataT = addPrefix(dataT,'diff_');
                    dataT = dataT(2:dataT.numberOfObservations,:,:);
                case 'seconddiff'
                    dataT = diff(diff(obj.data));
                    dataT = addPrefix(dataT,'diff^2_');
                    dataT = dataT(3:dataT.numberOfObservations,:,:);
                otherwise
                    error([mfilename ':: Non-supported transformation ' obj.transformation])
            end
            
            
            switch lower(obj.type)
                
                case 'adf'
                    
                    [res,est] = nb_adf(dataT,obj.options{:});   
                    
                case 'pp'
                    
                    [res,est] = nb_phillipsPerron(dataT,obj.options{:});   
                    
                case 'kpss'
        
                    error('Not yet finished')
                    
%                     [res,est] = nb_kpss(dataT,obj.options{:});   
                    
                otherwise
                    
                    error([mfilename ':: Unsupported test type ' obj.type])
                    
            end
            
            % Assign results 
            obj.results      = res;
            obj.estimationEq = est;
            
        end
        
    end

end
