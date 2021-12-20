classdef nb_cointTest < handle
% Description:
%
% A class for cointegration testing of time-series stored in an 
% nb_ts object.
%
% Constructor:
%
%   obj = nb_cointTest(data,type,varargin)
% 
%   Input:
%
%   - data : An object of class nb_ts. Can only consist of one
%            page (dataset).
%
%   - type : A string with either:
%
%            > 'eg'   : Engle-Granger single equation test. 
%                       (nb_egcoint)
%
%            > 'jo'   : Johansen system test. (nb_jcoint)
%
%   Optional input:
%
%   - Depends on the type input. For information look at the 
%     documentation of the function in parentheses above.
% 
%   Output:
% 
%   - obj : An nb_cointTest test object.
% 
% See also: 
% nb_egcoint, nb_jcoint, nb_ts
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties (SetAccess=protected)
        
       % The test time-series as an nb_ts object. 
       data             = nb_ts();
        
       % A 1 x n vector of nb_olsEstimator object storing the
       % estimation results (by OLS).
       estimationEq     = []; 
        
       % The test options provided to the nb_jcoint or nb_egcoint
       % functions.
       options          = {};
       
       % A struct storing the results of the test. Will depend on 
       % the type of test. See the documentation of the functions
       % nb_egcoint and nb_jcoint for more on this structure.
       results          = struct();
       
       % The transformation of the input data. Either:
       %
       % > 'level'      : Do nothing (default)
       % > 'firstDiff'  : First difference
       % > 'secondDiff' : Second difference
       transformation   = 'level';
       
       % The type of test.
       type             = 'eg';
        
    end
    
    methods
        
        function obj = nb_cointTest(data,type,varargin)
        % Constructor    
            
            if nargin < 2
                type = 'eg';
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
                warning('nb_cointTest:emptyData','The data property is empty.')
                return
            end
            
            opt = obj.options;
            
            % Locally transform data
            switch lower(obj.transformation)
                
                case 'level'
                    dataT = obj.data;
                case 'firstdiff'
                    
                    dataT = diff(obj.data);
                    dataT = addPrefix(dataT,'diff_');
                    dataT = dataT(2:end,:,:);
                    
                    ind = find(strcmpi('dependent',opt),1);
                    if ~isempty(ind)
                        opt{ind + 1} = ['diff_' opt{ind + 1}];
                    end
                    
                case 'seconddiff'
                    
                    dataT = diff(diff(obj.data));
                    dataT = addPrefix(dataT,'diff^2_');
                    dataT = dataT(3:end,:,:);
                    
                    ind = find(strcmpi('dependent',opt),1);
                    if ~isempty(ind)
                        opt{ind + 1} = ['diff^2_' opt{ind + 1}];
                    end
                    
                otherwise
                    error([mfilename ':: Non-supported transformation ' obj.transformation])
            end
            
            
            switch lower(obj.type)
                
                case 'eg'
                    
                    [res,est] = nb_egcoint(dataT,opt{:});   
                    
                case 'jo'
                    
                    [res,est] = nb_jcoint(dataT,opt{:});   
                    
                otherwise
                    
                    error([mfilename ':: Unsupported test type ' obj.type])
                    
            end
            
            % Assign results 
            obj.results      = res;
            obj.estimationEq = est;
            
        end
        
    end

end
