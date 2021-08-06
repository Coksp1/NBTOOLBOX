function message = nb_checkPostFix(postfix)
% Syntax:
%
% message = nb_checkPostFix(postfix)
%
% Description:
%
% Check the postfix for unsupported chars
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    message        = '';
    indN           = regexp(postfix,'\d','start');
    postfixT       = postfix;
    postfixT(indN) = '';
    ind            = regexp(postfixT,'[!"@#��$%&/()=?`\^~�*-:;�|><{},]','once');
    if ~isempty(ind)
        message = ['Invalid postfix ''' postfix ''' provided. The postfix cannot contain [, !, ", @, #, �, �, $, '...
                   '%, &, /, (, ), =, ?, `, \, ^, ~, �, *, -, :, ;, �, |, >, <, {, }, ], and ,'];
        return
    end
    
end
