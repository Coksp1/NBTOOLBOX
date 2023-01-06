function [sources,vintages,variables ] = nb_mergeSources(dbNames,vintages,variables)
% Syntax:
%
% [sources,vintages,variables ] = ...
%                           nb_mergeSources(dbNames,vintages,variables)
% 
% Description:
%
% A function to avoid duplicate sources in a dataset.  
%
% Input:
%
% - dbNames   : The names of the databases of the object.
%
% - vintages  : The vintages of the different variables of the object.
%
% - variables : The variablenames of the object.
%
% Output:
%
% - sources   : The databases, without duplicates
%
% - vintages  : The vintages returned without duplicates
%
% - variables : The variables of the object with correct sources.
%
% See also:
% nb_ts.merge
%
% Original code by Kenneth Sæterhagen Paulsen, tweaks by Eyo I. Herstad

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    dbN       = dbNames;
    tempVints = vintages;
    tempVars  = variables;
    
    uniqueSources  = unique(dbN);
    [~,indSources] = ismember(dbN,uniqueSources);
    
    num       = length(dbN);
    sources   = cell(1,num);
    vints     = cell(1,num);
    variables = cell(1,num);
    kk        = 1;
    for ii = 1:length(uniqueSources)
        
       ind                 = indSources == ii;
       vintsOfSource       = tempVints(ind);
       vintsOfSource       = allElementsAsStrings(vintsOfSource);
       sourceUniqueVints   = unique(vintsOfSource);
       [~,sourceIndVints]  = ismember(vintsOfSource,sourceUniqueVints);
       variablesOfSource   = tempVars(ind); 
       
       for jj = 1:length(sourceUniqueVints)
          
           indV        = sourceIndVints == jj;
           sources(kk) = uniqueSources(ii);
           if all(size(sourceUniqueVints{jj},2) ~= [0,8,12])
               vints{kk} = str2double(sourceUniqueVints{jj});
           else
               vints(kk) = sourceUniqueVints(jj);
           end
           variables{kk} = nb_nestedCell2Cell(variablesOfSource(indV));
           kk = kk + 1;
           
       end
       
    end
    
    isEmpty   = ~cellfun('isempty',sources);
    sources   = sources(isEmpty);
    vintages  = vints(isEmpty);
    variables = variables(isEmpty);
    
end
%==================================================================
% SUB
%==================================================================
function c = allElementsAsStrings(c)

    numC = length(c);
    for ii = 1:numC
        
        temp = c{ii};
        if isnumeric(temp)
            c{ii}   = num2str(temp);
        end
        
    end

end

