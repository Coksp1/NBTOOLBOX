function d = nb_dash(type,printing2PDF)
% Syntax:
%
% d = nb_dash(type,printing2PDF)
%
% Description:
%
% Get dash type.
% 
% Input:
% 
% - type : Either 'dash', 'en-dash' or 'em-dash'. Default is 'dash'.
% 
% Output:
% 
% - d    : A char with the given dash type.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        printing2PDF = false;
        if nargin < 1
            type = '';
        end
    end

    if strcmpi(type,'en-dash')
        if printing2PDF
            d = '--';
        else
            d = char(8211);
        end
    elseif strcmpi(type,'em-dash')
        if printing2PDF
            d = '_-';
        else
            d = char(8212);
        end
    else
        d = char(173);
    end

end
