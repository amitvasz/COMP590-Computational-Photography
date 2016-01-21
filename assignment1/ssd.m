%define ssd function (sum of squared differences)
%PRECONDITION: images must be of equal size
function y = ssd(A, B)
    y = 0;
    
    
    for i = 1:size(A, 1)
        for j = 1:size(A, 2)
            y = double(y) + double((A(i,j) - B(i,j))^2);  
        end
    end
    y = sqrt(double(y));
end