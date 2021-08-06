function obj = solveVector(obj)
% Syntax:
%
% obj = solveVector(obj)
%
% Description:
%
% Solve vector of nb_model_generic objects.
% 
% Input:
% 
% - obj : A vector of nb_model_generic objects.
% 
% Output:
% 
% - obj : A vector of nb_model_generic objects.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj = obj(:);
    for ii = 1:numel(obj)
        try
            obj(ii) = solve(obj(ii)); % Cannot seal this function!
        catch Err
            nb_error(['Error while solving model number ' int2str(ii)],Err);
        end
    end
    
end
