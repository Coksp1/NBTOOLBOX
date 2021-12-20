function newLink = nb_createDefaultLink()
% Syntax:
%
% newLink = nb_createDefaultLink()
%
% Description:
%
% Creates a default link (i.e. empty) used by the nb_ts and nb_cs
% classes
% 
% Output:
% 
% - newLink : A structure with all the fields of an link.
%
% See also:
% nb_ts, nb_cs, nb_data
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    newLink = struct();
    newLink.source     = '';
    newLink.sourceType = '';
    newLink.variables  = {};
    newLink.types      = {};
    newLink.startDate  = '';
    newLink.endDate    = '';
    newLink.sheet      = '';
    newLink.range      = {};
    newLink.transpose  = 0;
    newLink.options    = '';
    newLink.freq       = '';
    newLink.vintage    = '';
    newLink.host       = '';
    newLink.port       = '';
    newLink.operations = {};
    newLink.data       = [];

end
