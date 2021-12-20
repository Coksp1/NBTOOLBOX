function obj = interpret(input)
% Syntax:
%
% obj = nb_macro.interpret(input)
%
% Description:
%
% Convert input to a vector of nb_macro objects.
% 
% Input:
% 
% - input : Either a 1 x N or N x 1 nb_macro object, struct with N fields 
%           or a N x 2 cell.
% 
% Output:
% 
% - obj   : An object of class nb_macro with size 1 x N.
%
% See also:
% nb_dsge
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nb_isempty(input)
        obj = nb_macro.empty();
        return
    end

    if isstruct(input) 
        
        fields   = fieldnames(input);
        N        = length(fields);
        obj(1,N) = nb_macro;
        for mv = 1:N
            obj(mv) = nb_macro(fields{mv},input.(fields{mv}));
        end
        
    elseif iscell(input)
        
        [N,C,P] = size(input);
        if C < 2
            error('nb_macro:interpret',[mfilename ':: When input is a cell it must have 2 columns.'])
        end
        if P > 1
            error('nb_macro:interpret',[mfilename ':: When input is a cell it cannot have more than one page.'])
        end
        obj(1,N) = nb_macro;
        for mv = 1:N
            obj(mv) = nb_macro(input{mv,1},input{mv,2});
        end
        
    elseif isa(input,'nb_macro')
        obj = nb_rowVector(input);
    else
        error('nb_macro:interpret',[mfilename '::  The input cannot be of class ' class(input)])
    end
    
end
