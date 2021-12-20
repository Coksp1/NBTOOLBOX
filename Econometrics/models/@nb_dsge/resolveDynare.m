function resolveDynare(results)
% Syntax:
%
% nb_dsge.resolveDynare(results)
%
% Description:
%
% Assign estimated/calibrated parameters to dynare and resolve DSGE model.
%
% This function calls Dynare function resol.
% 
% See also:
% nb_dsge.solveNormal, nb_dsge.solvExpanded, resol
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    global M_ oo_ options_

    % Assign the parameters
    M_.params  = results.beta;
    M_.Sigma_e = results.sigma;

    % Find the new solution
    if options_.partial_information == 1 || options_.ACES_solver == 1
        error([mfilename ':: The nb_dsge class does not handle partial information models.'])
    end
    
    try
        try
            [oo_.dr, info] = resol(oo_.steady_state,0);
        catch % Newer versions
            [oo_.dr,info] = resol(0,M_,options_,oo_);
        end
    catch Err
        nb_error('Model could not be solve with the assign coefficients. Error:',Err)
    end
        
    if info(1)
        print_info(info, options_.noprint);
        error('See message above')
    end

end

