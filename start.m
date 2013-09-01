function start()   
    % cria a imagem 256 x 256
    imagem = zeros([256 256]);
    
    % gera imagem 
    imagem = desenha_circulo(imagem, 0, 0, 128)
    imagem = desenha_circulo(imagem, 30, 30, 20)
    imagem = desenha_circulo(imagem, 90, 90, 200)
    imagem = desenha_circulo(imagem, -30, -30, 2)
    
    % mapa de cores
    colormap = [0:1 / 255:1]' * ones(1,3);
    colormap(1, :) = [1 1 1];
    
    % exibe imagem
    imshow(imagem, colormap);
    
end