function [output_matrix] = nb_lagmatrix(input_matrix,lags)

% Syntax :
% [output_matrix] = nb_lagmatrix(input_matrix,lags)
%   
% Description:
%
% For all values in "lags", this function creates the lags of
% "input_matrix". The result, "output_matrix" contains all lagged values in
% the order given in lags. 
%
% Inputs:
%
% - input_matrix : A matrix
%
% - lags :         lags to be computed. Can be a sequence, e.g 0:2, a 
%                  matrix, e.g. [0, 2, 3], or an integer value.
%                  
%
% Outputs:
%
% - output_matrix : A matrix containing all the the lags of "input_matrix" 
%                   that are given in "lags".
%
% Example:
%
%  With lags = 0:2 and input matrix = [1 2; 3 4; 5 6], nb_lagmatrix returns
%  
%  output_matrix = 1  2 NaN NaN NaN NaN
%                  3  4  1   2  NaN NaN
%                  5  6  3   4   1   1
%
% Written by Maximilian Schröder

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen
    
    % Display an error message, if the lag length exceeds the time series 
    % length
    if lags(end) >= size(input_matrix, 1)
        error('Number of lags to large: The number of lags selected is larger than the length of the data')
    end
    
    % preallocate "output_matrix"
    output_matrix = zeros(size(input_matrix,1), size(input_matrix,2)*length(lags));
    
    % extrakt the number of matrix columns
    k = size(input_matrix, 2);
    
    % iterate over the lags specified in "lags"
    for i = 1:length(lags)
        
        % read out the ith element of "lags"
        lag = lags(i);
        
        % append the lagged matrix with missing values and write result
        % into "output_matrix"
        output_matrix(:,i*k-k+1:i*k) = [NaN(lag, k); input_matrix(1:end-lag,:)];
        
    end

end

