classdef nb_baiPerronTestStatistic < handle
% Description:
%
% A class for doing Bai and Perron multiple structural break test.
%
% See:
%
%  Bai, Jushan and Pierre Perron (1998): "Estimating and Testing Linear
%  Models with Multiple Structural Changes," Econometrica, vol 66,?@47-78
% and
%  Bai, Jushan and Pierre Perron (2003): "Computation and Analysis of
%  Multiple Structural Change Models," Journal of Applied Econometrics, 18,
%  1-22.
%
% Constructor:
%
%   obj = nb_baiPerronTestStatistic(data,varargin)
% 
%   Input:
%
%   - data    : An object of class nb_ts. Can only consist of one
%               page (dataset).
%
%   Optional input:
%
%   - varargin : 'inputName',inputValue pairs. Will either set a
%                property of the object or one of the fields of the
%                options property. (See the static template method
%                for more.)
% 
%   Output:
% 
%   - obj      : A nb_baiPerronTestStatistic object.
% 
% See also:
% baiPerron.pbreak
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties (SetAccess=protected)
        
       % The test time-series as an nb_ts object. 
       data             = nb_ts();
        
       % The test options provided to the nb_adf, nb_phillipsPeron
       % or the nb_kpss functions.
       options          = {};
       
       % A struct storing the results of the test.
       results          = struct();
        
    end

    methods
        
        function obj = nb_baiPerronTestStatistic(data,varargin)
        % Constructor
        
            if nargin < 1
                data = [];
            end
        
            obj.data    = data;
            obj.options = nb_baiPerronTestStatistic.template();
            obj         = set(obj,varargin{:});
            
        end
        
    end
    
    methods
        
        varargout = help(varargin)
        
        varargout = print(varargin) 
        
        varargout = doTest(varargin)
        
    end
    
    methods(Static=true)
        
        varargout = template(varargin)
        
    end
    
end

