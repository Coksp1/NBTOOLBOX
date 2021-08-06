function dout = iegrowthnan(din,t,periods)
% Syntax: 
%
% - dout = iegrowthnan(din,t,periods)
%
% Description:
%
% - Uses iegrowth, but is robust for trailing and leading NaNs. It also
%   checks whether theres any NaNs in between observations in the 
%   double, and returns an error if it is the case. 
% 
% Input:
%
% - din     : A double matrix with dimensions [r,c,p].
%
% - t       : A double matrix with dimensions [r,c,p].
% 
% - periods : The number of periods the din has been growthed over.
%
% Output:
% 
% - dout    : A double matrix with dimensions [r,c,p].
%
% Examples:
%
% x = rand(3,3,3);
% y = nan(1,3,3);
% t = [y;x;y];
%
% iegrowthnan(t,100)
%
% See also:
% egrowth, iegrowth, growth
%
% Written by Tobias Ingebrigtsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        periods = 1;
    end

    ind       = isnan(din);
    [r,c,p]   = size(din);
    [~,ci,pi] = size(t);
    if ci == 1
        t = t(:,ones(1,c),:);
    elseif ci ~= c
        error([mfilename ':: The t input must either be a scalar or has as many columns as din.'])
    end
    if pi == 1
        t = t(:,:,ones(1,p));
    elseif pi ~= p
        error([mfilename ':: The t input must either have one page or has as many pages as din.'])
    end
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
                tt = t(indf:indf + periods - 1,ii,jj);
            catch     
                error([mfilename ':: The t input must have at least ' int2str(indf + periods - 1) ' row(s).'])
            end
            dout(indf:indl,ii,jj) = iegrowth(dataint,tt,periods);    
        end
    end

end
