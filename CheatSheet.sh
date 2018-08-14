#!/bin/bash
#
# nome_completo.sh - Busca o nome completo de usuário
#
# Site		: http://programas.com.br/nomecompleto/
# Autor		: João Silva <joao@email.com.br>
# Manutenção: Maria Teixeira <maria@email.com.br>
#
# -----------------------------------------------------------------------------
# Este programa recebe como parâmetro o login de um usuário e procura em várias 
# bases qual o seu nome completo, retornando o resultado na saída padrão (STOUT).
#
# Exemplos:
#		$ ./nome_completo.sh jose
#		José Moreira
#		$ ./nome_completo.sh joseeeee
#		$
#
# A ordem de procura do nome completo é sequencial:
#
#	1. Arquivo /etc/passwd
#	2. Arquivo $HOME/.plan
#	3. Base de Usuários LDAP
#	4. Base de Usuários MySQL
#
# Respeitando a ordem, o primeiro resultado encontrado será o retornado.
#
#
# Histórico:
#
#	v1.0 1999-05-18, João Silva:
#		- Versão inicial procurando no /etc/passwd
#	v1.1 1999-08-02, João Silva:
#		- Adicionada pesquisa no $HOME/.plan
#		- Corrigindo bug com nomes acentuados
#
#
#	Licença GPL.
#

###
#
# Este é um comentário em bloco
#
# Visualmente distinto dos comandos, serve para colocar textos extensos,
# introduções e exemplos.
#


###
#
# TODO	- Indica uma tarefa a ser feita, uma pendência
# FIXME	- Indica um bug conhecido, que precisa ser arrumado
# XXX	- Chama a atenção, é um recado ou uma notícia importante
#
# Don't comment bad code, rewrite it 
#

###
#
# Funções 	retornam números de 0 a 255 usando return
#			retornam texto usando echo
#

###
#
# Changelog (para programadores)
#
# 2003-01-31 (josé): $ARQUIVO agora pode ser um link simbólico
# 2003-02-04 (maria): adicionada opção --help
# 2003-02-10 (paulo): Corrigidos bugs #498, #367
# 2003-02-10 --- lançada versão 1.3

###
#
# News (para usuários)
#	Novidades da versão 1.3:
#	- Novas oções de linha de comando -h e --help, que mostram uma tela
#	  de ajuda e -V e --version, que mostram a versão do programa
#	- Adicionado suporte a arquivos que são links simbólicos
#	- Vários bugs reportados pelos usuários foram corrigidos, como o
#	  problema da acentuação no nome do arquivo e extensão em letras
#	  maiúsculas como o .TXT

USAR_CORES=1		#Chave para usar cores (0 desliga, 1 liga)

#comparar string ao invés de simplesmente $USAR_CORES evita erros:
if test "$USAR_CORES" -eq 1	
then
	msg_colorida $mensagem	#chama a função "msg_colorida"
else
	echo $mensagem
fi

test "$chave" = 1 && echo LIGADA	#forma simplificada

###############################################################################
#
### Configuração do programa mostra_mensagem.sh
### Use 0 (zero) para desligar as opções e 1 (um) para ligar
### O padrão é zero para todas (desligado)
#
USAR_CORES=0			# mostrar cores nas mensagens
CENTRALIZAR=0			# centralizar a mensagem na tela?
SOAR_BIPE=0				# soar um bipe ao mostrar a mensagem
CONFIRMAR=0				# pedir confirmação antes de mostrar?
MOSTRA_E_SAI=0			# sair do programa após mostrar?
#
### Fim da configuração - Não edite daqui para baixo
#
###############################################################################


###
#
# Opções padronizadas
#
# 	-h		--help			Mostra informações resumidas
#	-V		--version		Mostra versão do programa e sai
#	-v		--verbose		Mostra informações adicionais na saída
#	-q		--quiet			Não mostra nada na saída, execução quieta
#			--				Terminador de opções, depois dele não é opção
#	-c		--chars			Algo com caracteres: cut -c, od -c, wc -c
#	-d 		--delimiter		Caracteres usados como separador
#	-f		--file			Nome do arquivo a ser manipulado
#	-i		--ignore-case	Trata letras maiúsculas e minúsculas igualmente
#	-n		--number		Algo com números
#	-o		--output		Nome do arquivo de saída
#	-w		--word			Algo com palavras: grep -w, wc -w



