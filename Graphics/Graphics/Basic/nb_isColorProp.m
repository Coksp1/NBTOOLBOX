function ret = nb_isColorProp(in,mult)
% Syntax:
%
% ret = nb_isColorProp(in,log)
%
% Description:
%
% Evaluates the color properties. Must have dimension size N x 3 with
% the RGB colors or a cellstr with size 1 x N with the color names.
%
% N == 1 if mult is set to false, else N can be > 1.
% 
% Input:
% 
% - in    : The property value to be evaluated. 
% 
% - mult  : Allow for multiple colors.
%
% Output:
% 
% - ret   : Logical. Returns true if the property is evaluated to be a
%           valid color property as stated in the description above. 
%
% Written by Tobias Ingebrigtsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    if nargin == 1
        mult = 0;
    end
    ret = false;
    if isa(in,'double')
        
        if ~nb_sizeEqual(in,[nan,3])
            error([mfilename ':: The input must be of size x*3.'])
        end
        if ~nb_sizeEqual(in,[1,3]) && ~mult
           error([mfilename ':: The vector is too long. Set mult to true '...
               ' if you want to set multiple colors.'])

        end
        ret = true;
        
    elseif nb_isOneLineChar(in)
       ret = true;
    elseif iscellstr(in)
        if ~mult
           error([mfilename ':: The cellstring is too long. Set mult to '...
                 'true if you want to set multiple colors.'])
        end
        test = cellfun(@(x)nb_isColorProp(x),in);
        ret  = all(test);
    end
end
