function start()
    % deslocamento
    dx = 0;
    dy = 0;
    
    % cria a imagem 1000 x 1000
    imagem = zeros([1000 1000]);
    
    % gera imagem
    X = ones(1000, 1) * [-500 : 499];
    Y = [-500 : 499]' * ones(1, 1000); 
    Z = (X + dx).^2 + (Y + dy).^2; 
    imagem(find(Z <= 10^2)) = 1;
    
    % exibe imagem
    imshow(imagem);
    
end