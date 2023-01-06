function [Fhat,lamhat,xhat,ehat,y_em,eig] = f_em_mf(x,x_freq,nFac,standardise)
% =========================================================================
% DESCRIPTION
% This program estimates a set of factors for a given dataset using
% principal component analysis. The number of factors estimated is
% determined by an information criterion specified by the user. Missing
% values in the original dataset are handled using an iterative
% expectation-maximization (EM) algorithm.
%
% -------------------------------------------------------------------------
% INPUTS
%           x           = dataset (one series per column)
%           x_freq      = frequency of each indicator
%           nFac        = (predefined) number of factors      
%           standardise = an integer indicating the type of transformation
%                         performed on each series in x before the factors 
%                         are estimated.
%
% OUTPUTS
%           ehat    = difference between x and values of x predicted by
%                     the factors
%           Fhat    = set of factors
%           lamhat  = factor loadings
%           xhat    = values of x predicted by the factors
%           eig     = eigenvalues of x3'*x3 (where x3 is the dataset x post
%                     transformation and with missing values filled in)
%           y_em    = x with missing values replaced from the EM algorithm
%
% -------------------------------------------------------------------------
% SUBFUNCTIONS
%
% f_pca()         - runs principal component analysis
% f_standardise() - performs demeaning/standardisation of the data for PCA
%
% -------------------------------------------------------------------------
% BREAKDOWN OF THE FUNCTION
%
% Part 1: Check that inputs are specified correctly.
% Part 2: Setup.
% Part 3: Initialize the EM algorithm -- fill in missing values with
%         unconditional mean and estimate factors using the updated
%         dataset.
% Part 4: Perform the EM algorithm -- update missing values using factors,
%         construct a new set of factors from the updated dataset, and
%         repeat until the factor estimates do not change.
% 
% -------------------------------------------------------------------------
% NOTES
% Authors: Michael W. McCracken and Serena Ng
% Date: 9/5/2017
% Version: MATLAB 2014a
% Required Toolboxes: None
%
% Details for the three possible information criteria can be found in the
% paper "Determining the Number of Factors in Approximate Factor Models" by
% Bai and Ng (2002).
%
% The EM algorithm is essentially the one given in the paper "Macroeconomic
% Forecasting Using Diffusion Indexes" by Stock and Watson (2002). The
% algorithm is initialized by filling in missing values with the
% unconditional mean of the series, demeaning and standardizing the updated
% dataset, estimating factors from this demeaned and standardized dataset,
% and then using these factors to predict the dataset. The algorithm then
% proceeds as follows: update missing values using values predicted by the
% latest set of factors, demean and standardize the updated dataset,
% estimate a new set of factors using the demeaned and standardized updated
% dataset, and repeat the process until the factor estimates do not change.
%
% Edited by Sercan Eraslan on 20/07/2020
% The code is reduced to factor estimates with a fixed number of factors. 
% The EM algorithm (part on updating missing values) is adjusted to
% incorporate mixed frequency data, such as monthly and quarterly according
% to Stock & Watson (2002) Appendix A.E p. 157.
% 
% =========================================================================
% PART 1: CHECKS

% Check that x is not missing values for an entire row
if sum(sum(isnan(x),2)==size(x,2))>0
    error('Input x contains entire row of missing values.');
end

% Check that x is not missing values for an entire column
if sum(sum(isnan(x),1)==size(x,1))>0
    error('Input x contains entire column of missing values.');
end

% Check that DEMEAN is one of 0, 1, 2, 3
if standardise ~= 0 && standardise ~= 1 && standardise ~= 2 && standardise ~= 3
    error('Input standardise is specified incorrectly.');
end

% =========================================================================
% PART 2: SETUP

% Maximum number of iterations for the EM algorithm
maxit=1000;

% Number of observations per series in x (i.e. number of rows)
T=size(x,1);

% Number of series in x (i.e. number of columns)
N=size(x,2);

% Set error to arbitrarily high number
err=999;

% Set iteration counter to 0
it=0;

% Locate missing values in x
x_miss_idx = isnan(x);

% =========================================================================
% PART 3: INITIALIZE EM ALGORITHM
% Fill in missing values for each series with the unconditional mean of
% that series. Demean and standardize the updated dataset. Estimate factors
% using the demeaned and standardized dataset, and use these factors to
% predict the original standardised dataset.

% Initialise a cell arrays for the aggregator matrices and index of
% observed values in monthly and quarterly indicators
A = cell(N,1);
Xobs = cell(N,1);

% Get unconditional mean of the non-missing values of each series
mu_init = repmat(nanmean(x),T,1);

% Replace missing values with unconditional mean
y_em = x;
y_em(x_miss_idx) = mu_init(x_miss_idx);

% Demean and standardize data using subfunction f_data_transform()
%   x_std_init = initial demeaned and standardised dataset
%   mu_init    = mean of the initial dataset y_em
%   sd_init    = standard deviation of the initial dataset y_em
[x_std_init,mu_init,sd_init]=f_standardise(y_em,standardise);

