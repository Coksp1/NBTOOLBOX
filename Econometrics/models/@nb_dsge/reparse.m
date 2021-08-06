function obj = reparse(obj,varargin)
% Syntax:
%
% obj = reparse(obj,varargin)
%
% Description:
%
% Re-parse model given new parsing options.
% 
% Input:
% 
% - obj         : An object of class nb_dsge.
%
% Optional input:
% (Most relevant to parsing)
%
% - 'macroVars' : See nb_dsge.help('macroVars').
%
% - 'silent'    : See nb_dsge.help('silent').
%
% Output:
% 
% - obj         : An object of class nb_dsge.
%
% See also:
% nb_dsge.set, nb_dsge.parse
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj = nb_dsge.parse(obj.parser.file,obj,varargin{:});

end
