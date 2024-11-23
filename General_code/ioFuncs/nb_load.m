function l = nb_load(filename,index)
% Syntax:
%
% l = nb_load(filename)
% l = nb_load(filename,index)
%
% Description:
%
% Load .mat file using the MATLAB function load, then select the
% index of the variable to load. Default is 1.
% 
% Input:
% 
% - filename : Name of file to load. See the MATLAB load function.
% 
% - index    : The load function return a struct, where the fields are
%              the seperate variables that are stored to the .mat file.
%              The index input refer to the index value of the variable
%              you want to sign the output. Default is 1.
%
% Output:
% 
% - l        : The loaded variable from the .mat file.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        index = 1;
    end

    if ~nb_isScalarInteger(index)
        error([mfilename ':: The index input must be a scalar integer.'])
    end
    
    m = load(filename);
    f = fieldnames(m);
    try
        l = m.(f{index});
    catch
        error([mfilename ':: The loaded file does not load up ' int2str(index) ' number of variables.'])
    end
end
