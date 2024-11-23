function ret = nb_isScalarIntegerUI(dispText,x,low,upp)
% Syntax:
%
% ret = nb_isScalarIntegerUI(dispText,x,low,upp)
%
% Description:
%
% Test if x is a scalar integer, and throw error in a nb_errorWindow 
% object.
% 
% Input:
% 
% - dispText : The text to insert at the x in the following error message;
%              'The X must be set to a scalar integer' 
%
% - x   : Any type
% 
% - low : If x is a number, it will test if x > low if this input is given.
%
% - upp : If x is a number, it will test if x < upp if this input is given.
% 
% Output:
% 
% - ret : true or false.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isnan(x)
        ret = false;
        nb_errorWindow(['The ' dispText ' must be set to a scalar ',...
                'number.'])
        return
    end

    if nargin < 3
        ret = nb_isScalarInteger(x);
        if ~ret
            nb_errorWindow(['The ' dispText ' must be set to a scalar ',...
                'integer.'])
        end
    elseif nargin < 4
        ret = nb_isScalarInteger(x,low);
        if ~ret
            nb_errorWindow(['The ' dispText ' must be set to a scalar ',...
                'integer greater than ' int2str(low) '.'])
        end
    else
        ret = nb_isScalarInteger(x,low,upp);
        if ~ret
            nb_errorWindow(['The ' dispText ' must be set to a scalar ',...
                'integer greater than ' int2str(low) ' and less then ',...
                int2str(upp) '.'])
        end
    end
    
end
