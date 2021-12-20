function obj = setBlocks(obj,blocks)
% Syntax:
%
% obj = setBlocks(obj,blocks)
%
% Description:
%
% Use this function to set zero restriction in the factor loadings. This
% can be used to only restrict some factors to explain the observables.
% E.g. in this way we can have one factor that only relates to one class
% of observables, and in this way we can identify that factor with that
% spesific class.
% 
% Input:
% 
% - obj    : An object of class nb_fmdyn.
%
% - blocks : A nb_cs or double with size N x R, where N is the number of
%            observables and R is the number of factors. Give a nb_cs
%            object to name the factors! Ordering of the nb_cs input is not
%            important, but if given as a double the ordering is given by
%            obj.observables.name. Set a one in the row of the observables
%            that belong to the block of the corresponding column,
%            otherwise 0.
% 
% Output:
% 
% - obj    : An object of class nb_fmdyn, where the blocks field of the
%            options property is set.
%
% See also:
% nb_fmdyn.set
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        obj = nb_callMethod(obj,@setBlocks,@nb_fmdyn,blocks);
        return
    end
    if isempty(blocks)
        obj.options.blocks = blocks;
        obj.factorNames    = {};
        return
    end
    if isempty(obj.observables.name)
        error([mfilename ':: You must first declare the observables!'])
    end
    N = obj.observables.number;
    R = obj.options.nFactors;
    if isa(blocks,'nb_cs')
        blocks               = reorder(blocks,obj.observables.name,'types');
        obj.factorNames.name = blocks.variables;
        blocks               = double(blocks);
    end
    if size(blocks,2) ~= R
        error([mfilename ':: The block input does not match the number of factors of the model (' int2str(R) ')'])
    end
    if size(blocks,1) ~= N
        error([mfilename ':: The block input does not match the number of observables of the model (' int2str(N) ')'])
    end
    blocks = logical(blocks);
    test   = all(~blocks,1);
    if any(test)
        if isa(blocks,'nb_cs')
            facNames = obj.factorNames.name(test);
        else
            facNames = nb_appendIndexes('Factor',1:size(blocks,2));
            facNames = facNames(test);
        end
        error(['The factors ' toString(facNames) ' are not assign any variables to load on.'])
    end
    obj.options.blocks = blocks;
    
end
