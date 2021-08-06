function value = nb_funcWrapper(x,fHandle,inputs)
% Syntax:
%
% value = nb_funcWrapper(x,fHandle,inputs)
%
% Description:
%
% Create a wrapper function to assign optional inputs to a function handle.
%
% Useful for speeding up function evaluation during parfor with use of
% feval.
% 
% Caution: For speed, the input are not tested!
%
% Input:
% 
% - x       : Main input to function.
%
% - fHandle : A function handle.
%
% - inputs  : A cell array with the inputs passed to the function handle.
% 
% Output:
% 
% - value : The output of the function. 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

   value = fHandle(x,inputs{:}); 
   
end
