function [imagem, melhor_individuo, avaliacao, circulos, tempo] = algoritmo_genetico(circulos, variacao_raio, nome_imagem)
    start = tic;
    matlabpool open 4;
    
    % imagem
    [imagem_original, mapa_cores_original] = imread(strcat(nome_imagem, '.bmp'));
    
    % converter para escala de cinza
    imagem_original = ind2gray(imagem_original, mapa_cores_original);
    
    % opcoes
    opcoes = struct('bits_atributo', [8, 8, 8, variacao_raio], 'circulos', circulos, 'imagem', 256, 'diretorio_saida', strcat('solucao-', num2str(circulos), '-', num2str(2^variacao_raio - 1),'-', nome_imagem, '/'));
    
    % cria a pasta para guardar as imagens
    mkdir(opcoes.diretorio_saida);
    
    % algoritmo genetico
    total_genes = sum(opcoes.bits_atributo) * opcoes.circulos;
    opcoes_genetico = gaoptimset('PopulationSize', 20, 'PopulationType', 'bitstring', 'Generations', 3000, 'SelectionFcn', @selectionroulette, 'CrossoverFraction', 0.8, 'UseParallel', 'always', 'Vectorized', 'off', 'OutputFcns', @(opcoes_saida, estado, flags)gerar_imagem_geracao(opcoes_saida, estado, flags, opcoes));
    [melhor_individuo, avaliacao, flag, saida] = ga(@(cromossomo)funcao_avaliacao_resolucao_sem_peso(cromossomo, opcoes, imagem_original), total_genes, [], [], [], [], [], [], [], opcoes_genetico);
    
    % exibe imagem para individuo final
    imagem = desenhar_individuo(melhor_individuo, opcoes);
    
    % salva as imagens
    imwrite(imagem, gray(256), strcat(opcoes.diretorio_saida, 'imagem-aprox.bmp'));
    imwrite(imagem_original, gray(256), strcat(opcoes.diretorio_saida, 'imagem-original.bmp'));
    
    % individuo
    circulos = gerar_individuo(melhor_individuo, opcoes.bits_atributo, opcoes.circulos);
    
    matlabpool close;
    tempo = toc(start);
    
    % salva alguns dados em arquivo
    arquivo = fopen(strcat(opcoes.diretorio_saida, 'arquivo.txt'), 'w');
    fprintf(arquivo, 'Avaliacao do Melhor Individuo: %f\r\n', avaliacao);
    fprintf(arquivo, 'Geracoes: %d\r\n', saida.generations);
    fprintf(arquivo, 'Termino(%d): %s\r\n\r\n', flag, saida.message);
    fprintf(arquivo, 'Tamanho da imagem: %d\r\n', opcoes.imagem);
    fprintf(arquivo, 'Total de circulos: %d\r\n', opcoes.circulos);
    fprintf(arquivo, 'Variacao dos raios dos circulos: %d\r\n\r\n', 2^opcoes.bits_atributo(1, 4) - 1);
    fprintf(arquivo, 'Tempo: %f\r\n\r\n', tempo);
    fclose(arquivo);
end

function resultado = funcao_avaliacao_simples(cromossomo, opcoes, imagem_original)
    % exibe a imagem para individuo
    imagem = desenhar_individuo(cromossomo, opcoes);
    
    resultado = sum(sum((imagem - double(imagem_original)).^2));
end

function resultado = funcao_avaliacao_resolucao_sem_peso(cromossomo, opcoes, imagem_original)
    % exibe a imagem para individuo
    imagem = desenhar_individuo(cromossomo, opcoes);
    
    % calcula as proporcoes como potencias de dois
    [largura] = size(imagem, 1);
    tamanho_max = log2 (largura);
    base = 2 * ones(1, tamanho_max + 1);
    expoente = - 1 * (0 : tamanho_max);
    escalas = base.^expoente;
    
    resultado = 0;
    for i = escalas;
        % reducao das imagens
        B = imresize(imagem_original, i, 'bilinear');
        A = imresize(imagem, i, 'bilinear');
        
        % comparacao
        resultado = sum(sum((A - double(B)).^2)) + resultado;
    end
