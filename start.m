function start()   
    % cria a imagem 1000 x 1000
    imagem = zeros([1000 1000]);
    
    % gera imagem 
    imagem = desenha_circulo(imagem, 0, 0, 128)
    
    % mapa de cores
    colormap = [0:1 / 255:1]' * ones(1,3);
    colormap(1, :) = [1 1 1];
    
    % exibe imagem
    imshow(imagem, colormap);
    
end