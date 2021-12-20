function obj = joinDance(obj,employed,lowerBound,upperBound,local)
% Syntax:
%
% obj = joinDance(obj,employed,lowerBound,upperBound,local) 
%
% Description:
%
% Make the onlooker or scout bees find a employed bee to dance with.
%
% Input:
% 
% - obj        : A vector of onlookers bees, as a vector of nb_beeSolver 
%                objects.
% 
% - See the properties with the same names in the nb_abcSolve class.
%
% Output:
% 
% - obj : A vector of nb_beeSolver objects.
%
% See also:
% nb_beeSolver.relocate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    nEmployed = size(employed,1);
    if any(nEmployed == [0,1])
        if ~local
            % Currently no employed bees, so we let the onlooker bees scout 
            % for new source, and therefore compete with the employed bees
            % after they also have found a new source
            obj = scout(obj,lowerBound,upperBound);
        end
        return
    end

    % Find the employed bee to dance with. Here we assign higher
    % probability for the onlookers to go to the employed bees that are
    % performing the best
    nBees    = size(obj,1);
    prob     = calculateProbabilities(employed);
    empDraw  = rand(nBees,1);
    for ii = 1:nBees        
        obj(ii).index = find(empDraw(ii) < prob,1);        
    end
    
    % Then we let the onlooker bees dance in the area they have been placed
    nPar = size(employed(1).current,1);
    if isempty(employed(1).maxNumberChanged)
        maxNum = nPar;
    else
        maxNum = employed(1).maxNumberChanged;
    end
    for ii = 1:nBees
        
        % Select the number of values to change
        numChange = floor(rand*maxNum) + 1;
        
        % Select start location of values to change
        candDraws = nPar - numChange;
        change    = floor(rand*candDraws) + 1;
        indC      = change:change + numChange - 1;
       
        % Select another employed bee at random
        jj = obj(ii).index;
        while jj == obj(ii).index 
            jj = floor(rand*nEmployed) + 1;
        end
        
        % Get the values of the employed bee that the onlooker matched with
        x = employed(obj(ii).index).current; 
        
        % Draw a new candidate solution
        xDraw       = x;
        xDraw(indC) = inf;
        indBreak    = xDraw(indC) > upperBound(indC) | xDraw(indC) < lowerBound(indC);
        while any(indBreak)
            indCT              = indC(indBreak);
            phi                = -1 + rand*2; % Select random numbers in [-1,1]
            xDraw(indCT)       = x(indCT) + phi*(x(indCT) - employed(jj).current(indCT));
            indBreak(indBreak) = xDraw(indCT) > upperBound(indCT) | xDraw(indCT) < lowerBound(indCT);
        end
        obj(ii).tested = xDraw;
        
    end
     
end
