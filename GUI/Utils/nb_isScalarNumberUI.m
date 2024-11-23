function ret = nb_isScalarNumberUI(dispText,x,low,upp,closedLow,closedUpp)
% Syntax:
%
% ret = nb_isScalarNumberUI(dispText,x,low,upp,closedLow,closedUpp)
%
% Description:
%
% Test if x is a scalar number, and throw error in a nb_errorWindow 
% object.
% 
% Input:
% 
% - dispText  : The text to insert at the x in the following error message;
%               'The X must be set to a scalar number' 
%
% - x         : Any type
% 
% - low       : If x is a number, it will test if x > low if this input 
%               is given.
%
% - upp       : If x is a number, it will test if x < upp if this input 
%               is given.
% 
% - closedLow : Set to true to change x > low to x >= low
%
% - closedUpp : Set to true to change x < upp to x <= upp
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
        ret = nb_isScalarNumber(x);
        if ~ret
            nb_errorWindow(['The ' dispText ' must be set to a scalar ',...
                'number.'])
        end
    elseif nargin < 4
        ret = nb_isScalarNumber(x,low);
        if ~ret
            nb_errorWindow(['The ' dispText ' must be set to a scalar ',...
                'number greater than ' int2str(low) '.'])
        end
    else
        if nargin < 6
            closedLow = false;
            if nargin < 5
                closedUpp = false;
            end
        end

        if closedLow && closedUpp
            ret = nb_isScalarNumberClosed(x,low,upp);
            if ~ret
                nb_errorWindow(['The ' dispText ' must be set to a scalar ',...
                    'number greater than or equal to ' int2str(low) ' and ',...
                    'less then or equal to ', int2str(upp) '.'])
            end
        elseif ~closedLow && ~closedUpp
            ret = nb_isScalarNumber(x,low,upp);
            if ~ret
                nb_errorWindow(['The ' dispText ' must be set to a scalar ',...
                    'number greater than ' int2str(low) ' and less then ',...
                    int2str(upp) '.'])
            end
        elseif closedLow
            ret = nb_isScalarNumberClosedLower(x,low,upp);
            if ~ret
                nb_errorWindow(['The ' dispText ' must be set to a scalar ',...
                    'number greater than or equal to ' int2str(low) ' and ',...
                    'less then ', int2str(upp) '.'])
            end
        else
            ret = nb_isScalarNumberClosedUpper(x,low,upp);
            if ~ret
                nb_errorWindow(['The ' dispText ' must be set to a scalar ',...
                    'number greater than ' int2str(low) ' and less then or ',...
                    'equal to ', int2str(upp) '.'])
            end
        end
        
    end
    
end
