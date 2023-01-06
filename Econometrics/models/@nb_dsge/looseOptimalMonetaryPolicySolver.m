function [H,D,DE,parser,err] = looseOptimalMonetaryPolicySolver(parser,solution,options,expandedOnly)
% Syntax:
%
% [H,D,DE,parser,err] = ...
%       nb_dsge.looseOptimalMonetaryPolicySolver(parser,solution,...
%                   options,expandedOnly)
%
% Description:
%
% This static method of the nb_dsge class implements the algorithm 
% presented by; Debortoli, Maih and Nunes (2010) "Loose commitment in 
% medium-scale macroeconomic models: Theory and an application". 
%
% All credits should go to the authors of that paper for the solution and 
% not the writer of this code.
%
% Input:
% 
% - parser       : See nb_dsge.solveNB
%
% - solution     : See nb_dsge.solveNB
% 
% - options      : See nb_dsge.solveNB
%
% - expandedOnly : true if only the expanded solution is to be solved for.
%
% Output:
% 
% - H        : Transition matrix, as a nEndo + nMult x nEndo + nMult.
%
% - D        : Shock impact matrix as a nEndo + nMult x nExo.
%
% - DE       : Shock impact matrix as a nEndo x nExo x nHor, when solved
%              with anticipated shocks, otherwise [].
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    persistent H0;
    err = '';
    
    % Get the options
    beta        = options.lc_discount;
    gam         = options.lc_commitment;
    reConvexify = options.lc_reconvexify;
    tol         = options.fix_point_TolFun;
    maxIter     = options.fix_point_maxiter;
    init        = options.solve_initialization;
    if isempty(init)
        init = 'last';
    end
    
    % Get the jacobian
    JAC = full(solution.jacobian);
    if max(abs(imag(JAC(:)))) < eps^(0.8)
        JAC = real(JAC);
    else
        err = [mfilename ':: Cannot solve the model the jacobian is not real.'];
        if nargout < 5
            error(err)
        else
            [H,D,DE,parser] = errorReturn();
            return    
        end
    end
    
    % Get the structural representation of the restriction to optimze over
    if isfield(parser,'isMultiplier')
        % Remove multipliers when already solved under optimal monetary
        % policy
        parser.leadCurrentLag = parser.leadCurrentLag(~parser.isMultiplier,:);
    end
    if expandedOnly
        parserT           = nb_rmfield(parser,'block'); 
        [Alead,A0,Alag,B] = nb_dsge.jacobian2StructuralMatricesNB(JAC,parserT);
    else
        [Alead,A0,Alag,B] = nb_dsge.jacobian2StructuralMatricesNB(JAC,parser);
    end
    Alead = nb_dsge.applyDiscount(options,Alead);
    
    % Get indexes once and for all
    nExo          = size(B,2);
    [nMult,nEndo] = size(A0);
    nEqs          = nMult + nEndo;
    i1            = 1:nMult;  
    i2            = 1:nEndo;  
    i3            = nMult+1:nEqs; 
    i4            = nEndo+1:nEqs;
    
    if ~expandedOnly
    
        % Get starting value for the fixed point iterations
        %------------------------------------------------------------------
        if strcmpi(init,'last')
            
            if size(H0,1) ~= nEqs 
                % The new model is not the same as the old, so to use the 
                % the old as a guess does not work!
                H0 = [];
            end
            
            if isempty(H0)
                % Uses commitment solution
                options.lc_commitment = 1;
                [H0,~,~,~,err]        = nb_dsge.optimalMonetaryPolicySolver(parser,solution,options,false,false);
                if ~isempty(err)
                    if nargout < 5
                        error(err)
                    else
                        [H,D,DE,parser] = errorReturn();
                        return    
                    end
                end
                options.lc_commitment = gam;
            end

        elseif strcmpi(init,'load') 
            
            saveH0 = false;
            if isempty(H0) 
                % Try to load from file as H0 has not been set after a 
                % clearing of memory. We only want to load in this case as
                % we want to use the last solution during estimation etc.
                [H0,~] = nb_loadFromUserpath('H0');
                saveH0 = true;
            end
            if size(H0,1) ~= nEqs 
                % The new model is not the same as the old, so to use the 
                % the old as a guess does not work!
                H0 = [];
            end
            if isempty(H0)
                % Uses commitment solution
                options.lc_commitment = 1;
                [H0,~,~,~,err]        = nb_dsge.optimalMonetaryPolicySolver(parser,solution,options,false,false);
                if ~isempty(err)
                    if nargout < 5
                        error(err)
                    else
                        [H,D,DE,parser] = errorReturn();
                        return    
                    end
                end
                options.lc_commitment = gam;
            end
               
        elseif strcmpi(init,'zeros')
            H0 = zeros(nEqs); % Initial guess
        elseif strcmpi(init,'backward')
            H0        = zeros(nEqs); 
            H0(i2,i2) = A0\Alag; % Initial guess, use backward solution for Hyy
        elseif strcmpi(init,'commitment')
            options.lc_commitment = 1;
            H0                    = nb_dsge.optimalMonetaryPolicySolver(parser,solution,options,false,false);
            options.lc_commitment = gam;
        else
            err = [mfilename ':: Only possible to initialize the fixed point problem under optimal monetary ',...
                             'policy with zeros or the backward solution, if you use the NB Toolbox parser.'];
            if nargout < 5
                error(err)
            else
                [H,D,DE,parser] = errorReturn();
                return    
            end
        end
        
        crit   = inf;
        iter   = 0;
        
        % Get lag loose commitment matrices (Here the multipliers are 
        % ordered last)
        %------------------------------------------------------------------
        
        % Loss function 2. order derivative
        W = solution.W; 
        if options.blockDecompose && isfield(parser,'block')
            W = W(~parser.block.epiEndo,~parser.block.epiEndo);
        end
        
        GAM1        = zeros(nEqs);
        GAM1(i1,i2) = Alag;
        if reConvexify
            GAM1(i3,i4) = gam/beta*Alead';
        else
            GAM1(i3,i4) = (gam>0)/beta*Alead';
        end 
        GAMv       = zeros(nEqs,nExo);
        GAMv(i1,:) = B; 
        GAM0       = zeros(nEqs);
        
        % Do the fix point iterations
        %------------------------------------------------------------------
        if options.fix_point_verbose
            
            bAlagT  = beta*Alag';
            A0T     = A0';
            W2      = 2*W;
            gAlead  = gam*Alead;
            gbAlagT = gam*beta*Alag';
            while crit > tol

                AleadH      = Alead*H0(i2,i2);
                GAM0(i1,i2) = A0 + AleadH;
                GAM0(i1,i4) = gAlead*H0(i2,i4);
                GAM0(i3,i2) = W2 + bAlagT*H0(i4,i2); % Indexing is much faster than concatenating!
                GAM0(i3,i4) = A0T + (1-gam)*AleadH' + gbAlagT*H0(i4,i4);
                if rcond(GAM0) < options.rcondTol
                    err = [mfilename ':: No solution found with optimal policy. Matrix singular.'];
                    if nargout < 5
                        error(err)
                    else
                        [H,D,DE,parser] = errorReturn();
                        return    
                    end
                end
                H    = -GAM0\GAM1;           
                crit = max(abs(H(:) - H0(:))); % Maximum distance of any single element as criteria
                iter = iter + 1;
                H0   = H;
                if iter > maxIter
                    err = [mfilename ':: No solution found with optimal policy. Too many iterations'];
                    if nargout < 5
                        error(err)
                    else
                        [H,D,DE,parser] = errorReturn();
                        return    
                    end
                end
                
                if rem(iter,10) == 0
                    disp(['Criteria at iteration ' int2str(iter) ': ' num2str(crit)])
                end

            end
           
        %------------------------------------------------------------------    
        else % Not report status during fixed point iterations
        %------------------------------------------------------------------
        
            if gam == 1 % Commitment

                bAlagT = beta*Alag';
                A0T    = A0';
                W2     = 2*W;
                while crit > tol

                    % Indexing is much faster than concatenating!
                    GAM0(i1,i2) = A0 + Alead*H0(i2,i2);
                    GAM0(i1,i4) = Alead*H0(i2,i4);
                    GAM0(i3,i2) = W2 + bAlagT*H0(i4,i2); 
                    GAM0(i3,i4) = A0T + bAlagT*H0(i4,i4);
                    if rcond(GAM0) < options.rcondTol
                        err = [mfilename ':: No solution found with optimal policy. Matrix singular.'];
                        if nargout < 5
                            error(err)
                        else
                            [H,D,DE,parser] = errorReturn();
                            return    
                        end
                    end
                    H           = -GAM0\GAM1;           
                    crit        = max(abs(H(:) - H0(:))); % Maximum distance of any single element as criteria
                    iter        = iter + 1;
                    H0          = H;
                    if iter > maxIter
                        err = [mfilename ':: No solution found with optimal policy. Too many iterations'];
                        if nargout < 5
                            error(err)
                        else
                            [H,D,DE,parser] = errorReturn();
                            return    
                        end
                    end

                end

            else

                bAlagT = beta*Alag';
                A0T    = A0';
                W2     = 2*W;
                if gam == 0 % Discretion

                    while crit > tol

                        A0AleadH    = A0 + Alead*H0(i2,i2);
                        GAM0(i1,i2) = A0AleadH;
                        GAM0(i3,i2) = W2 + bAlagT*H0(i4,i2); % Indexing is much faster than concatenating!
                        GAM0(i3,i4) = A0AleadH';
                        if rcond(GAM0) < options.rcondTol
                            err = [mfilename ':: No solution found with optimal policy. Matrix singular.'];
                            if nargout < 5
                                error(err)
                            else
                                [H,D,DE,parser] = errorReturn();
                                return    
                            end
                        end
                        H    = -GAM0\GAM1;           
                        crit = max(abs(H(:) - H0(:))); % Maximum distance of any single element as criteria
                        iter = iter + 1;
                        H0   = H;
                        if iter > maxIter
                            err = [mfilename ':: No solution found with optimal policy. Too many iterations'];
                            if nargout < 5
                                error(err)
                            else
                                [H,D,DE,parser] = errorReturn();
                                return    
                            end
                        end
                    end

                else % Loose commitment

                    gAlead  = gam*Alead;
                    gbAlagT = gam*beta*Alag';
                    while crit > tol

                        AleadH      = Alead*H0(i2,i2);
                        GAM0(i1,i2) = A0 + AleadH;
                        GAM0(i1,i4) = gAlead*H0(i2,i4);
                        GAM0(i3,i2) = W2 + bAlagT*H0(i4,i2); % Indexing is much faster than concatenating!
                        GAM0(i3,i4) = A0T + (1-gam)*AleadH' + gbAlagT*H0(i4,i4);
                        if rcond(GAM0) < options.rcondTol
                            err = [mfilename ':: No solution found with optimal policy. Matrix singular.'];
                            if nargout < 5
                                error(err)
                            else
                                [H,D,DE,parser] = errorReturn();
                                return    
                            end
                        end
                        H    = -GAM0\GAM1;           
                        crit = max(abs(H(:) - H0(:))); % Maximum distance of any single element as criteria
                        iter = iter + 1;
                        H0   = H;
                        if iter > maxIter
                            err = [mfilename ':: No solution found with optimal policy. Too many iterations'];
                            if nargout < 5
                                error(err)
                            else
                                [H,D,DE,parser] = errorReturn();
                                return    
                            end
                        end

                    end

                end

            end
            
        end
        
        % Finalize solution
        %------------------------------------------------------------------
        if strcmpi(init,'load') 
            if saveH0
                nb_save2Userpath('H0',H0);
            end
        end
        
        if crit > tol % Due to:: rcond(GAM0) < options.rcondTol
            err = [mfilename ':: No solution found with optimal policy. Too many iterations'];
            if nargout < 5
                error(err)
            else
                [H,D,DE,parser] = errorReturn();
                return    
            end
        end
        D = -GAM0\GAMv;
         
        if options.blockDecompose && isfield(parser,'block')
            % Solve for the epilogue, update the lead and lag incident
            [H,D,parser] = nb_dsge.solveForEpilogue(parser,solution,H,D,Alead,Alag,'dmn');
        else
            % Update the lead and lag incident       
            parser = nb_dsge.updateLeadLagGivenOptimalPolicy(parser,Alead,Alag);
        end

        % Add the multipliers to the list of endogenous
        parser = nb_dsge.addMultipliers(parser);
        
    else
        % Get already found solution
        H = solution.A;
        D = solution.C;
        W = solution.W;
        if options.blockDecompose && isfield(parser,'block')
            % Add multipliers that are normally there, when not solved with
            % block decomposition
            m           = nEndo + nMult;
            loc         = [true(nEndo,1);~parser.block.epiEqs];
            HN          = zeros(m);
            HN(loc,loc) = H;
            H           = HN;
            DN          = zeros(m,nExo);
            DN(loc,:)   = D;
            D           = DN;
        end
        try
            GAM0 = dsge.getLooseCommitmentMatrices(H,Alag,A0,Alead,B,W,beta,gam,reConvexify);
        catch
            error([mfilename ':: This version of NB toolbox cannot solve the DSGE model under loose commitment with anticipated shocks.'])
        end
    end
       
    % Do we want the expanded solution?
    %----------------------------------------------------------------------
    if ~isempty(options.numAntSteps) && ~isempty(options.shockProperties)
        
        numAntSteps     = options.numAntSteps;
        shockProperties = options.shockProperties(solution.activeShocks);
        
        % Get the horizon of anticipation for each shock.
        [horizon,err] = nb_dsge.getHorizon(shockProperties,numAntSteps,solution);
        if ~isempty(err)
            [H,D,DE,parser] = errorReturn();
            return
        end
        
        % Only keep active shocks
        D = D(:,solution.activeShocks);
        
        % Get solution matrices on anticipated shocks
        DE = dsge.findAniticipatedMatricesLooseCommitment(D,GAM0,Alead,Alag,gam,beta,numAntSteps);
        
        % Time to set each shocks active horizon
        for j = 1:length(horizon)
            hh             = horizon(j) + 1;
            DE(:,j,hh:end) = 0;
        end
        
        if options.blockDecompose 
            % Remove unnecessary multipliers that where added earlier
            H  = H(loc,loc);
            D  = D(loc,:);
            DE = DE(loc,:,:);
        end
        
    else
        DE = [];
    end
    
end

%==========================================================================
function [H,D,DE,parser] = errorReturn()

    H      = [];
    D      = [];
    DE     = [];
    parser = [];
    
end
