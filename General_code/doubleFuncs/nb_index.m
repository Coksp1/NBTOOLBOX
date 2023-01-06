function d = nb_index(d,ind1,ind2,ind3)
% Syntax:
%
% d = nb_index(d,ind1,ind2,ind3)
%
% Description:
%
% 
% 
% Input:
% 
% - d    : A double.
% 
% - ind1 : Indicies in the first dimension. As a string. E.g. '1:3','1',
%          '1:end' or ':'.
%
% - ind2 : Indicies in the second dimension. As a string. E.g. '1:3','1',
%          '1:end' or ':'.
%
% - ind3 : Indicies in the third dimension. As a string. E.g. '1:3','1',
%          '1:end' or ':'.
%
% Output:
% 
% - d    : A double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 4
        ind3 = ':';
        if nargin < 3
            ind2 = ':';
            if nargin < 2
                ind1 = ':';
            end
        end
    end
    
    if ~ischar(ind1)
        error([mfilename ':: The ind1 input must be a string.'])
    end
    if ~ischar(ind2)
        error([mfilename ':: The ind2 input must be a string.'])
    end
    if ~ischar(ind3)
        error([mfilename ':: The ind3 input must be a string.'])
    end
    
    ind1 = strrep(ind1,'end',int2str(size(d,1)));
    ind2 = strrep(ind2,'end',int2str(size(d,2)));
    ind3 = strrep(ind3,'end',int2str(size(d,3)));
    ind1 = transIndex(ind1);
    ind2 = transIndex(ind2);
    ind3 = transIndex(ind3);
    
    d = d(ind1,ind2,ind3);

end

function ind = transIndex(ind)

    if strcmpi(ind,':')
        return
    end
    
    indS = strfind(ind,':');
    if isempty(indS)
        ind = mathInd(ind);
    elseif length(indS) == 2
        ind1 = mathInd(ind(1:indS(1)-1));
        ind2 = mathInd(ind(indS(1)+1:indS(2)-1));
        ind3 = mathInd(ind(indS(2)+1:end));
        ind  = ind1:ind2:ind3;
    else
        ind1 = mathInd(ind(1:indS-1));
        ind2 = mathInd(ind(indS+1:end));
        ind  = ind1:ind2;
    end

end

function ind = mathInd(ind)

    indS = regexp(ind,'+','split');
    ind  = 0;
    for ii = 1:length(indS)
        ind = ind + mathIndMinus(indS{ii});
    end
    
end

function ind = mathIndMinus(ind)

    indS = regexp(ind,'-','split');
    ind  = str2double(indS{1});
    for ii = 2:length(indS)
        ind = ind - str2double(indS{ii});
    end

end
