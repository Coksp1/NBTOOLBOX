function x = median(obj)
% Syntax:
%
% x = median(obj)
%
% Description:
%
% Evaluate the median of the given distribution.
% 
% Input:
% 
% - obj : An object of class nb_distribution
% 
% Output:
% 
% - x   : numel(obj) == 1 : A double with size as 1 x 1
%         otherwise       : A double with size 1 x nobj
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    nobj1 = size(obj,1); 
    nobj  = size(obj,2);
    lb    = reshape({obj.lowerBound},nobj1,nobj);
    ub    = reshape({obj.upperBound},nobj1,nobj);
    ms    = reshape({obj.meanShift},nobj1,nobj);
    x     = nan(nobj1,nobj);
    for jj = 1:nobj1
        
        for ii = 1:nobj

            if ~isempty(lb{jj,ii}) || ~isempty(ub{jj,ii}) % Truncated distribution
                if isempty(ms{jj,ii})
                    x(jj,ii) = nb_distribution.truncated_median(obj(jj,ii).type,obj(jj,ii).parameters,lb{jj,ii},ub{jj,ii});      
                else
                    x(jj,ii) = nb_distribution.meanshift_median(obj(jj,ii).type,obj(jj,ii).parameters,lb{jj,ii},ub{jj,ii},ms{jj,ii}); 
                end
            else
                func     = str2func(['nb_distribution.' obj(jj,ii).type '_median']);
                x(jj,ii) = func(obj(jj,ii).parameters{:});
                if ~isempty(ms{jj,ii})
                    x(jj,ii) = x(jj,ii) + ms{jj,ii};
                end
            end
            
        end
                
    end

end
