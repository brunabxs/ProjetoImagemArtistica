function [imagem, individuo_perfeito, circulos] = algoritmo_genetico()
    global opcoes
    global imagem_original
    
    preparar();

    % algoritmo genetico
    total_genes = opcoes.bits_atributo * opcoes.atributos * opcoes.circulos;
    opcoes_genetico = gaoptimset('PopulationSize', 20, 'PopulationType', 'bitstring', 'Generations', 1000, 'SelectionFcn', @selectionroulette, 'CrossoverFraction', 0.8);
    [individuo_perfeito, avaliacao_individuo_perfeito] = ga(@funcao_avaliacao, total_genes, [], [], [], [], [], [], [], opcoes_genetico);
    
    % exibe imagem para individuo final
    imagem = desenhar_individuo(individuo_perfeito, opcoes);
    imshow(imagem, opcoes.mapa_cores);
    
    % salva as imagens
    imwrite(imagem, opcoes.mapa_cores, 'imagem-aprox.bmp');
    imwrite(imagem_original, opcoes.mapa_cores, 'imagem-original.bmp');
    
    % individuo
    circulos = gerar_individuo(individuo_perfeito, opcoes.bits_atributo, opcoes.atributos, opcoes.circulos);
end

function preparar()
    global opcoes
    global imagem_original
    
    % imagem
    [imagem_original, mapa_cores_original] = imread('imagem.bmp');

    mapa_cores_original = [0:1 / 255:1]' * ones(1,3);
    
    % opcoes
    opcoes = struct('atributos', 3, 'bits_atributo', 8, 'circulos', 1000, 'raio_circulo', 10, 'imagem', 256, 'mapa_cores', mapa_cores_original);
end

function resultado = funcao_avaliacao(cromossomo)    
    global opcoes
    global imagem_original
    
    % gera a imagem
    imagem = desenhar_individuo(cromossomo, opcoes);
    
    %resultado = sum(sum((imagem - double(imagem_original)).^2));
    resultado = (norm(imagem,'fro') - norm(double(imagem_original),'fro')).^2;
end

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
    X = ones(largura, 1) * [1 : largura];
    Y = [1 :altura]' * ones(1, altura); 
    Z = (X - dx).^2 + (Y - dy).^2; 

    % gera imagem
    imagem(find(Z <= raio^2)) = tonalidade; 
end