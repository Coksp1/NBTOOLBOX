classdef nb_test_generic
% Description:
%
% A overhead class to do classical test on a nb_model_generic 
% or a nb_estimator class.
%
% Constructor:
%
%   Not possible to initialize an nb_test_generic object. The class
%   is abstract.
% 
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % The nb_model_generic or nb_estimator object to be tested.
        model           = [];
        
        % A struct storing all the options for the test.
        options         = struct();
        
        % A struct storing the test results
        results         = struct();
        
    end
    
    methods
        
        function obj = nb_test_generic(model)
        % Constructor
        
            obj.model = model;
            
        end
        
    end
    
    methods
        
        function res = print(obj)
            
            res = 'Nothing to display.';
            
        end
        
    end
    
    methods(Static=true)
        
        function options = template()
        
            options = struct();
            
        end
        
    end
    
end

