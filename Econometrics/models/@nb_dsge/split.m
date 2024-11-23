function objVec = split(obj)
% Syntax:
%
% objVec = split(obj)
%
% Description:
%
% Split a NB toolbox or RISE solved DSGE model into seperates objects for
% each regime.
%
% Caution : In the case of a RISE object, calling solve again on the object
%           will result in the a object with more regimes!
% 
% Input:
% 
% - obj : An object of class nb_dsge, either solved with the NBToolbox or
%         RISE.
% 
% Output:
% 
% - objVec : A vector of nb_dsge object representing each regime.
%
% See also:
% nb_dsge.solve
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isscalar(obj)
        error([mfilename ':: The input must be a scalar nb_dsge object.'])
    end
    
    if isNB(obj)
        
        parser      = obj.parser;
        nBreaks     = parser.nBreaks;
        breakPoints = parser.breakPoints;
        if nBreaks < 1
            objVec = obj;
            return
        end
        parser.breakPoints  = [];
        parser.nBreaks      = 0;
        objVec(nBreaks+1,1) = nb_dsge();
        beta                = obj.results.beta;
        betaB               = beta;
        
        % Separate out the main period
        objVec(1)                   = obj;
        objVec(1).estOptions.parser = parser;
        
        % Separate out a object for each of the breaks
        for ii = 2:nBreaks+1
            
            objVec(ii) = obj;
            
            % Get the parameters of each break-point regime
            [~,locB]                = ismember(breakPoints(ii-1).parameters,parser.parameters);
            betaB(:)                = beta;
            betaB(locB)             = breakPoints(ii-1).values;
            objVec(ii).results.beta = betaB;
            
            % Update the parser, so resolving is supported.
            objVec(ii).estOptions.parser = parser;
            
            % Split the solution property
            if issolved(obj)
                objVec = splitSolution(obj,objVec);
            end
            
            % Set the name of the model to the break date
            objVec(ii) = set(objVec(ii),'name',toString(breakPoints(ii-1).date));
            
        end
        
    elseif isRise(obj)
        if issolved(obj)
            nRegimes = length(obj.solution.A);
            objVec   = splitSolution(obj,obj(ones(1,nRegimes),1));
        else
            error([mfilename ':: You first need to solve the nb_dsge object when dealing with RISE.'])
        end
    else
        error([mfilename ':: Model is solved with Dynare, so there is nothing to split.'])
    end
    
end

%==========================================================================
function objVec = splitSolution(obj,objVec)

    s        = obj.solution;
    nRegimes = length(s.A);
    for ii = 1:nRegimes
        sBreak          = s;
        sBreak.ss       = s.ss{ii};
        sBreak.jacobian = s.jacobian{ii};
        sBreak.breaks   = [];
        sBreak.A        = s.A{ii};
        sBreak.C        = s.C{ii};
        sBreak.B        = s.B{ii};
        sBreak.vcv      = s.vcv{ii};
        if isfield(sBreak,'CE')
            sBreak.CE = s.CE{ii};
        end
        objVec(ii).solution = sBreak; 
    end

end
