classdef nb_bee
% Description:
%
% A class representing a bee in the artificial bee colony (ABC) algorithm 
% by Karaboga et. al (2012) or the constrained version by Stanarevic et. 
% al (2015).
%
% Constructor:
%
%   obj = nb_bee(n);
% 
%   Input:
%
%   - n   : Number of objects to initialize, as a scalar integer.
% 
%   Output:
% 
%   - obj : An object of class nb_bee.
% 
% See also: 
% nb_abc, nb_abc.call
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties (SetAccess=protected)
       
        % Current location of the bee. Used by employed bees only.
        current             = [];
        
        % Indicate if the current point is feasible or not given the
        % constraints. Default is true.
        currentFeasible     = true;
        
        % Current objective value of the bee. Used by employed bees only.
        currentValue        = inf;
        
        % Current constraint violation of the bee. Used by employed bees 
        % only.
        currentViolation    = inf;
        
        % The fitness at the current point. Used by employed bees only.
        fitness             = 0;
        
        % The index of the employed bee that the onlooker bee is dancing
        % with. Used by onlooker bees only.
        index               = 1;
        
        % Tested location of the bee.
        tested              = [];
        
        % Indicate if the tested point is feasible or not given the
        % constraints. Default is false.
        testedFeasible      = true;
        
        % Objective value of the bee at the tested location.
        testedValue         = inf;
        
        % Constraint violation of the bee at the tested location.
        testedViolation     = inf;
        
        % The number of trials at the current area. Used by employed bees
        % only.
        trials              = 0;
        
        % The type of bee. Either 'employed' or 'onlooker'.
        type                = 'onlooker';
        
    end
    
    methods
        
        function obj = nb_bee(n)
            
            if nargin == 0
                return
            end
            obj = obj(ones(1,n),:); % Duplicate objects
            
        end
       
    end
    
    methods (Static=true)
        varargout = drawCandidates(varargin)
    end
    
end

