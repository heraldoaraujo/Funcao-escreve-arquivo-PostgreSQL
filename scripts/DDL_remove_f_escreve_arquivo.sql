-- Autor            : Heraldo Araujo da Silva
-- Data atualizacao : 12/02/2019
-- Descricao        : Script que exclui o programa public.escreve_arquivo

drop function if exists public.f_escreve_arquivo(diretorio varchar,nome_arquivo varchar,v_linha anyelement,controle varchar);
