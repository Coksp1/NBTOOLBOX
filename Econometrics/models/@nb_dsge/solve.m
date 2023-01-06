function [obj,solved] = solve(obj,varargin)
% Syntax:
%
% obj = solve(obj)
% obj = solve(obj,numAntSteps,shockProperties)
% obj = solve(obj,varargin)
%
% Description:
%
% Solve estimated/calibrated model(s) represented by nb_dsge object(s).
%
% This method uses the RISE model solver if the nb_dsge model represent a
% RISE object, and it uses the dynare developed solver if the underlying
% object is a dynare solved DSGE model. All credits should go to the 
% authors of those codes. 
%
% If the model file is of the .nb extension the solver should be credited
% the author of this function, but again this solver is based on papers 
% published by the dynare team and other. See:
%
% > "Solving rational expectations models at first order: what Dynare does" 
%   by Sebastian Villemot 
% > "Loose commitment in medium-scale macroeconomic models: 
%   Theory and an application" by Debortoli, Maih and Nunes (2010).
% > "Conditional forecast in DSGE models." by Maih (2010).
%
% Input:
%
% - obj : A vector of nb_model_generic objects.
%
% Optional inputs:
%
% Only two extra inputs (and the varargin{1} input is numeric):
%
% - varargin{1} : See nb_dsge.help('numAntSteps').
%
% - varargin{2} : See nb_dsge.help('shockProperties').
%
% OR (optionName, optionValue pairs):
%
% - 'numAntSteps'     : See nb_dsge.help('numAntSteps').
%
% - 'silent'          : See nb_dsge.help('silent').
%
% - 'shockProperties' : See nb_dsge.help('shockProperties').
%
% - 'waitbar'         : Set to nb_waitbar5 object. Only if numel(obj) > 1.
%                       It will use the maxIterations2 and status2 
%                       properties.
%
% Can also set all options of the options property. Same as 
% nb_model_estimate.set.
%
% Output:
% 
% - obj    : A vector of nb_model_generic objects, where the 
%            solved model(s) is/are stored in the property
%            solution.
%
% - solved : If nargout == 2 this method will not throw an error in the 
%            case an element does not solve, instead it will set the 
%            corresponding element of this output to false, and return the
%            un-solved nb_dsge object array.
%
% See also:
% nb_model_generic, nb_model_estimate.set, nb_dsge.solveNormal, 
% nb_dsge.solveExpanded
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj  = obj(:);
    nobj = numel(obj);
    if nobj == 0
        error('Cannot solve an empty vector of nb_dsge objects.')
    elseif nobj > 1
        
        waitbar = nb_parseOneOptional('waitbar',[],varargin{:});
        if isempty(waitbar)
            update = false;
        else
            if ~isa(waitbar,'nb_waitbar5')
                error([mfilename ':: The ''waitbar'' input must be set to a nb_waitbar5 object or empty.'])
            end
            update                 = true;
            waitbar.maxIterations2 = nobj;
            note                   = nb_when2Notify(nobj);
        end
        
        if nargout > 1
           solved = true(1,nobj); 
        end
        for ii = 1:nobj
            
            try
                obj(ii) = solve(obj(ii),varargin{:});
            catch Err
                if nargout > 1
                    solved(ii) = false;
                else
                    error(['Cannot solve the model '  int2str(ii) '. Error message:: ' Err.message])
                end
            end
            
            if update
                if waitbar.canceling
                    error('User terminated')
                end
                if rem(ii,note) == 0
                    waitbar.status2 = ii;
                end
            end
            
        end
        
    else
        
        % Are we doing the expanded solution or not?
        expanded = false;
        if nargin == 3
            % To keep it robust to old version!
            numAntSteps = varargin{1};
            if isnumeric(numAntSteps) 
                shockProperties = varargin{2};
                expanded        = true;
            else
                obj = set(obj,varargin{:});
            end
        else
            obj = set(obj,varargin{:});
        end
        
        % Solve the model
        %------------------------------------------------------
        solved = true;
        if isNB(obj)
            if expanded
                obj = set(obj,'numAntSteps',numAntSteps,'shockProperties',shockProperties);
            end
            try
                obj = solveNB(obj);
            catch Err
                if nargout > 1
                    solved = false;
                else
                    rethrow(Err)
                end
            end
        else
            
            if ~expanded
                numAntSteps     = obj.options.numAntSteps;
                shockProperties = obj.options.shockProperties;
                if ~isempty(numAntSteps) && ~isempty(shockProperties)
                    expanded = true;
                end
            end
            
            results = obj.results;
            opt     = getEstimationOptions(obj);
            opt     = opt{1};
            if expanded
                model   = obj.solution; % Already solved model
                tempSol = nb_dsge.solveExpanded(model,results,opt,numAntSteps,shockProperties);
            else
                [tempSol,opt] = nb_dsge.solveNormal(results,opt);
            end
            
            if isRise(obj)
                tempSol.type = 'rise';
            else
                tempSol.type = 'dynare';
            end

            % Assign solution
            %------------------------------------------------------
            obj.solution   = tempSol;
            obj.estOptions = opt;
            
        end
        
    end

end
