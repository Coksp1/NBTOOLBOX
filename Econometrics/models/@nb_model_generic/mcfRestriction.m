function f = mcfRestriction(obj,type,restriction)
% Syntax:
%
% f = mcfRestriction(obj,type,restriction)
%
% Description:
%
% Create restriction function for use in the monteCarloFiltering method
% 
% Caution: To combine more restriction you can use @(x)f1(x)&&f2(x), where
%          f1 and f2 are the output from this function.
%
% Input:
% 
% - obj         : An object of class nb_model_generic.
% 
% - type        : The type of restriction. Either 'irf', 'corr' or 'cov'.
%
% - restriction : Depends on the type input:
%
%                 > 'irf'    : A N x 4 cell, where the elements of each 
%                              row are:
%                              1. Name of the shock. 'E_X'
%                              2. Name of the variable. 'X'
%                              3. Horizon. E.g. 1 or 1:3.
%                              4. Restriction. E.g. @(x)gt(x,0), 
%                                 @(x)gt(x,0)||lt(x,1), i.e. a 
%                                 function_handle that takes a scalar  
%                                 double as input and a scalar logical as 
%                                 output.
%
%                 > 'rirf'   : A N x 7 cell, where the elements of each 
%                              row are:
%                              1. Name of the shock 1. 'E_X'
%                              2. Name of the variable 1. 'X'
%                              3. Horizon of variable 1. E.g. 1.
%                              4. Name of the shock 2. 'E_Y'
%                              5. Name of the variable 2. 'Y'
%                              6. Horizon of variable 2. E.g. 2.
%                              7. Restriction. E.g. @(x,y)gt(x,y), 
%                                 @(x,y)gt(x-y,0)||lt(x-y,1), i.e. a 
%                                 function_handle that takes a two scalar  
%                                 double as inputs and a scalar logical 
%                                 as output.
%
%                 > 'corr'   : A N x 4 cell, where the elements of each 
%                              row are:
%                              1. Name of the first variable.
%                              2. Name of the second variable.
%                              3. Number of periods to lag the 2. variable.
%                              4. Same as 4 for 'irf'.
%
%                              E.g. {'Var1','Var1',1,@(x)gt(x,0.1)}, to
%                              test a restriction on the autocorrelation 
%                              at lag for variable 'Var1'.
%
%                              E.g. {'Var1','Var2',0,@(x)lt(x,0.1)}, to
%                              test a restriction on the contemporaneous 
%                              correlation between 'Var1' and 'Var2'.
%
%                 > 'cov'    : Same as for 'corr'.
%
%                              E.g. {'Var1','Var1',0,@(x)lt(x,0.1)}, to
%                              test a restriction on the contemporaneous 
%                              variance.
% 
%                 > 'ss'     : A N x 2 cell, where the elements of each 
%                              row are:
%                              1. The expression using any of the
%                                 endogenous variables of the model.
%                              2. Same as 4 for 'irf'. 
%
% Output:
% 
% - f : A function_handle that can be used as an input to the 
%       monteCarloFiltering method.
%
% See also:
% nb_model_generic.monteCarloFiltering, nb_model_generic.irf,
% nb_model_generic.theoreticalMoments
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen


    switch lower(type)
        case 'irf'
            
            testIrfRestriction(obj,restriction);
            f = @(x)irfRestriction(x,restriction);
            
        case 'rirf'
            
            testRirfRestriction(obj,restriction);
            f = @(x)rirfRestriction(x,restriction);
            
        case {'corr','cov'}
            
            testMomentRestriction(obj,restriction,type);
            f = @(x)momentRestriction(x,restriction,type);    
            
        case 'ss'
            
            testSSRestriction(obj,restriction);
            f = @(x)ssRestriction(x,restriction);
            
        otherwise 
            error([mfilename ':: The restriction type ' type ' is not supported'])
    end
    
end

