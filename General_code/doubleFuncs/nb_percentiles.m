function p = nb_percentiles(d,perc,dim)
% Syntax:
%
% p = nb_percentiles(d,perc,dim)
%
% Description:
%
% Take the percentile over the given dimension of the data of the object.
% 
% Uses mid-point interpolation.
%
% Input:
% 
% - d    : A double with dimension less than or equal to 3.
%
% - perc : A double with the wanted percentiles of the data. E.g.
%          50 (median), or [5,15,25,35,50,65,75,85,95]. These values must
%          be integers!
% 
% - dim  : The dimension to calculate the percentiles over. Default is 1.
%
% Output:
% 
% - p    : A double with the percentiles.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~all(nb_iswholenumber(perc))
        error([mfilename ':: The perc input must be a vector of integers.'])
    end
    
    perc = sort(perc);
    if any(perc < 0)
        error([mfilename ':: The perc input cannot contain a number less than 0.'])
    end
    if any(perc > 100)
        error([mfilename ':: The perc input cannot contain a number greater than 100.'])
    end  
    perc           = perc/100;
    s              = size(d,dim);
    perc1          = round(perc*s - 0.5);
    perc1(perc1<1) = 1;
    perc2          = round(perc*s + 0.5);
    perc2(perc2>s) = s;
    
    d = sort(d,dim);
    switch dim
        case 1      
            p1 = d(perc1,:,:);
            p2 = d(perc2,:,:);
            p  = 0.5*p1 + 0.5*p2;
        case 2
            p1 = d(:,perc1,:);
            p2 = d(:,perc2,:);
            p  = 0.5*p1 + 0.5*p2;
        case 3
            p1 = d(:,:,perc1);
            p2 = d(:,:,perc2);
            p  = 0.5*p1 + 0.5*p2;
        otherwise
            error([mfilename ':: Cannot calculate percentiles over the dimension ' int2str(dim)])
    end

end
