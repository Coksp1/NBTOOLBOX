classdef nb_breuschPaganTestStatistic < nb_test_generic
% Description:
%
% A class for doing the Breusch-Pagan test on an nb_singleEq object.
%
% Superclasses:
% nb_test_generic
%
% Constructor:
%
%   obj = nb_breuschPaganTestStatistic(model,varargin)
% 
%   Input:
%
%   - model    : A nb_model_generic object.
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
%   - obj      : An nb_breuschPaganTestStatistic object
% 
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    methods
        
        function obj = nb_breuschPaganTestStatistic(model,varargin)
        % Constructor
        
            if isempty(fieldnames(model.results))
                error([mfilename ':: The provided model is not estimated!'])
            end
        
            obj         = obj@nb_test_generic(model);
            obj.options = nb_breuschPaganTestStatistic.template();
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