%==========================================================================
function test = irfRestriction(obj,restriction)

    % Produce the IRFs
    shocks = restriction(:,1);
    vars   = restriction(:,2);
    nSteps = restriction(:,3);
    mSteps = max(horzcat(nSteps{:}));
    irfs   = irf(obj,'shocks',unique(shocks),'variables',unique(vars),'periods',mSteps);

    % Do the testing
    test  = true;
    funcs = restriction(:,4);
    for ii = 1:size(restriction,1)
        
        if isscalar(nSteps{ii})
            nStepsT = int2str(nSteps{ii});
            tested  = getVariable(irfs.(shocks{ii}),vars{ii},nStepsT,nStepsT);
            test    = test && funcs{ii}(tested);
            if ~test
                break;
            end
        else
            nStepsT = nSteps{ii};
            nStepsS = int2str(nStepsT(1));
            nStepsE = int2str(nStepsT(end));
            tested  = getVariable(irfs.(shocks{ii}),vars{ii},nStepsS,nStepsE);
            test    = test && all(funcs{ii}(tested));
            if ~test
                break;
            end
        end
        
    end
    
end

%==========================================================================
function testIrfRestriction(obj,restriction)

    if ~iscell(restriction)
        error([mfilename ':: The restriction input must a cell array.'])
    end
    if size(restriction,2) ~= 4
        error([mfilename ':: The restriction input must have 4 columns when type is set to ''irf''.'])
    end
    N = size(restriction,1);
    for ii = 1:N
        
        shock = restriction{ii,1};
        if ~nb_isOneLineChar(shock)
            error([mfilename ':: The first element of row ' int2str(ii) ' must be a one line char with the name of the shock to restrict.'])
        end
        if ~any(strcmpi(shock,obj.residuals.name))
            error([mfilename ':: The model does not contain any shock/residual ' shock ' (row nr ' int2str(ii) ').'])
        end
        
        var = restriction{ii,2};
        if ~nb_isOneLineChar(var)
            error([mfilename ':: The second element of row ' int2str(ii) ' must be a one line char with the name of the variable to restrict.'])
        end
        if ~any(strcmpi(var,obj.dependent.name))
            error([mfilename ':: The model does not contain any variable ' var ' (row nr ' int2str(ii) ').'])
        end
        
        hor = restriction{ii,3};
        hor = hor(:);
        if ~nb_iswholenumber(hor)
            error([mfilename ':: The third element of row ' int2str(ii) ' must be a vector of integers with the horizons to restrict.'])
        end
        if any(hor < 1)
            error([mfilename ':: The third element of row ' int2str(ii) ' must be an integer greater than 0.'])
        end
        
        rest = restriction{ii,4};
        if ~isa(rest,'function_handle')
            error([mfilename ':: The fourth element of row ' int2str(ii) ' must be a function handle.'])
        end
        try 
            ret = rest(1);
        catch
            error([mfilename ':: The fourth element of row ' int2str(ii) ' must be a function handle that takes only one input as a double.'])
        end
        if ~islogical(ret)
            error([mfilename ':: The fourth element of row ' int2str(ii) ' must be a function handle that returns either true or false.'])
        end
            
    end
    
end

%==========================================================================
function test = rirfRestriction(obj,restriction)

    % Produce the IRFs
    shocks1 = restriction(:,1);
    shocks2 = restriction(:,4);
    shocks  = [shocks1;shocks2];
    vars1   = restriction(:,2);
    vars2   = restriction(:,5);
    vars    = [vars1;vars2];
    nSteps1 = [restriction{:,3}];
    nSteps2 = [restriction{:,6}];
    nSteps  = [nSteps1,nSteps2];
    irfs    = irf(obj,'shocks',unique(shocks),'variables',unique(vars),'periods',max(nSteps));

    % Do the testing
    test  = true;
    funcs = restriction(:,7);
    for ii = 1:size(restriction,1)
        nStepsT = int2str(nSteps1(ii));
        tested1 = getVariable(irfs.(shocks1{ii}),vars1{ii},nStepsT,nStepsT);
        nStepsT = int2str(nSteps2(ii));
        tested2 = getVariable(irfs.(shocks2{ii}),vars2{ii},nStepsT,nStepsT);
        test    = test && funcs{ii}(tested1,tested2);
        if ~test
            break;
        end
    end
    
