function dataT = nb_readMat(filename,sorted)
% Syntax:
%
% data = nb_readMat(filename,sorted)
% 
% Description:
%
% This is a function for reading a mat file, and checks if the
% stored information in that file can be converted to either a
% nb_data, nb_ts, nb_cs or nb_modelDataSource object
%
% Input:
%
% - filename : A string with the filename of the .mat file.
%
% Formats:
% 
% See nb_data.toStructure, nb_ts.toStructure, nb_cs.toStructure,
%     nb_data.struct, nb_ts.struct or nb_cs.struct
% 
% Output:
%
% - data    : An object of class nb_data, nb_ts, nb_cs or 
%             nb_modelDataSource.
%
% See also:
% nb_ts, nb_cs, nb_data, nb_modelDataSource
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        sorted = 1;
    end

    structure = load(filename);
    try
        class = structure.class;
    catch  %#ok<CTCH>
        error([mfilename ':: The loaded mat file cannot be loaded to either a nb_ts, a nb_data nor a nb_cs object.'])
    end
    
    if strcmpi(class,'nb_modelDataSource')
        dataT = nb_modelDataSource.unstruct(structure);
        return
    end
    
    if isfield(structure,'links')
        
        % The object has been saved down to a structure using the struct
        % method
        structure.sorted = sorted;
        if strcmpi(class,'nb_ts')
            dataT = nb_ts.unstruct(structure);
        elseif strcmpi(class,'nb_cs')
            dataT = nb_cs.unstruct(structure);
        elseif strcmpi(class,'nb_data')
            dataT = nb_data.unstruct(structure);
        elseif strcmpi(class,'nb_cell')
            dataT = nb_cell.unstruct(structure);
        else
            error([mfilename ':: The loaded mat file cannot be loaded to either a nb_cell, a nb_data, a nb_ts nor a nb_cs.'])
        end
        
    else
    
        if strcmpi(class,'nb_ts')
            dataT = nb_ts(filename,'','',{},sorted);
        elseif strcmpi(class,'nb_cs')
            dataT = nb_cs(filename,'',{},{},sorted);
        elseif strcmpi(class,'nb_data')
            dataT = nb_data(filename,'',[],{},sorted);
       elseif strcmpi(class,'nb_cell')
            dataT = nb_cell(filename,'');
        else
            error([mfilename ':: The loaded mat file cannot be loaded to either a nb_data, a nb_ts, a nb_cs nor a nb_cell object.'])
        end
        
    end
    
end
