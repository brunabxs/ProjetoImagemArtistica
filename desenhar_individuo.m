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
        imagem = desenha_circulo(imagem, individuo(i,1), individuo(i,2), individuo(i,3));
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