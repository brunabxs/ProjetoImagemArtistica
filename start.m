function start()   
    % cria a imagem 1000 x 1000
    imagem = zeros([1000 1000]);
    
    % gera imagem 
    imagem = desenha_circulo(imagem, 0, 0)
    
    % exibe imagem
    imshow(imagem);
    
end