end

function resultado = funcao_avaliacao_resolucao_com_peso(cromossomo, opcoes, imagem_original)
    % exibe a imagem para individuo
    imagem = desenhar_individuo(cromossomo, opcoes);
    
    % calcula as proporcoes como potencias de dois
    [largura] = size(imagem, 1);
    tamanho_max = log2 (largura);
    base = 2 * ones(1, tamanho_max + 1);
    expoente = - 1 * (0 : tamanho_max);
    escalas = base.^expoente;
    
    resultado = 0;
    for i = escalas;
        % reducao das imagens
        B = imresize(imagem_original, i, 'bilinear');
        A = imresize(imagem, i, 'bilinear');
        
        % peso do resultado
        peso = find(escalas == i);
        
        % comparacao
        resultado = peso * sum(sum((A - double(B)).^2)) + resultado;
    end
    
    % media ponderada
    resultado = resultado / sum(1:size(escalas, 1));
end


function [estado, opcoes_saida, opcoes_saida_alterdas] = gerar_imagem_geracao(opcoes_saida, estado, flags, opcoes)
    opcoes_saida_alterdas = [];
    
    % sendo a primeira das geracoes, nao precisa gerar imagem
    if estado.Generation == 0
        return
    end
    
    % encontra o melhor individuo da geracao atual
    melhores_pontuacoes = find(estado.Score == estado.Best(1, estado.Generation));
    melhores_individuos = estado.Population(melhores_pontuacoes, :);
    melhor_individuo = melhores_individuos(1, :);
    
    % exibe imagem para individuo
    imagem = desenhar_individuo(melhor_individuo, opcoes);
    
    % salva a imagem
    imwrite(imagem, gray(256), strcat(opcoes.diretorio_saida, 'imagem-ger', num2str(estado.Generation), '.bmp'));
end

function imagem = desenhar_individuo(cromossomo, opcoes)
    % converte a sequencia de bits para uma matriz contendo as informacoes
    % de cada circulo
    individuo = gerar_individuo(cromossomo, opcoes.bits_atributo, opcoes.circulos);
        
    % cria a imagem 
    imagem = zeros([opcoes.imagem opcoes.imagem]);
    
    % desenha o circulo correspondente na imagem
    for i = 1:opcoes.circulos;
        imagem = desenhar_circulo(imagem, individuo(i,1), individuo(i,2), individuo(i,4), individuo(i,3));
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
    X = circulos(:, (1:genes_atributo(1)) + total_genes);
    X = bi2de(X, 'left-msb');
    
    % posicao Y
    total_genes = total_genes + genes_atributo(1);
    Y = circulos(:, (1:genes_atributo(2)) + total_genes);
    Y = bi2de(Y, 'left-msb');
    
    % tonalidade
    total_genes = total_genes + genes_atributo(2);
    T = circulos(:, (1:genes_atributo(3)) + total_genes);
    T = bi2de(T, 'left-msb');
    
    % raio do circulo
    total_genes = total_genes + genes_atributo(3);
    R = circulos(:, (1:genes_atributo(4)) + total_genes);
    R = bi2de(R, 'left-msb');
    
    % individuo
    individuo = [X'; Y'; T'; R']';
end

function imagem = desenhar_circulo(imagem, dx, dy, raio, tonalidade)
    % tamanho da imagem
    [largura, altura] = size(imagem);
    
    % gera a matriz de tamanho largura x altura
    % com o circulo na posicao (dx, dy) onde o ponto (0, 0) encontra-se no centro da matriz
    X = ones(largura, 1) * (1 : largura);
    Y = (1 : altura)' * ones(1, altura); 
    Z = (X - dx).^2 + (Y - dy).^2; 

    % gera imagem
    imagem(find(Z <= raio^2)) = tonalidade; 
end