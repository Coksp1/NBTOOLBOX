function draws = random(obj,nrow,ncol)
% Syntax:
%
% draws = random(obj,nrow,ncol)
%
% Description:
%
% Draw random numbers from the distribution represented by the
% nb_distribution object.
% 
% Input:
% 
% - obj  : An object of class nb_distribution
%
% - nrow : The number of rows of the draws output
%
% - ncol : The number of columns of the draws output
% 
% Output:
% 
% - draws : numel(obj) == 1 : A nrow x ncol double with the draws from the 
%                             distribution
%           otherwise       : A nrow x ncol x nobj1 x nobj2 double with the  
%                             draws from the distributions
%
% Examples:
% 
% obj = nb_distribution;
% d   = random(obj,10,1);
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        ncol = 1;
        if nargin < 2
            nrow = 1;
        end
    end
    
    nobj1 = size(obj,1);
    nobj  = size(obj,2);
    lb    = reshape({obj.lowerBound},nobj1,nobj);
    ub    = reshape({obj.upperBound},nobj1,nobj);
    ms    = reshape({obj.meanShift},nobj1,nobj);
    draws = nan(nrow,ncol,nobj1,nobj);
    for jj = 1:1:nobj1
        for ii = 1:nobj

            if ~isempty(lb{jj,ii}) || ~isempty(ub{jj,ii}) % Truncated distribution
                if isempty(ms{jj,ii})
                    draws(:,:,jj,ii) = nb_distribution.truncated_rand(nrow,ncol,obj(jj,ii).type,obj(jj,ii).parameters,lb{jj,ii},ub{jj,ii});
                else
                    draws(:,:,jj,ii) = nb_distribution.meanshift_rand(nrow,ncol,obj(jj,ii).type,obj(jj,ii).parameters,lb{jj,ii},ub{jj,ii},ms{jj,ii});
                end
            else
                func             = str2func(['nb_distribution.' obj(jj,ii).type '_rand']);
                draws(:,:,jj,ii) = func(nrow,ncol,obj(jj,ii).parameters{:});
                if ~isempty(ms{jj,ii})
                    draws(:,:,jj,ii) = draws(:,:,jj,ii) + ms{jj,ii};
                end
            end
        end
    end
    
end
