%opcoes = struct('atributos', 3, 'bits_atributo', 3, 'circulos', 2,
%'raio_circulo', 5, 'imagem', 8)

function imagem = desenhar_individuo(individuo, opcoes)
    % converte a sequencia de bits para uma matriz contendo as informacoes
    % de cada circulo
    individuo = gerar_individuo(individuo, opcoes.bits_atributo, opcoes.atributos, opcoes.circulos);
        
    % cria a imagem 
    imagem = zeros([opcoes.imagem opcoes.imagem]);
    
    % desenha o circulo correspondente na imagem
    for i = 1:opcoes.circulos;
        imagem = desenhar_circulo(imagem, individuo(i,1), individuo(i,2), opcoes.raio_circulo, individuo(i,3));
    end        
end

function individuo = gerar_individuo(cromossomo, genes_atributo, total_atributos, total_circulos)
    % separa a sequencia de bits em uma matriz
    circulos = reshape(cromossomo, genes_atributo, total_atributos, total_circulos);
    
    % reordena a matriz de forma que
    % - (i) linhas indicam um atributo
    % - (j) colunas indicam o bit do atributo i do circulo k
    % - (k) profund. indica o circulo
    circulos = permute(circulos, [2 1 3]);
    
    % converte o valor de cada atributo (que esta em binario) em um valor
    % inteiro
    individuo = ones(total_circulos, total_atributos);
    for i = 1:total_circulos
        individuo(i,:) = bi2de(circulos(:,:,i), 'left-msb')';
    end
end

function imagem = desenhar_circulo(imagem, dx, dy, raio, tonalidade)
    % tamanho da imagem
    [largura, altura] = size(imagem);
    
    % gera a matriz de tamanho largura x altura
    % com o circulo na posicao (dx, dy) onde o ponto (0, 0) encontra-se no centro da matriz
    X = ones(largura, 1) * [-ceil(largura/2) : ceil(largura/2)-1];
    Y = [-ceil(altura/2) : ceil(altura/2)-1]' * ones(1, altura); 
    Z = (X - dx).^2 + (Y - dy).^2; 

    % gera imagem
    imagem(find(Z <= raio^2)) = tonalidade; 
end