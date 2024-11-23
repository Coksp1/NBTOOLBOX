function [AB,BB,CB,CEB,ssB,JACB,err] = solveBreakPoints(options,beta,A,B,C,CE,ss,JAC,silent)
% Syntax:
%
% [AB,BB,CB,CEB,ssB,JACB,err] = nb_dsge.solveBreakPoints(options,...
%                                           beta,A,B,C,CE,ss,JAC,silent)
%
% Description:
%
% Solve for all the break-points regimes.
% 
% Input:
% 
% - options : See the estOptions property of the nb_dsge class.
%
% - beta    : A nParam x 1 double with the parameter values in the main 
%             regime. 
%
% - A       : State transition matrix in main regime.
%
% - B       : Constant term
%
% - C       : The impact of shock matrix in main regime.
%
% - CE      : The impact of anticipated shock matrix in main regime.
%
% - ss      : The steady-state in the main regime.
%
% - JAC     : The jacobian of the main regime.
%
% Output:
% 
% - AB      : A 1 x nBreaks + 1 cell with the state transition matrices 
%             of all regimes.
%
% - BB      : A 1 x nBreaks + 1 cell with the constant term.
%
% - CB      : A 1 x nBreaks + 1 cell with the impact of shock matrices of 
%             all regimes.
%
% - CEB     : A 1 x nBreaks + 1 cell with the impact of anticipated shock 
%             matrices of all regimes.
%
% - ssB     : A 1 x nBreaks + 1 cell with the steady-state of all regimes.
%
% - JACB    : A 1 x nBreaks + 1 cell with the jacobian matrices of all
%             regimes.
%
% - err     : Non-empty if an error is thrown. If this output is not return
%             a standard error is thrown in the command window.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 9
        silent = true;
    end

    parser  = options.parser;
    nBreaks = parser.nBreaks;
    
    % Preallocate and assign starting regime
    AB      = cell(1,nBreaks + 1);
    BB      = AB;
    CB      = AB;
    CEB     = AB;
    ssB     = AB;
    JACB    = AB;
    AB{1}   = A;
    BB{1}   = B;
    CB{1}   = C;
    CEB{1}  = CE;
    ssB{1}  = ss;
    JACB{1} = JAC;
    
    % Are we using the steady_state_first operator?
    if isfield(parser,'steadyStateFirstUsed')

        if parser.steadyStateFirstUsed
            
            eqs        = nb_func2Cellstr(options.parser.eqFunction);
            index      = regexp(eqs,'steady_state_first\(vars\((\d+)\)\)','tokens');
            changed    = ~cellfun(@isempty,index);
            index      = [index{:}];
            index      = [index{:}];
            indexD     = cellfun(@(x)str2double(x),index);
            vars       = nb_dsge.getOrderingNB(parser);
            ssFirst    = vars(indexD);
            
            % Add steady-state from first regime as temporary variables
            nNewPars   = length(parser.parameters) + 1: length(parser.parameters) + length(ssFirst);
            ssFirstSub = strcat('pars(',cellstr(num2str(nNewPars')),')');
            for ii = 1:length(ssFirst)
                eqs(changed) = strrep(eqs(changed),['steady_state_first(vars(' index{ii} '))'],ssFirstSub{ii});
            end
            [~,loc] = ismember(ssFirst,parser.endogenous);
            beta    = [beta;ss(loc)];
            
            % Need to add some dummy parameters
            options.parser.parameters = [parser.parameters, strcat(ssFirst, nb_dsge.steadyStateFirstPostfix)];
            
            % Re-create the function handles
            options.parser.eqFunction = nb_cell2func(eqs,'(vars,pars)');
            if isfield(parser,'staticFunction')
                eqs         = nb_func2Cellstr(parser.staticFunction);
                [~, indexS] = ismember(ssFirst,parser.endogenous); 
                for ii = 1:length(ssFirst)
                    eqs(changed) = strrep(eqs(changed),['steady_state_first(vars(' num2str(indexS(ii)) '))'],ssFirstSub{ii});
                end
                options.parser.staticFunction = nb_cell2func(eqs,'(vars,pars,ss_init_vars)');
            end
            
        end
        
    end
    
    % Loop each regime and solve
    breakPoints = parser.breakPoints;
    params      = options.parser.parameters;
    betaB       = beta;
    for ii = 1:nBreaks
        
        if ~silent
            disp(' ')
            disp(['At break ' toString(breakPoints(ii).date) ':'])
        end
        
        % Get the parameters of each break-point regime
        [~,locB]    = ismember(breakPoints(ii).parameters,params);
        betaB(:)    = beta;
        betaB(locB) = breakPoints(ii).values;
        
        % Solve for the companion for for each regime
        [AB{ii+1},BB{ii+1},CB{ii+1},CEB{ii+1},ssB{ii+1},JACB{ii+1},err] = nb_dsge.solveOneRegime(options,betaB,false,silent);
        if ~isempty(err)
            return
        end
        
    end
    
end
