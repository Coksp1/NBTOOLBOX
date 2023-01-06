classdef nb_beeSolver
% Description:
%
% A class representing a bee in the artificial bee colony (ABC) algorithm 
% by Karaboga et. al (2012) applied to solving the problem
%
% F(x) = 0
% s.t. x in S
%
% where F(x) is a set of non-linear solutions. S is the search space, i.e. 
% the space to look for candidate values to solve F(x) = 0. 
%
% Constructor:
%
%   obj = nb_beeSolver(n);
% 
%   Input:
%
%   - n   : Number of objects to initialize, as a scalar integer.
% 
%   Output:
% 
%   - obj : An object of class nb_beeSolver.
% 
% See also: 
% nb_abcSolve, nb_abcSolve.call
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties (SetAccess=protected)
       
        % Current location of the bee. Used by employed bees only. A
        % double with size N x 1.
        current             = [];
        
        % F(currentValue), as a double with size N x 1.
        currentFValue       = inf;
        
        % Current merit function value of the bee. Used by employed 
        % bees only. As a scalar double.
        currentValue        = inf;

        % The fitness at the current point. Used by employed bees only.
        fitness             = 0;
        
        % The index of the employed bee that the onlooker bee is dancing
        % with. Used by onlooker bees only.
        index               = 1;
        
        % Maximum number of changed parameters at a given dance. If empty
        % It gets the value N.
        maxNumberChanged    = [];
        
        % Method to use for updating the current point.
        % > 1 : Random search.
        % > 2 : Newton (either with numerical jacobian or function handle).
        %       The function handle may return a sparse matrix.
        method              = 1;
        
        % Tested location of the bee. A double with size N x 1.
        tested              = [];
        
        % F(testedValue), as a double with size N x 1.
        testedFValue        = inf;
        
        % Objective value of the bee at the tested location.
        testedValue         = inf;
        
        % The number of trials at the current area. Used by employed bees
        % only.
        trials              = 0;
        
        % The type of bee. Either 'employed' or 'onlooker'.
        type                = 'onlooker';
        
    end
    
    methods
        
        function obj = nb_beeSolver(n)
            
            if nargin == 0
                return
            end
            obj = obj(ones(1,n),:); % Duplicate objects
            
        end
       
    end
    
    methods (Static=true)
        varargout = drawCandidates(varargin)
        varargout = drawCandidatesLocal(varargin)
    end
    
end