###
#
# Exemplo de software com opções
#
#
ordernar=0			# A saída deverá ser ordenada?
inverter=0			# A saída deverá ser invertida?
maiusculas=0		# A saída deverá ser em maiúsculas?
delim='\t'			# Caractere usado como delimitador de saída

#basename remove o ./ antes do nome do arquivo que fica no parâmetro $0
MENSAGEM_USO="Uso: $(basename "$0") [OPÇÕES]

OPÇÕES:
	-d, --delimiter C	Usa o caractere C como delimitador
	-r, --reverse		Inverte a listagem
	-s, --sort			Ordena a listagem alfabeticamente
	-u, --uppercase		Mostra a listagem em MAIÚSCULAS
	
	-h, --help			Mostra esta tela de ajuda e sai
	-V, --version		Mostra a versão do programa e sai
"

# Tratamento das opções de linha de comando
while test -n "$1"
do
	case "$1" in
	
		# Opções que ligam/desligam chaves
		-s | --sort		) ordenar=1		;;
		-r | --reverse	) inverter=1	;;
		-u | --uppercase) maisuculas=1	;;
		
		-d | --delimiter)
			shift
			delim="$1"
			
			if test -z "$delim"
			then
				echo "Faltou o argumento para a -d"
				exit 1
			fi
		;;
		
		-h | --help)
			echo "$MENSAGEM_USO"
			exit 0
		;;
		
		-V | --version)
			echo -n $(basename "$0")
			# Extrai a versão diretamente dos cabeçalhos do programa
			grep '^# Versão ' "$0" | tail -1 | cut -d : -f 1 | tr -d \#
			exit 0
		;;
		
		*)
			echo "Opção inválida"
			echo "$MENSAGEM_USO"
			exit 0
        ;;

	esac
	
	#Opção $1 já processada, a fila deve andar
	shift
done

###
#
# Debug Opções
#
# Exs.:
# 	Informa a linha do erro: 								bash -n grita.sh 
#	Mostra comando a comando:								bash -x grita.sh
#		'+' indica linhas sendo executadas
#		'++' indica execução numa subshell
#	Mostra o número das linhas:								bash -v grita.sh
#	Ligar/Desligar debug setorizado:						set -x;...; set +x; 
#															set -v;...;set +v;
#	Depuração passo-a-passo:								trap read DEBUG
#		(Não funciona no Bourne Sh)							trap "" DEBUG

DEBUG=1				#depuração: 0 desliga, 1 liga

# Função de depuração
Debug(){
	[ "$DEBUG" = 1 ] && echo "$*"
}

# Mostra as mensagens de depuração em amarelo
Debug(){
	[ "$DEBUG" = 1 ] && echo -e "\033[33;1m$*\033[m"
}

###
#
# Código de Cores no Linux
#
# ESC [ n1; n2; ... m
#
#	Onde ESC = \033
#	Terminando sempre com m
#
#	Exemplo: 	echo -ne '\033[2J'
#				echo -e '\033[31m MENSAGEM IMPORTANTE!!!! \033[m'
#
#	0 	- Texto Normal					5	- Pisca-pisca
#	1 	- Cor brilhante					7	- Vídeo reverso
#	30	- Preto(ou cinza)				40	- Fundo preto(ou cinza)
#	31	- Vermelho						41	- Fundo vermelho
#	32	- Verde							42	- Fundo verde
#	33	- Marrom(ou amarelo)			43	- Fundo marrom(ou amarelo)
#	34	- Azul							44	- Fundo azul
#	35	- Roxo							45	- Fundo roxo
#	36	- Ciano							47	- Fundo cinza(ou branco)
#	37	- Cinza(ou branco)				46	- Fundo ciano	
#										

###
#
# Subistituição de Parâmetros
#
#
# $parametro
# ${parametro}
# ${#parametro}
# ${parametro=}
# ${parametro-padrao}
# ${parametro=padrao}
# ${parametro+valor_novo}
# ${parametro?mensagem}
#
# Subistituição de Comandos
# 
# $(comando)
# `comando`
#
# Exemplo:
# 	echo o caminho para dir é `which dir`
# 	o caminho para dir é /usr/bin/dir
#

