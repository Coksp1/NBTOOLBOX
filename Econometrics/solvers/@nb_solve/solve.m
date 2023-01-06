function solve(obj,varargin)
% Syntax:
% 
% solve(obj,varargin)
%
% Description:
%
% Solve the problem.
% 
% Input:
% 
% - obj : An object of class nb_solve.
% 
% See also:
% nb_solve.call
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Check and get options
    check(obj);
    opt = getAllOptions(obj);
    
    % Initalize displayer
    fValInit = opt.F(opt.initialXValue);
    nb_solve.reportStatus(opt.displayer,0,opt.initialXValue,fValInit,'init');
    
    % Test the merit function
    try
        opt.meritFunction(fValInit);
    catch Err
        nb_error([mfilename ':: Merit function failed. See error above for more details.'],Err)
    end
    
    % Select the solver
    switch lower(opt.method)
        case 'dfsane'
            results = nb_solve.dfsane(opt,fValInit);
        case 'broyden'
            results = nb_solve.broyden(opt,fValInit);
        case 'newton'
            results = nb_solve.newton(opt,fValInit);
        case 'sane'
            results = nb_solve.sane(opt,fValInit);
        case 'steffensen'
            results = nb_solve.steffensen(opt,fValInit);   
        case 'steffensen2'
            results = nb_solve.steffensen2(opt,fValInit);  
        case 'ypl'
            results = nb_solve.ypl(opt,fValInit);      
        otherwise
            error([mfilename ':: Unsupported solver method ' opt.method ' for class nb_solve'])
    end
    
    % Report results back to object
    obj.x         = results.x;
    obj.fVal      = results.fVal;
    obj.exitFlag  = results.exitFlag;
    obj.iter      = results.iter;
    obj.funEvals  = results.funEvals;        
    obj.meritFVal = results.meritFVal;
    if isfield(results,'meritXChange')
        obj.meritXChange = results.meritXChange;
    end
    if isfield(results,'jacobian')
        obj.jacobian = results.jacobian;
    end

end
