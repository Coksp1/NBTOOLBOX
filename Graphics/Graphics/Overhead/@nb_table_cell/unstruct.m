function obj = unstruct(s)
% Syntax:
%
% obj = nb_table_cell.unstruct(s)
%
% Description:
%
% Convert struct to object
% 
% Input:
% 
% - s   : A struct
% 
% Output:
% 
% - obj : An object of class nb_table_cell
%
% See also:
% nb_table_cell.struct
%
% Written by Kenneth Sæterhagen Paulsen        

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj    = nb_table_cell();
    fields = fieldnames(s);
    for ii = 1:length(fields)
        
        switch lower(fields{ii})
            
            case 'annotation'
                
                ann = s.annotation;
                if isstruct(ann)
                    ann = nb_annotation.fromStruct(ann);
                elseif iscell(ann)
                    for jj = 1:length(ann)
                        ann{jj} = nb_annotation.fromStruct(ann{jj});
                    end
                end
                obj.annotation = ann;
                
            case 'db'
                
                if iscell(s.DB)
                    obj.DB = s.DB;
                else
                    obj.DB = nb_cell.unstruct(s.DB);    
                end
                
            case 'class'

                % Do nothing

            case 'table'
                
                obj.table = nb_table.unstruct(s.table);
                
            case 'figtitleobjecteng'
                
                if isstruct(s.figTitleObjectEng)
                    obj.figTitleObjectEng = nb_figureTitle.unstruct(s.figTitleObjectEng);
                end
                
            case 'figtitleobjectnor'
                
                if isstruct(s.figTitleObjectNor)
                    obj.figTitleObjectNor = nb_figureTitle.unstruct(s.figTitleObjectNor);
                end
                
            case 'footerobjecteng'
                
                if isstruct(s.footerObjectEng)
                    obj.footerObjectEng = nb_footer.unstruct(s.footerObjectEng);
                end
                
            case 'footerobjectnor'
                
                if isstruct(s.footerObjectNor)
                    obj.footerObjectNor = nb_footer.unstruct(s.footerObjectNor);
                end 
                
            case 'interpreter'
                
                % Removed property    
                
            otherwise
                
                obj.(fields{ii}) = s.(fields{ii});
                
        end
                
    end        

end
