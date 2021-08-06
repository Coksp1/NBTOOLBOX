function ret = isDate(input,freq,locVar)
% Syntax:
%
% ret = nb_date.isDate(input,freq)
%
% Description:
%
% Test if a string ot nb_date object is a date. It is also possible to
% restrict the test to a specific frequency.
% 
% Input:
% 
% - input  : Any object
%
% - freq   : 1, 2, 4, 12, 52 or 365. Can also be empty, but then it is
%            slower.
%
% - locVar : A nb_struct/struct with the supported local variables. If 
%            the input is a string using the syntax '%#name', this input
%            will be looked up and tested. 
% 
% Output:
% 
% - ret   : Either true or false. true if input is a date string or nb_date
%           object.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        locVar = [];
        if nargin < 2
            freq = [];
        end
    end
    
    if isa(input,'nb_date')
        
        if isempty(freq)
            ret = true;
        else
            switch freq
                case 1
                    ret = isa(input,'nb_year');
                case 2
                    ret = isa(input,'nb_semiAnnual');
                case 4
                    ret = isa(input,'nb_quarter');
                case 12
                    ret = isa(input,'nb_month');
                case 52
                    ret = isa(input,'nb_week');
                case 365
                    ret = isa(input,'nb_day');
                otherwise
                    error('Wrong input given to freq.') 
            end
        end
        
    elseif ischar(input) && nb_sizeEqual(input,[1,nan])
        
        if ~isempty(locVar)
            ind  = strfind(input,'%#');
            if ~isempty(ind)
                input = nb_localVariables(locVar,input);
            end
        end
        
        ret = true;
        if isempty(freq)
            try
                nb_date.date2freq(input);
            catch %#ok<CTCH>
                ret = false;
            end
        else
            try
                nb_date.toDate(input,freq);
            catch %#ok<CTCH>
                ret = false;
            end
        end
        
    else
        ret = false;
    end

end
