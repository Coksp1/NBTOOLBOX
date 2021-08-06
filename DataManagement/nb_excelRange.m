function range = nb_excelRange(base,r,c,br,bc)
% Syntax:
%
% range = nb_excelRange(base,r,c,br,bc)
%
% Description:
%
% Get excel range from a base cell on the format 'A1' and different
% combinations of offsets.
% 
% Input:
% 
% - base : A String on the format 'A1', 'ZZ123' or 'A1:B1'.
%
% If nargin == 2:
%
% - r    : The range will be returned from the base with this number of
%          row offsets. As a strictly positiv scalar integer. 
%
% - c    : The range will be returned from the base with this number of
%          column offsets.  As a strictly positiv scalar integer.
% 
% If nargin == 4:
%
% - r    : The range will be returned from the base with this number of
%          row offsets. As a strictly positive scalar integer. 1 imply 
%          no movement.
%
% - c    : The range will be returned from the base with this number of
%          column offsets. As a strictly positive scalar integer. 1 imply 
%          no movement.
% 
% - br   : First move the base these number of rows. As a scalar integer.
%          0 imply no movement.
%
% - bc   : First move the base these number of columns. As a scalar 
%          integer. 0 imply no movement.
%
% Output:
% 
% - range : A excel range on the format 'A1:C2' or 'B1:C2'.
%
% Examples:
% 
% nb_excelRange('A1',2,2)
% nb_excelRange('A1',2,2,1,1)
%
% See also:
% nb_excelCellOffset, nb_letter2num, nb_num2letter
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5
        br = 0;
        if nargin < 4
            bc = 0;
            if nargin < 3
                c = 1;
                if nargin < 2
                    r = 1;
                end
            end
        end
    end
    
    ind = strfind(base,':');
    if ~isempty(ind)
        if length(ind) > 1
            error([mfilename ':: Wrong input base. Must be on the format ''A1'' or ''A1:B2''.'])
        end
        if nargin < 4
           base1    = base(1:ind-1);
           base2    = base(ind+1:end);
           newBase1 = nb_excelCellOffset(base1,r,c);
           newBase2 = nb_excelCellOffset(base2,r,c);
           range    = [newBase1,':',newBase2];
           return
        else
            base = base(1:ind-1);
        end
        
    end
    
    if ~nb_isScalarInteger(r) || r < 1
        error([mfilename ':: The row increment (r) must be a strictly positive scalar integer.'])
    end
    if ~nb_isScalarInteger(c) || c < 1
        error([mfilename ':: The column increment (c) must be a strictly positive scalar integer.'])
    end

    if nargin < 3
        endCell = nb_excelCellOffset(base,r-1,c-1);
        range   = [base,':',endCell];
    else
        newBase = nb_excelCellOffset(base,br,bc);
        endCell = nb_excelCellOffset(newBase,r-1,c-1);
        range   = [newBase,':',endCell];
    end
    
end
