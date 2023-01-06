classdef nb_sarganHansenTestStatistic < nb_test_generic
% Description:
%
% A class for doing the Sargan-Hansen overidentification test.
%
% See documentation of DAG for more on this test.
%
% Superclasses:
% nb_test_generic
%
% Constructor:
%
%   obj = nb_sarganHansenTestStatistic(model,varargin)
% 
%   Input:
%
%   - model    : An nb_sarganHansenTestStatistic object.
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
%   - obj      : An nb_sarganHansenTestStatistic object
% 
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    methods
        
        function obj = nb_sarganHansenTestStatistic(model,varargin)
        % Constructor
        
            if isempty(fieldnames(model.results))
                error([mfilename ':: The provided model is not estimated!'])
            end
            
            if not(isa(model,'nb_singleEq'))
                error([mfilename ':: The Sargan-Hansen test is only supported for a single equation model (nb_singleEq).'])
            end
        
            obj         = obj@nb_test_generic(model);
            obj.options = nb_sarganHansenTestStatistic.template();
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

