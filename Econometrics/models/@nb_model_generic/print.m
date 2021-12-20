function printed = print(obj)
% Syntax:
%
% printed = print(obj)
%
% Description:
%
% Get the estimation result printed to a char array.
% 
% Input:
% 
% - obj : A vector of nb_model_estimate objects.
% 
% Output:
% 
% - printed : A char array with the estimation results.
%
% See also:
% nb_model_estimate.print_estimation_results
%
% Written by Kenneth Sæterhagen Paulsen    

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    printed = print_estimation_results(obj);

end
