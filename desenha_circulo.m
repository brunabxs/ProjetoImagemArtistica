function imagem = desenha_circulo(imagem, dx, dy, tonalidade)
    % tamanho da imagem
    [width, height] = size(imagem);

    % raio fico em 5px
    raio = 5;
    
    % gera a matriz de tamanho width x height
    % com o circulo na posicao (dx, dy) onde o ponto (0, 0) encontra-se no centro da matriz
    X = ones(width, 1) * [-ceil(width/2) : ceil(width/2)-1];
    Y = [-ceil(height/2) : ceil(height/2)-1]' * ones(1, height); 
    Z = (X - dx).^2 + (Y - dy).^2; 

    % gera imagem
    imagem(find(Z <= raio^2)) = tonalidade; 
end