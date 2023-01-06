function xout = nb_msum(xin,backward,forward)
% Syntax:
% 
% xout = nb_msum(xin,backward,forward)
% 
% Description:
% 
% Moving sum
% 
% Input:
% 
% - xin      : The data series, as a double.
% 
% - backward : The number of elements backward to include in moving 
%              sum.
% 
% - forward  : The number of elements forward to include in moving 
%              sum.
% 
% Examples:
% 
% newseries = nb_msum(x,9,0); % 10-element moving sum
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    [s1,s2,s3] = size(xin);

    xfor = nan(s1,s2,s3,forward);
    for cc = 1:forward
        xfor(:,:,:,cc) = [xin(cc+1:end,:,:);zeros(cc,s2,s3)];
    end
    xback = nan(s1,s2,s3,backward);
    for mm = 1:backward
        xback(:,:,:,mm) = [zeros(mm,s2,s3);xin(1:end-mm,:,:)];
    end

    xout = (nansum(xback,4) + xin + nansum(xfor,4)); 

end
