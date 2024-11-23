function dout = nb_uncumdiff(din,d0,omitnan)
% Syntax: 
%
% - dout = nb_uncumdiff(din,d0,omitnan)
%
% Description:
%
% Inverse of the cumulative diff method nb_cumdiff
% 
% Input:
%
% - din     : A double matrix with dimensions [r,c,p].
%
% - d0      : A double matrix with dimensions [r,c,p]. Initial values
% 
% - omitnan : Set to true to make the function robust for trailing and 
%             leading NaNs, but it does not handle missing observation 
%             in the middle. In the last case nan is returned.  
%
% Output:
% 
% - dout    : A double matrix with dimensions [r,c,p].
%
% See also:
% nb_diff, nb_cumdiff
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        omitnan = false;
    end
    
    [r,c,p]   = size(din);
    [~,ci,pi] = size(d0);
    if ci == 1
        d0 = d0(:,ones(1,c),:);
    elseif ci ~= c
        error('The t input must either be a scalar or has as many columns as din.')
    end
    if pi == 1
        d0 = d0(:,:,ones(1,p));
    elseif pi ~= p
        error('The t input must either have one page or has as many pages as din.')
    end
        
    if omitnan

        ind  = isnan(din);
        dout = nan(size(din));
        for ii = 1:c
            for jj = 1:p
                dint = din(:,ii,jj);
                indf = find(~ind(:,ii,jj),1,'first');
                if isempty(indf) || indf == 1
                    indf = 1;
                else
                    indf = indf - 1;
                end
                indl = find(~ind(:,ii,jj),1,'last');
                 if isempty(indl)
                    indl = r;
                end
                dataint = dint(indf:indl);
                if sum(isnan(dataint(2:end))) > 0
                    dout(:,ii,jj) = nan;
                    continue
                end

                try
                    doT = d0(indf:indf,ii,jj);
                catch     
                    error(['The initial values must have at least ',...
                        int2str(indf - 1) ' row(s).'])
                end
                dout(indf:indl,ii,jj) = subFunc(dataint,doT);    
            end
        end
        
    else
        dout = subFunc(din,d0);
    end

end

%==========================================================================
function dout = subFunc(din,d0)

    [r,c,p]         = size(din); 
    d0              = d0(1,:,:);
    dout            = nan(r,c,p);
    dout(1,:,:)     = d0;
    dout(2:end,:,:) = bsxfun(@plus,din(2:end,:,:),d0);
   
end