end

%==========================================================================
function testRirfRestriction(obj,restriction)

    if ~iscell(restriction)
        error([mfilename ':: The restriction input must a cell array.'])
    end
    if size(restriction,2) ~= 7
        error([mfilename ':: The restriction input must have 7 columns when type is set to ''rirf''.'])
    end
    N = size(restriction,1);
    for ii = 1:N
        
        shock = restriction{ii,1};
        if ~nb_isOneLineChar(shock)
            error([mfilename ':: The first element of row ' int2str(ii) ' must be a one line char with the name of the first shock to restrict.'])
        end
        if ~any(strcmpi(shock,obj.residuals.name))
            error([mfilename ':: The model does not contain any shock/residual ' shock ' (row nr ' int2str(ii) ').'])
        end
        
        var = restriction{ii,2};
        if ~nb_isOneLineChar(var)
            error([mfilename ':: The second element of row ' int2str(ii) ' must be a one line char with the name of the first variable to restrict.'])
        end
        if ~any(strcmpi(var,obj.dependent.name))
            error([mfilename ':: The model does not contain any variable ' var ' (row nr ' int2str(ii) ').'])
        end
        
        hor = restriction{ii,3};
        if ~nb_isScalarInteger(hor)
            error([mfilename ':: The third element of row ' int2str(ii) ' must be an integer with the horizon of the first IRF to restrict.'])
        end
        if hor < 1
            error([mfilename ':: The third element of row ' int2str(ii) ' must be an integer greater than 0.'])
        end
        
        shock2 = restriction{ii,4};
        if ~nb_isOneLineChar(shock2)
            error([mfilename ':: The fourth element of row ' int2str(ii) ' must be a one line char with the name of the second shock to restrict.'])
        end
        if ~any(strcmpi(shock2,obj.residuals.name))
            error([mfilename ':: The model does not contain any shock/residual ' shock2 ' (row nr ' int2str(ii) ').'])
        end
        
        var2 = restriction{ii,5};
        if ~nb_isOneLineChar(var2)
            error([mfilename ':: The fifth element of row ' int2str(ii) ' must be a one line char with the name of the second variable to restrict.'])
        end
        if ~any(strcmpi(var2,obj.dependent.name))
            error([mfilename ':: The model does not contain any variable ' var2 ' (row nr ' int2str(ii) ').'])
        end
        
        hor2 = restriction{ii,6};
        if ~nb_isScalarInteger(hor2)
            error([mfilename ':: The sixth element of row ' int2str(ii) ' must be an integer with the horizon of the second IRF to restrict.'])
        end
        if hor2 < 1
            error([mfilename ':: The sixth element of row ' int2str(ii) ' must be an integer greater than 0.'])
        end
        
        rest = restriction{ii,7};
        if ~isa(rest,'function_handle')
            error([mfilename ':: The seventh element of row ' int2str(ii) ' must be a function handle.'])
        end
        try 
            ret = rest(1,2);
        catch
            error([mfilename ':: The seventh element of row ' int2str(ii) ' must be a function handle that takes two scalar double as inputs.'])
        end
        if ~islogical(ret)
            error([mfilename ':: The seventh element of row ' int2str(ii) ' must be a function handle that returns either true or false.'])
        end
            
    end
    
end

%==========================================================================
function test = momentRestriction(obj,restriction,type)

    if strcmpi(type,'cov')
        typeLong = 'covariance';
    else
        typeLong = 'correlation';
    end
    
    % Calculate the moments
    vars1             = restriction(:,1);
    vars2             = restriction(:,2);
    lags              = [restriction{:,3}];
    maxLag            = max(lags);
    [out{1:maxLag+2}] = theoreticalMoments(obj,'type',typeLong);

    % Do the testing
    test  = true;
    funcs = restriction(:,4);
    for ii = 1:size(restriction,1)
        tested  = getVariable(out{lags(ii)+2},vars2,vars1);
        test    = test && funcs{ii}(tested);
        if ~test
            break;
        end
    end
    
