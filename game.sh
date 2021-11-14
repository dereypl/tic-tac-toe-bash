#!/bin/bash

BOARD=(0 0 0 0 0 0 0 0 0)
PLAYER1=1
PLAYER2=2

game_ended=false
current_player=$PLAYER1

function show_cell() {
    if [ ${BOARD[$1]} == $PLAYER1 ]; then
      echo -e "X \c"
    elif [ ${BOARD[$1]} == $PLAYER2 ]; then
      echo -e "O \c"
    else
      echo -e "  \c"
    fi
}

function show_board() {
  clear
  for i in {0..8}; do
    show_cell $i
    if [ $(expr $(($i + 1)) % 3) == 0 ]; then
      echo
    else
      echo -e " | \c"
    fi
  done
}

function finish_game(){
  echo "Koniec gry: Wygrał gracz nr: ${current_player}";
  game_ended=true
}

function check_game_ended {
    for((i=0; i<=6; i=i+3)){
      if [ ${BOARD[$i]} == $current_player ] && [ ${BOARD[$i+1]} == $current_player ] && [ ${BOARD[$i+2]} == $current_player ]
      then
        finish_game
        return
      fi
    }

     for((i=0; i<=2; i++)){
      if [ ${BOARD[$i]} == $current_player ] && [ ${BOARD[$i+3]} == $current_player ] && [ ${BOARD[$i+6]} == $current_player ]
      then
        finish_game
        return
      fi
    }

    if [ ${BOARD[0]} == $current_player ] && [ ${BOARD[4]} == $current_player ] && [ ${BOARD[8]} == $current_player ]
    then
      finish_game
      return

    fi

    if [ ${BOARD[2]} == $current_player ] && [ ${BOARD[4]} == $current_player ] && [ ${BOARD[6]} == $current_player ]
    then
      finish_game
      return
    fi

    board_filled=true
    for i in {0..8}
    do
        if [ ${BOARD[$i]} == 0 ]
        then
            board_filled=false
            break
        fi
    done

    if [ $board_filled == true ]
    then
      echo 'Koniec gry: Remis!'
      game_ended=true
    fi
}

function switch_player() {
  if [ $current_player == $PLAYER1 ]; then
    current_player=$PLAYER2
  else
    current_player=$PLAYER1
  fi
}

function get_player_move(){
  while true; do
    echo "Kolej gracza: ${current_player}"
    read pos
    if [[ $pos == ?(-)+([0-9]) ]] && [  $pos -ge 0 ] && [  $pos -le 8 ] && [ ${BOARD[$pos]} == 0 ]; then
      BOARD[$pos]=$current_player
      break
    fi
    echo "Pozycja zajęta lub nieprawidłowy numer pola! Wprowadż ponownie numer pola."
  done
}

while [ $game_ended == false ]; do
  get_player_move
  show_board
  check_game_ended
  switch_player
done
