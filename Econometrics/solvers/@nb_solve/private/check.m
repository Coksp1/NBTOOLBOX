function obj = check(obj)
% Syntax:
%
% obj = check(obj)
%
% Description:
%
% Check properties before solving.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    M = size(obj.initialXValue,1);
    try 
        fVal = obj.F(obj.initialXValue);
    catch Err
        nb_error([mfilename ':: The F property (the problem) could not be evaluated ',...
            'at the value of the init property (initial values).'],Err)
    end
    if size(fVal,1) ~= M || size(fVal,2) > 1
        error([mfilename ':: The F property (the problem) does not return a ' int2str(M),...
            'x1 double at the value of the init property (initial values).'])
    end
    if ~isempty(obj.JF)        
        try 
            JAC = obj.JF(obj.initialXValue);
        catch Err
            nb_error([mfilename ':: The JF property (the function that return the ',...
                'jacobian of the problem) could not be evaluated at the value of ',...
                'the init property (initial values).'],Err)
        end
        if size(JAC,1) ~= M && size(JAC,2) ~= M
            error([mfilename ':: The JF property does not return a ' int2str(M),...
                'x' int2str(M) ' double at the value of the init property (initial values).'])
        end
    end
    
    if strcmpi(obj.method,'newton')
        if isempty(obj.JF)
            error([mfilename ':: The JF property (the function that return the ',...
                'jacobian of the problem) cannot be empty, if the ''newton'' ',...
                'method is selected.'])
        end
    end

end
