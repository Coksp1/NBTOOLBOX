function toIndex = convertCursorIndex(fromString, toString, fromIndex)

    fromIndex1Dim = length(horzcat(fromString{1:fromIndex(1) - 1})) + ...
        (fromIndex(1) - 1) + fromIndex(2);

    toIndex = [1 1];
    while (fromIndex1Dim - length(toString{toIndex(1)}) - 1) > 0
        fromIndex1Dim = fromIndex1Dim - length(toString{toIndex(1)}) - 1;
        toIndex(1) = toIndex(1) + 1;
    end
    toIndex(2) = fromIndex1Dim;

end