% Run principal components on updated dataset using subfunction f_pca()
%   chat   = values of x_std predicted by the factors
%   Fhat   = factors scaled by (1/sqrt(N)) where N is the number of series
%   lamhat = factor loadings scaled by number of series
%   eig    = eigenvalues of x_std'*x_std 
[chat,Fhat,lamhat,eig]  = f_pca(x_std_init,nFac);

% Save predicted series values
chat0=chat;

% =========================================================================
% PART 4: PERFORM EM ALGORITHM
% Update missing values using values predicted by the latest set of
% factors. Demean and standardize the updated dataset. Estimate a new set
% of factors using the updated dataset. Repeat the process until the factor
% estimates do not change.

% Run while error is large and have yet to exceed maximum number of
% iterations
while err> 0.000001 && it <maxit
    
    % ---------------------------------------------------------------------
    % INCREASE ITERATION COUNTER
    
    % Increase iteration counter by 1
    it=it+1;
    
    % Display iteration counter, error, and number of factors
    %fprintf('Iteration %d: obj %10f IC %d \n',it,err,icstar);

    % ---------------------------------------------------------------------
    % UPDATE MISSING VALUES (E-step)
    
    % Replace missing observations:
    % (m) in monthly indicators - if any - with latest values predicted by 
    % the factors from the previous iteration according to Appendix A.A p. 156.
    % (q) in the latent monthly observations of the quarterly indicators by
    % means of the temporal (dis)aggregation according to Appendix A.E p. 157.

    for j = 1:N
        switch x_freq{j}
            case{'m'}
                for t=1:T
                    if x_miss_idx(t,j)==1
                        y_em(t,j)=chat(t,j);
                    else
                        y_em(t,j)=x_std_init(t,j);
                    end
                end
            case{'q'}
                vec_taMQ = [1:3 2:-1:1]; % temporal aggregation m-q
                xObs = 1-x_miss_idx(:,j); % index of observed quarterlies
                xObsIdx = find(ismember(xObs,1)); % rows of observed quarterlies
                Ai = zeros(length(xObsIdx),T); % initialise the aggregator matrix m-q
                for i = 1:length(xObsIdx) % fill in the Ai
                    if xObsIdx(i) == 3
                        Ai(i,1:3) = vec_taMQ(3:5);
                    elseif xObsIdx(i) > size(vec_taMQ,2)
                        Ai(i,xObsIdx(i)-4:1:xObsIdx(i)) = vec_taMQ;
                    end
                end
                x_stdObs = x_std_init(xObsIdx,j);
                y_em(:,j) = chat(:,j) + Ai'*inv(Ai*Ai')*(x_stdObs - Ai*chat(:,j));
                A{j}=Ai;
                Xobs{j}=xObsIdx;
        end
    end

    % ---------------------------------------------------------------------
    % ESTIMATE FACTORS (M-step)
    
    % Demean/standardize new dataset and recalculate mu_em and sd_em using
    % subfunction f_data_transform()
    %   x_std_em = demeaned and standardised dataset obtained from y_em 
    %   mu_em    = means of the filled dataset y_em 
    %   sd_em    = standard deviations of the the filled dataset y_em
    [x_std_em,mu_em,sd_em]=f_standardise(y_em,standardise);
    
    % Run principal components on the new dataset using subfunction pc2()
    %   chat   = values of x_std predicted by the factors
    %   Fhat   = factors scaled by (1/sqrt(N)) where N is the number of 
    %            series
    %   lamhat = factor loadings scaled by number of series
    %   eig    = eigenvalues of x_std'*x_std 
    [chat,Fhat,lamhat,eig]  = f_pca(x_std_em,nFac);

    % ---------------------------------------------------------------------
    % CALCULATE NEW ERROR VALUE
    
    % Caclulate difference between the predicted values of the new dataset
    % and the predicted values of the previous dataset
    diff=chat-chat0;
    
    % The error value is equal to the sum of the squared differences
    % between chat and chat0 divided by the sum of the squared values of
    % chat0
    v1=diff(:);
    v2=chat0(:);
    err=(v1'*v1)/(v2'*v2);

    % Set chat0 equal to the current chat
    chat0=chat;
end

% Produce warning if maximum number of iterations is reached
if it==maxit
    warning('Maximum number of iterations reached in EM algorithm');
end

% -------------------------------------------------------------------------
% FINAL COMMON COMPONENTS AND DIFFERENCE

% Calculate the values of x predicted by the final set of factors
xhat =NaN(size(x));

% The common components are standardised twice (one during the
% initialisation step from x to x_init; one during the EM iterations).
% Therefore we have to re-standardise also twice: first re-standardise the
% EM standardisation and then the second one to get the magnitute of the
% original dataset
for j = 1:N
    switch x_freq{j}
        case{'m'}
            xhat(:,j) = (chat(:,j).*sd_em(:,j)+mu_em(:,j)).*sd_init(:,j)+mu_init(:,j);
        case{'q'}
            xhat(Xobs{j},j) = A{j}*(chat(:,j).*sd_em(:,j)+mu_em(:,j)) .* ...
                              sd_init(Xobs{j},j)+mu_init(Xobs{j},j);
    end
end

% Calculate the difference between the initial dataset and the values 
% predicted by the final set of factors
ehat = x-xhat;

end
