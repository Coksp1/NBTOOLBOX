function F_aux = f_factor_minnesotastruc(f_aux,lags_f,n_f,t,k,p)
% Syntax:
%
% F_aux = nb_tvpmfsvEstimator.f_factor_minnesotastruc(f_aux,lags_f,...
%  n_f,t,k,p)
%
% Description:
%
% f_factor_minnesotastruc written by Maximilian Schröder. This function is 
% mostly taken from Koop and Korobilis (2014) but modified to fit
% the current framework.
%
% Input:
%
% - f_aux  : an auxilliary factor matrix of lagged factors
% - lags_f : the number of factor lags
% - n_f    : the number of factors
% - t      : the time series length
% - k      : the size of the state vector
% - p      : the number of VAR parameters
%
% Output:
% - F_aux  : the final auxilliary factor matrix
%
% Written by Maximilian Schröder
% Edited by Kenneth Sæterhagen Paulsen
% - Formated the documentation to fit NB toolbox

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % extract the necessary size according to the dimensions of the state-space
    K = (n_f^2)*lags_f;

    % initialize F_aux
    F_aux = zeros((t-lags_f)*n_f,K);

    % reorder the elements of f_aux to acknowledge the structure of the
    % Minnesota prior. The factors are ordered similarly to the SUR case. 
    for i = 1:t-lags_f
        ztemp = [];
        for j = 1:lags_f
            ftemp = f_aux(i,(j-1)*n_f+1:j*n_f);
            ftemp = kron(eye(n_f),ftemp);
            ztemp = [ztemp ftemp];
        end
        F_aux((i-1)*n_f+1:i*n_f,:) = ztemp;
    end

    % adjust F_aux
    F_aux = [zeros(k,p) ;F_aux]; % the zeros fill up the space lost due to lagging

end