end

%==========================================================================
function testMomentRestriction(obj,restriction,type)

    if ~iscell(restriction)
        error([mfilename ':: The restriction input must a cell array.'])
    end
    if size(restriction,2) ~= 4
        error([mfilename ':: The restriction input must have 4 columns when type is set to ''' type '''.'])
    end
    
    N = size(restriction,1);
    for ii = 1:N
        
        var1 = restriction{ii,1};
        if ~nb_isOneLineChar(var1)
            error([mfilename ':: The first element of row ' int2str(ii) ' must be a one line char with the name of the first variable to restrict.'])
        end
        if ~any(strcmpi(var1,obj.dependent.name))
            error([mfilename ':: The model does not contain any variable ' var1 ' (row nr ' int2str(ii) ').'])
        end
        
        var2 = restriction{ii,2};
        if ~nb_isOneLineChar(var2)
            error([mfilename ':: The second element of row ' int2str(ii) ' must be a one line char with the name of the second variable to restrict.'])
        end
        if ~any(strcmpi(var2,obj.dependent.name))
            error([mfilename ':: The model does not contain any variable ' var2 ' (row nr ' int2str(ii) ').'])
        end
       
        lag = restriction{ii,3};
        if ~nb_isScalarInteger(lag)
            error([mfilename ':: The third element of row ' int2str(ii) ' must be an integer with the lag of the ' type ' to restrict.'])
        end
        if lag < 0
            error([mfilename ':: The third element of row ' int2str(ii) ' must be an integer greater than or equal to 0.'])
        end
        
        rest = restriction{ii,4};
        if ~isa(rest,'function_handle')
            error([mfilename ':: The fourth element of row ' int2str(ii) ' must be a function handle.'])
        end
        try 
            ret = rest(1);
        catch
            error([mfilename ':: The fourth element of row ' int2str(ii) ' must be a function handle that takes only one input as a double.'])
        end
        if ~islogical(ret)
            error([mfilename ':: The fourth element of row ' int2str(ii) ' must be a function handle that returns either true or false.'])
        end
            
    end

end

%==========================================================================
function test = ssRestriction(obj,restriction)

    % Calculate the steady-state
    expressions = restriction(:,1); 
    ss          = getSteadyState(obj,expressions);

    % Do the testing
    test  = true;
    funcs = restriction(:,4);
    for ii = 1:size(restriction,1)
        test = test && funcs{ii}(ss{ii,2});
        if ~test
            break;
        end
    end

end

%==========================================================================
function testSSRestriction(obj,restriction)

    if ~iscell(restriction)
        error([mfilename ':: The restriction input must a cell array.'])
    end
    if size(restriction,2) ~= 2
        error([mfilename ':: The restriction input must have 2 columns when type is set to ''ss''.'])
    end

    if ~iscellstr(restriction(:,1))
        error([mfilename ':: All elements of the first column of the restriction input must consist of strings.'])
    end
    
    N = size(restriction,1);
    for ii = 1:N
        
        expression = restriction{ii,1};
        try
            getSteadyState(obj,expression);
        catch
            error([mfilename ':: Cannot calculate the steady-state value of the expression ' expression ''])
        end
        
        rest = restriction{ii,2};
        if ~isa(rest,'function_handle')
            error([mfilename ':: The fourth element of row ' int2str(ii) ' must be a function handle.'])
        end
        try 
            ret = rest(1);
        catch
            error([mfilename ':: The fourth element of row ' int2str(ii) ' must be a function handle that takes only one input as a double.'])
        end
        if ~islogical(ret)
            error([mfilename ':: The fourth element of row ' int2str(ii) ' must be a function handle that returns either true or false.'])
        end
            
    end
    
end
