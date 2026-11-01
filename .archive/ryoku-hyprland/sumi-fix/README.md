# Ajuste opcional da barra SUMI

Corrige a barra em janelas maximizadas, abre o histórico de notificações pelo
ícone do sino e mostra somente o kanji de cada workspace, sem círculos ou
fundos. O kanji ativo e o que recebe o cursor ganham realce de cor com uma
transição suave. Cada monitor mostra somente seus próprios workspaces, em ordem
numérica crescente; os números reais de 1 a 10 são exibidos como 一–十, e nomes
fora desse intervalo permanecem inalterados. Clicar no relógio abre um painel
com calendário e previsão do tempo; calendário e notificações usam o mesmo
cartão e a mesma animação de expansão dos demais popouts SUMI. Os dois painéis
iniciam e recolhem a animação sobre o widget acionador, sem alterar a posição ou
o tamanho final. O calendário exibe a grade de datas sem moldura duplicada e
usa uma previsão compacta (condições atuais, próximas horas e três dias),
enquanto o popout de notificações permanece inalterado. Os ajustes ficam
separados por função:
correção da barra, workspaces Kanji, comportamento de notificações, clique do
relógio e, juntos, o layout/animação dos popouts de calendário e notificações.
O instalador aplica e reverte os patches na ordem necessária. O ajuste é
opcional e pode ser selecionado no menu:

```sh
./tomoe install
```

Também é possível selecioná-lo diretamente:

```sh
./tomoe install --sumi
```

Para remover, escolha SUMI no menu de `./tomoe uninstall`. O script executa
`ryoku reload` automaticamente após aplicar ou remover o patch.

Os patches alteram arquivos distribuídos pelo Ryoku. O instalador verifica o
contexto antes de aplicá-los e interrompe a operação se não puder fazê-lo com
segurança. O comportamento dos workspaces fica consolidado em um único patch
definitivo; instalações com um patch Kanji antigo ou personalizado precisam
voltar ao estado original antes de aplicar esta versão.
