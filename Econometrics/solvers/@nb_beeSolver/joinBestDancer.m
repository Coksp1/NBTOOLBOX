function joiners = joinBestDancer(joiners,minXValue,minFunctionValue,minFFunctionValue)
% Syntax:
%
% joiners = joinBestDancer(joiners,minXValue,minFunctionValue,...
%               minFFunctionValue)
%
% Description:
%
% When we use the local option, the employed bees that runs out of nectar
% (exceeds the cutLimit) goes to the best nectar location of all time.
% 
% Input:
% 
% - joiners : A vector of nb_beeSolver objects.
% 
% - Otherwise see the properties with the same names in the nb_abcSolve 
%   class.
%
% Output:
% 
% - joiners : A vector of nb_beeSolver objects.
%
% See also:
% nb_beeSolver.relocate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    nBees = size(joiners,1);
    if nBees == 0
        return
    end

    nPar = size(joiners(1).current,1);
    if isempty(joiners(1).maxNumberChanged)
        maxNum = nPar;
    else
        maxNum = joiners(1).maxNumberChanged;
    end
    N = size(joiners(1).currentFValue,1);
    for ii = 1:nBees
    
        % Select the number of values to change
        numChange = floor(rand*maxNum) + 1;

        % Select start location of values to change
        candDraws = nPar - numChange;
        change    = floor(rand*candDraws) + 1; 
        indC      = change:change + numChange - 1;

        % Draw a new candidate
        d           = minFFunctionValue;%./minFunctionValue;
        x           = minXValue;
        alpha       = rand(numChange,N);
        beta        = -1 + rand()*2; % Uniform(-1,1)
        xDraw       = x;
        xDraw(indC) = x(indC) + beta*alpha*d;
        
        % Assign to bee
        joiners(ii).tested = xDraw;
        joiners(ii).trials = 0;
        
    end

end
