function individuo = gerar_individuo(cromossomo, genes_atributo, total_atributos, total_circulos)
    circulos = reshape(cromossomo, genes_atributo, total_atributos, total_circulos);
    circulos = permute(circulos, [2 1 3]);
    individuo = ones(total_circulos, total_atributos);
    for i = 1:total_circulos
        individuo(i,:) = bi2de(circulos(:,:,i), 'left-msb')';
    end
end