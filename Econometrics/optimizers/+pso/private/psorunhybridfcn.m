function [xOpt,fval] = psorunhybridfcn(fitnessfcn,xOpt,...
    Aineq,bineq,Aeq,beq,LB,UB,nonlcon,options)
% Calls the hybrid function defined in options.HybridFcn, from PSO.

if iscell(options.HybridFcn)
    HybridFcn = options.HybridFcn{1} ;
    hybridOptions = options.HybridFcn{2} ;
else
    HybridFcn = options.HybridFcn ;
    hybridOptions = optimset('Display',options.Display,...
        'LargeScale','off') ;
    if isfield(hybridOptions,'Algorithm')
        hybridOptions.Algorithm = 'active-set' ;
    end
end

if options.Verbosity > 1
    fprintf('\nBest point before hybrid function: %s',...
        mat2str(xOpt,5))
    fprintf('\n\nTurning over to hybrid function %s...\n\n',...
        func2str(HybridFcn))
end

if exist(func2str(HybridFcn),'file') ~= 2
    warning('pso:hybridfcn:nofile',...
        'Hybrid function %s cannot be found. Check toolboxes.',...
        func2str(HybridFcn))
    fval = fitnessfcn(xOpt) ;
    return
end

% Check for constrainted vs. unconstrained problem
if strcmp(func2str(HybridFcn),func2str(@fmincon)) && ...
        all([isempty([Aineq,bineq]), isempty([Aeq,beq]), ...
        isempty([LB;UB]),isempty(nonlcon)])
    % If hybrid function is fmincon and there are no constraints,
    % automatically switch to fminunc
    if options.Verbosity > 2
        msg = sprintf('%s does not accept problems without',...
            func2str(HybridFcn)) ;
        warning('%s constraints. Switching to fminunc.\n\n',msg)
    end % if options.Verbosity
    HybridFcn = @fminunc ;
elseif (strcmp(func2str(HybridFcn),func2str(@fminunc)) || ...
        strcmp(func2str(HybridFcn),func2str(@fminsearch))) && ...
        ~all([isempty([Aineq,bineq]), isempty([Aeq,beq]), ...
        isempty([LB;UB]),isempty(nonlcon)])
    % If hybrid function is fminunc and there are constraints,
    % automatically switch to fmincon
    if options.Verbosity > 2
        msg = sprintf('%s does not accept problems with',...
            func2str(HybridFcn)) ;
        warning('%s constraints. Switching to fmincon.\n\n',msg)
    end % if options.Verbosity
    HybridFcn = @fmincon ;
end

if strcmp(func2str(HybridFcn),func2str(@fmincon)) || ...
        strcmp(func2str(HybridFcn),func2str(@patternsearch))
    % Constrained
    [xOpt,fval] = HybridFcn(fitnessfcn,xOpt,Aineq,bineq,...
        Aeq,beq,LB,UB,nonlcon,hybridOptions) ;
elseif strcmp(func2str(HybridFcn),func2str(@fminunc)) || ...
        strcmp(func2str(HybridFcn),func2str(@fminsearch))
    % Unconstrained
    [xOpt,fval] = HybridFcn(fitnessfcn,xOpt,hybridOptions) ;
elseif options.Verbosity > 2
    warning('pso:hybridfcn:unrecognized',...
        'Unrecognized hybrid function. Ignoring for it now.')
end
