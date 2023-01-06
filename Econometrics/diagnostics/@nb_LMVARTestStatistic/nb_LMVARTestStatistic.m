classdef nb_LMVARTestStatistic < nb_test_generic
% Description:
%
% A class for doing the LM autocorrelation test on a nb_var object.
%
% See the function nb_LMVARTest for more on this test.
%
% Superclasses:
% nb_test_generic
%
% Constructor:
%
%   obj = nb_LMVARTestStatistic(model,varargin)
% 
%   Input:
%
%   - model    : An nb_LMVARTestStatistic object.
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
%   - obj      : An nb_LMVARTestStatistic object
% 
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    methods
        
        function obj = nb_LMVARTestStatistic(model,varargin)
        % Constructor
        
            if isempty(fieldnames(model.results))
                error([mfilename ':: The provided model is not estimated!'])
            end
            
            if not(isa(model,'nb_var') || isa(model,'nb_favar'))
                error([mfilename ':: The Ljung-Box test is only supported for VAR (nb_var) or FA-VAR (nb_favar) model (object)'])
            end
        
            obj         = obj@nb_test_generic(model);
            obj.options = nb_LMVARTestStatistic.template();
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

