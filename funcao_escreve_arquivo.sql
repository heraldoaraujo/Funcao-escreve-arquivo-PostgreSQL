-- Autor            : Heraldo Araujo da Silva
-- Data atualizacao : 05/02/2019
-- Descricao        : Funcao que escreve a saida em um arquivo no servidor. Esse programa
--                  : funciona de forma semelhante ao pacote UTL_FILE do Oracle.
--                  : Muito util quando precisar converter um programa PL/SQL para PL/PGSQL
-- Parametros       : diretorio    = pasta no S.O com permisao de escrita
--                  : nome_arquivo = nome do arquivo que sera gravado
--                  : v_linha      = string da linha que ira salvar
--                  : controle     = parametro de controle do programa que pode receber
--                  :                'E' escreve no arquivo
--                  :                'F' fecha e salva o arquivo
--                  :                'C' fecha o arquivo sem salvar
-- Notas            : 1- Os parametros diretorio,nome_arquivo e controle sao obrigatorios.
--                  : 2- Quando se passa o parametro controle como 'E' significa que
--                  :    ira adicionar uma nova linha para o arquivo de saida.
--                  : 3- Quando se passa o parametro controle como 'F' o arquivo sera
--                  :    fechado e salvo.
--                  : 4- Quando se passa o parametro controle como 'C' o arquivo sera
--                  :    fechado sem salvar.
-- Exemplo          : psql> select escreve_arquivo('/var/lib/pgsql','saida.txt','maria','E');
--                  : psql> select escreve_arquivo('/var/lib/pgsql','saida.txt','joao','E');
--                  : psql> select escreve_arquivo('/var/lib/pgsql','saida.txt',null,'F');
--                  : $ cat saida.txt
--                  : maria
--                  : joao

create or replace function public.escreve_arquivo 
(in diretorio    varchar,
 in nome_arquivo varchar,
 in v_linha      varchar,
 in controle     varchar) returns void as $$
declare
arq_dados   varchar(300);
saida_erro  varchar(500);
conta_linha numeric     := 0;
begin
  if not exists (select * from information_schema.tables where  table_name = 'expurga_no_arquivo') then 
     create temp table expurga_no_arquivo (numero_linha integer, c_escrita varchar(2000));
  end if;
  
  if char_length(v_linha) > 2000 then 
     raise exception 'Erro no tamanho da linha. O tamanho máximo é de 2000 caracteres';
  end if;
  if diretorio is null then
     raise exception 'Erro no primeiro parametro ,diretorio nao pode ser nulo ou nao existe esse';
  end if;
  if nome_arquivo is null then
     raise exception 'Erro no segundo parametro ,nome do arquivo nao pode ser nulo';
  end if;
  
  if position('/' in reverse(diretorio)) <> 1 then
     arq_dados := ''''||diretorio||'/'||nome_arquivo||'''';
  else
     arq_dados := ''''||diretorio||nome_arquivo||'''';
  end if;
  
  execute 'copy (select  ''teste se o arquivo existe'') to '||arq_dados ;
  
  if upper(controle) = 'E' then
     select count(*) from expurga_no_arquivo into conta_linha;
     conta_linha := conta_linha + 1;
     insert into expurga_no_arquivo (numero_linha,c_escrita) values (conta_linha ,v_linha);
  elsif upper(controle) = 'F' then
     execute 'copy (select c_escrita 
                    from expurga_no_arquivo
                    order by numero_linha asc) to '|| arq_dados ;
     drop table expurga_no_arquivo ; 
  elsif upper(controle) = 'C' then
     drop table expurga_no_arquivo ;
  else
     raise exception 'Erro no terceiro parametero, deve ser E=escrever, F=fechar e salvar C=fechar sem salvar'; 
  end if; 

exception when others then  
  raise notice '----OPS, algo deu errado--------';
  saida_erro := sqlerrm;
  raise notice '%', saida_erro;
end;
$$ language plpgsql;
