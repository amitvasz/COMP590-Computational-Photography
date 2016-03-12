function H = calculateH(points1, points2 )
    %find how many points are provided
    n = size (points1,1);
    
    %initialize an empty M matrix of the correct size
    M = zeros(n*3, 9);
    
    %initialize an empty zero vector of the correct size
    b = zeros(n*3, 1);
    
    %iterate through each point
    for i=1:n
        %populate M with constraints
        M(3*(i-1)+1, 1:3) = [points2(i,:),1];
        M(3*(i-1)+2, 4:6) = [points2(i,:),1];
        M(3*(i-1)+3, 7:9) = [points2(i,:),1];
        
        %populate b with constraints
        b(3*(i-1)+1:3*(i-1)+3) = [points1(i,:),1];
    end
    
    %solve for h vector
    h = (M\b)';
    
    %reshape h vector into H matrix
    H = [h(1:3); h(4:6); h(7:9)];
end

