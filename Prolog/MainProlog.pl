:-dynamic posicao/3.
:-dynamic conhecimento/4.
:-dynamic inimigo_avistado/1.

posicao(0,0,north).
inimigo_avistado(0).

% Células Adjacentes
adjacente(X, Y, AX, Y) :- X < 59, AX is X + 1.   
adjacente(X, Y, AX, Y) :- X > 0,  AX is X - 1.   
adjacente(X, Y, X, AY) :- Y < 34, AY is Y + 1. 
adjacente(X, Y, X, AY) :- Y > 0,  AY is Y - 1.

% Definir Posição do Agente
def_pos(X, Y, P) :- retract(posicao(_,_,_)), assert(posicao(X, Y, P)),
					retract(conhecimento(X,Y,_,_)), assert(conhecimento(X,Y,nada,1)).

% Marca arredores como livres
arredores_livres(X, Y) :- adjacente(X, Y, AX, AY), retract(conhecimento(AX, AY, _, _)),
						  assert(conhecimento(AX, AY, nada, _)).
arredores_livres(X, Y) :- adjacente(X, Y, AX, AY), not(conhecimento(AX, AY, _, _)),
						  assert(conhecimento(AX, AY, nada, 0)).

% Detecta Obstáculo
	% Para Cima
add_obstaculo :- posicao(X,Y,P), P = north, YY is Y - 1, not(conhecimento(X, YY, _, _)),
		 		 assert(conhecimento(X, YY, obstaculo, _)),!.
add_obstaculo :- posicao(X,Y,P), P = north, YY is Y - 1,
		 		 retract(conhecimento(X, YY, _, _)), assert(conhecimento(X, YY, obstaculo, _)),!.
    % Para Baixo
add_obstaculo :- posicao(X,Y,P), P = south, YY is Y + 1, not(conhecimento(X, YY, _, _)),
		 		 assert(conhecimento(X, YY, obstaculo, _)),!.
add_obstaculo :- posicao(X,Y,P), P = south, YY is Y + 1,
		 		 retract(conhecimento(X, YY, _, _)), assert(conhecimento(X, YY, obstaculo, _)),!.
    % Para Direita
add_obstaculo :- posicao(X,Y,P), P = east, XX is X + 1, not(conhecimento(XX, Y, _, _)),
				 assert(conhecimento(XX, Y, obstaculo, _)),!.
add_obstaculo :- posicao(X,Y,P), P = east, XX is X + 1,
		 		 retract(conhecimento(XX, Y, _, _)), assert(conhecimento(XX, Y, obstaculo, _)),!.
    % Para Esquerda
add_obstaculo :- posicao(X,Y,P), P = west, XX is X - 1, not(conhecimento(XX, Y, _, _)),
				 assert(conhecimento(XX, Y, obstaculo, _)),!.
add_obstaculo :- posicao(X,Y,P), P = west, XX is X - 1,
		 		 retract(conhecimento(XX, Y, _, _)), assert(conhecimento(XX, Y, obstaculo, _)),!.

% Detecta Buraco & Teletransporte
add_problema :- posicao(X, Y, _), adjacente(X, Y, AX, AY), conhecimento(AX, AY, Q, _), Q \= nada,
			    retract(conhecimento(AX, AY, _, _)), assert(conhecimento(AX, AY, obstaculo, _)).
add_problema :- posicao(X, Y, _), adjacente(X, Y, AX, AY), not(conhecimento(AX, AY, _, _)),
			    assert(conhecimento(AX, AY, obstaculo, _)). 

% Detecta Item
add_item :- posicao(X, Y, _), not(conhecimento(X,Y,_,_)), assert(conhecimento(X,Y,item,0)),!.
add_item :- posicao(X, Y, _), retract(conhecimento(X,Y,_,_)), assert(conhecimento(X,Y,item,_)),!.
% Detecta powerup
add_pu :- posicao(X,Y,_), not(conhecimento(X,Y,_,_)), assert(conhecimento(X,Y,powerup,0)),!.
add_pu :- posicao(X,Y,_), retract(conhecimento(X,Y,_,_)), assert(conhecimento(X,Y,powerup,_)),!.

% Avistar inimigo
avistar_inimigo :- retract(inimigo_avistado(_)), assert(inimigo_avistado(1)).

% Atacar
atacar :- retract(inimigo_avistado(_)), assert(inimigo_avistado(0)).

% Pegar Item/Powerup
pegar :- posicao(X,Y,_), retract(conhecimento(X,Y,_,_)), assert(conhecimento(X,Y,nada,1)).

% Ações, em ordem de preferência

	% Pegar o Item
acao(A) :- posicao(X, Y, _), conhecimento(X, Y, item, _), A = pegar_item.

	% Pegar Power Up
acao(A) :- posicao(X, Y, _), conhecimento(X, Y, powerup, _), A = pegar_powerup.

	% Se avistou inimigo
acao(A) :- inimigo_avistado(1), A = atacar.

	% Andar para não visitado que não tenha nada
acao(A) :- posicao(X,Y,P), P = north, Y > 0, YY is Y - 1,
		   conhecimento(X, YY, nada, 0), A = andar,!.
acao(A) :- posicao(X,Y,P), P = south, YY is Y + 1,
		   conhecimento(X, YY, nada, 0), A = andar,!.
acao(A) :- posicao(X,Y,P), P = east, XX is X + 1,
		   conhecimento(XX, Y, nada, 0), A = andar,!.
acao(A) :- posicao(X,Y,P), P = west, X > 0,  XX is X - 1,
		   conhecimento(XX, Y, nada, 0), A = andar,!.

	% Virar-se caso tenha algum adjacente não visitado que não tenha nada 
acao(A) :- posicao(X,Y,_), adjacente(X, Y, AX, AY),
           conhecimento(AX, AY, nada, 0), A = virar_direita.

    % Andar por onde já foi se não tiver mais opção
acao(A) :- posicao(X,Y,P), P = north, Y > 0, YY is Y - 1,
		   conhecimento(X, YY, nada, 1), A = andar,!.
acao(A) :- posicao(X,Y,P), P = south, YY is Y + 1,
		   conhecimento(X, YY, nada, 1), A = andar,!.
acao(A) :- posicao(X,Y,P), P = east, XX is X + 1,
		   conhecimento(XX, Y, nada, 1), A = andar,!.
acao(A) :- posicao(X,Y,P), P = west, X > 0,  XX is X - 1,
		   conhecimento(XX, Y, nada, 1), A = andar,!.

	% Virar-se caso tenha algum adjacente visitado que não tenha nada 
acao(A) :- posicao(X,Y,_), adjacente(X, Y, AX, AY),
           conhecimento(AX, AY, nada, 1), A = virar_direita.