function [y, x] = getGridPosition(obj, textHandle)
% Find out which table cell a text object belongs to
    userData = get(textHandle, 'UserData');
    tablePosition = userData.TablePosition;
    y = tablePosition(1);
    x = tablePosition(2);
end
