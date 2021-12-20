function [employed,newScouts] = dance(employed,lowerBound,upperBound,F,jacobianFunction)
% Syntax:
%
% [employed,newScouts] = dance(employed,lowerBound,upperBound,F,...
%                           jacobianFunction) 
%
% Description:
%
% Make the employed bees move at random in their dancing area or some
% move by some other updating rule.
%
% Input:
% 
% - employed         : A vector of employed bees. As a vector of  
%                      nb_beeSolver objects.
% 
% - lowerBound       : See the property with the same name in the 
%                      nb_abcSolve class.
%
% - upperBound       : See the property with the same name in the 
%                      nb_abcSolve class.
%
% - jacobianFunction : See the property with the same name in the 
%                      nb_abcSolve class.
%
% Output:
% 
% - employed  : A vector of nb_beeSolver objects.
%
% - newScouts : A vector of nb_beeSolver objects. These are the once that
%               breach the bounds during the newton update.
%
% See also:
% nb_beeSolver.relocate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    nBees = size(employed,1);
    if nBees == 0
        newScouts = [];
        return
    end
    nPar = size(employed(1).current,1);
    if isempty(employed(1).maxNumberChanged)
        maxNum = nPar;
    else
        maxNum = employed(1).maxNumberChanged;
    end
    N            = size(employed(1).currentFValue,1);
    newScoutsInd = false(1,nBees);
    for ii = 1:nBees
        
        if employed(ii).method == 2
            
            % Newton update
            if isempty(jacobianFunction)
                % Uses a Steffensens update
                w   = employed(ii).current + employed(ii).currentFValue;
                JAC = nb_jacobian(F,employed(ii).current,w);
            else
                % Uses a newton update
                JAC = jacobianFunction(employed(ii).current);
            end
            test = rcond(JAC);
            if isnan(test)
                newScoutsInd(ii) = true;
            elseif test < eps
                newScoutsInd(ii) = true;
            else
                employed(ii).tested = employed(ii).current - JAC\employed(ii).currentFValue;
                if any(employed(ii).tested > upperBound | employed(ii).tested < lowerBound)
                    % Is this optimal? Or should we toss the solution
                    % candidates that breach the bound instead?? It may be
                    % optimal to let the the iterative solution candidate to
                    % go outside bounds on the way to a solution inside the
                    % bound...
                    newScoutsInd(ii) = true;
                end
            end
            
        else % Random search in the neighbourhood
        
            % Select the number of values to change
            numChange = floor(rand*maxNum) + 1;

            % Select start location of values to change
            candDraws = nPar - numChange;
            change    = floor(rand*candDraws) + 1; 
            indC      = change:change + numChange - 1;

            % Draw a new candidate
            d           = employed(ii).currentFValue./employed(ii).currentValue;
            x           = employed(ii).current;
            alpha       = rand(numChange,N);
            beta        = -1 + rand()*2; % Uniform(-1,1)
            xDraw       = x;
            xDraw(indC) = x(indC) + beta*alpha*d;
            indBreak    = xDraw(indC) > upperBound(indC) | xDraw(indC) < lowerBound(indC);
            gamma       = 0.7;
            kk          = 1;
            while any(indBreak)
                alpha              = rand(sum(indBreak),N);
                indCT              = indC(indBreak);
                xDraw(indCT)       = x(indCT) + beta*gamma^kk*alpha*d;
                indBreak(indBreak) = xDraw(indCT) > upperBound(indCT) | xDraw(indCT) < lowerBound(indCT);
                kk                 = kk + 1;
            end
            employed(ii).tested = xDraw;
        
        end
        employed(ii).trials = employed(ii).trials + 1;
        
    end
    
    if any(newScoutsInd)
        newScouts = employed(newScoutsInd);
        employed  = employed(~newScoutsInd);
    else
        newScouts = [];
    end
end
