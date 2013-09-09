function [imagem, individuo_perfeito, avaliacao_individuo_perfeito, circulos] = algoritmo_genetico()
    start = tic;
    matlabpool open 4;
    
    % imagem
    [imagem_original, mapa_cores_original] = imread('imagem.bmp');
    
    % converter para escala de cinza
    imagem_original = ind2gray(imagem_original, mapa_cores_original);
    
    % opcoes
    opcoes = struct('bits_atributo', [6, 6, 8, 1], 'circulos', 300, 'raio_circulo', 4, 'imagem', 64);
    
    % algoritmo genetico
    total_genes = sum(opcoes.bits_atributo) * opcoes.circulos;
    opcoes_genetico = gaoptimset('PopulationSize', 20, 'PopulationType', 'bitstring', 'Generations', 30000, 'SelectionFcn', @selectionroulette, 'CrossoverFraction', 0.8, 'UseParallel', 'always', 'Vectorized', 'off');
    [individuo_perfeito, avaliacao_individuo_perfeito] = ga(@(cromossomo)funcao_avaliacao(cromossomo, opcoes, imagem_original), total_genes, [], [], [], [], [], [], [], opcoes_genetico);
    
    % exibe imagem para individuo final
    imagem = desenhar_individuo(individuo_perfeito, opcoes);
    
    % salva as imagens
    imwrite(imagem, gray(256), 'imagem-aprox.bmp');
    imwrite(imagem_original, gray(256), 'imagem-original.bmp');
    
    % individuo
    circulos = gerar_individuo(individuo_perfeito, opcoes.bits_atributo, opcoes.circulos);
    
    matlabpool close;
    toc(start)
end

function resultado = funcao_avaliacao(cromossomo, opcoes, imagem_original)
    % gera a imagem
    imagem = desenhar_individuo(cromossomo, opcoes);
    
    resultado = sum(sum((imagem - double(imagem_original)).^2));
    %resultado = (norm(imagem,'fro') - norm(double(imagem_original),'fro')).^2;
end

function imagem = desenhar_individuo(cromossomo, opcoes)
    % converte a sequencia de bits para uma matriz contendo as informacoes
    % de cada circulo
    individuo = gerar_individuo(cromossomo, opcoes.bits_atributo, opcoes.circulos);
        
    % cria a imagem 
    imagem = zeros([opcoes.imagem opcoes.imagem]);
    
    % desenha o circulo correspondente na imagem
    for i = 1:opcoes.circulos;
        if (individuo(i,4))
            imagem = desenhar_circulo(imagem, individuo(i,1), individuo(i,2), opcoes.raio_circulo, individuo(i,3));
        end
    end  
end

function individuo = gerar_individuo(cromossomo, genes_atributo, total_circulos)
    % separa a sequencia de bits em uma matriz
    % - (i) linhas indicam o circulo
    % - (j) colunas indicam os bits dos atributos do circulo i
    circulos = reshape(cromossomo, sum(genes_atributo), total_circulos)';
    
    % separa os dados da matriz
    % converte o valor de cada atributo (que esta em binario) em um valor
    % inteiro
    
    % posicao X
    total_genes = 0;
    X = circulos(:, [1:genes_atributo(1)] + total_genes);
    X = bi2de(X, 'left-msb');
    
    % posicao Y
    total_genes = total_genes + genes_atributo(1);
    Y = circulos(:, [1:genes_atributo(2)] + total_genes);
    Y = bi2de(Y, 'left-msb');
    
    % tonalidade
    total_genes = total_genes + genes_atributo(2);
    T = circulos(:, [1:genes_atributo(3)] + total_genes);
    T = bi2de(T, 'left-msb');
    
    % exibe ou nao o circulo
    total_genes = total_genes + genes_atributo(3);
    E = circulos(:, [1:genes_atributo(4)] + total_genes);
    E = bi2de(E, 'left-msb');
    
    % individuo
    individuo = [X'; Y'; T'; E']';
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