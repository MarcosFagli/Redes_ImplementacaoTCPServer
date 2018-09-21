# Redes_ImplementacaoTCPServer

Trabalho implementado para a disciplina de Redes de Computadores da Universidade Federal de São Carlos - UFSCar

## Escopo do trabalho

Implementação do protocolo TCP. Este trabalho esta sendo pensado para ser executado em Hardware, utilizando FPGA

## Escopo desta entrega

O objetivo da primeira etapa é adquirir alguma vivência no uso de sockets. Implemente algum protocolo qualquer de camada de aplicação usando sockets TCP ou UDP, na linguagem e na plataforma de sua escolha.

Dê preferência a algum protocolo de camada de aplicação que funcione sobre TCP, pois a próxima etapa do projeto será a implementação do TCP. Prefira também implementar algum protocolo que permita enviar grandes quantidades de dados em uma única conexão, pois isso será importante para testar o controle de fluxo e o controle de congestionamento do TCP durante a próxima etapa.

Note que usar algum programa ou biblioteca pronta não equivale a implementar um protocolo de camada de aplicação! Use diretamente a API de sockets de baixo nível disponível na sua linguagem / plataforma. Durante a aula, mostramos alguns exemplos do uso de sockets TCP em Python.

Caso você opte por alguma plataforma que não tenha suporte nativo a sockets, por exemplo FPGA ou microcontrolador, por enquanto você pode 1) trabalhar apenas com testes unitários; 2) trabalhar com simulação e integrar sockets ao simulador; ou 3) executar sockets em um computador para emular a parte ainda inexistente do circuito, e comunicar-se com a placa de desenvolvimento por meio de algum protocolo simples.

## Instruções para execução (Testado para o linux Mint 19)

Para compilação do código é necessário ter instalado o Bluespec, que é uma linguagem de sintetização de Hardware para a linguagem Verilog.

### Bluespec reference:

```
http://csg.csail.mit.edu/6.S078/6_S078_2012_www/resources/reference-guide.pdf
```

### Download do Bluespec 

```
http://bluespec.com/downloads/Bluespec-2017.07.A.tar.gz
```

### Configuração

Para instalar, crie um diretório /opt/bluespec e descompacte o .tar.gz dentro dele. Insira o seguinte no final do seu ~/.bashrc

```
export BLUESPECHOME="/opt/bluespec/Bluespec-2017.07.A"
export BLUESPECDIR="$BLUESPECHOME/lib"
export PATH="$PATH:$BLUESPECHOME/bin"
export LM_LICENSE_FILE=(Coloque aqui a localização da sua licença)
```
  
### Execução

É necessário apenas executar:

```
./a.out
```

### Compilação

Em caso de edição do arquivo, é necessário realizar um make na pasta do projeto (para essa etapa é necessário que o bluespec esteja configurado na máquina)


## Agradecimento

Agradeço ao Professor Doutor Paulo Matias pela ajuda com as plataformas extras ao que foi requisitado no trabalho, utilização do Bluespec e com a lógica de arquitetura em Hardware para a execução do trabalho





