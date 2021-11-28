#!/bin/bash

BOARD=(0 0 0 0 0 0 0 0 0)
PLAYER1=1
PLAYER2=2
PLAY_WITH_PC=false

game_ended=false
current_player=$PLAYER1

function show_cell() {
  if [[ ${BOARD[$1]} == $PLAYER1 ]]; then
    echo -e "X \c"
  elif [[ ${BOARD[$1]} == $PLAYER2 ]]; then
    echo -e "O \c"
  else
    echo -e "  \c"
  fi
}

function show_board() {
  clear
  for i in {0..8}; do
    show_cell $i
    if [[ $(expr $(($i + 1)) % 3) == 0 ]]; then
      echo
    else
      echo -e " | \c"
    fi
  done
}

function show_board_instruction() {
  for i in {0..8}; do
    echo -e $i "\c"
    if [[ $(expr $(($i + 1)) % 3) == 0 ]]; then
      echo
    else
      echo -e "| \c"
    fi
  done
  echo
}

function finish_game() {
  if [[ $PLAY_WITH_PC == true ]] && [[ $current_player == "$PLAYER2" ]]; then
    echo "Koniec gry: Wygrał komputer!"
  else
    echo "Koniec gry: Wygrał gracz nr: ${current_player}"
  fi

  game_ended=true
}

function check_game_ended() {
  for ((i = 0; i <= 6; i = i + 3)); do
    if [ ${BOARD[$i]} == $current_player ] && [ ${BOARD[$i + 1]} == $current_player ] && [ ${BOARD[$i + 2]} == $current_player ]; then
      finish_game
      return
    fi
  done

  for ((i = 0; i <= 2; i++)); do
    if [ ${BOARD[$i]} == $current_player ] && [ ${BOARD[$i + 3]} == $current_player ] && [ ${BOARD[$i + 6]} == $current_player ]; then
      finish_game
      return
    fi
  done

  if [ ${BOARD[0]} == $current_player ] && [ ${BOARD[4]} == $current_player ] && [ ${BOARD[8]} == $current_player ]; then
    finish_game
    return

  fi

  if [ ${BOARD[2]} == $current_player ] && [ ${BOARD[4]} == $current_player ] && [ ${BOARD[6]} == $current_player ]; then
    finish_game
    return
  fi

  board_filled=true
  for i in {0..8}; do
    if [ ${BOARD[$i]} == 0 ]; then
      board_filled=false
      break
    fi
  done

  if [ $board_filled == true ]; then
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

function handle_save_game() {
  printf "%s " "${BOARD[@]}" >saved.txt
  echo $current_player >>saved.txt

  game_ended=true
}

function restore_from_save() {
  array=($(head -n 1 saved.txt))

  for i in {0..8}; do
    echo -e ${array[$i]}
    case "${array[$i]}" in
    "0") BOARD[$i]=0 ;;
    "1") BOARD[$i]=1 ;;
    "2") BOARD[$i]=2 ;;
    esac
    current_player=${array[9]}
  done
}

function get_player_move() {
  while true; do

    if [[ $PLAY_WITH_PC == true ]] && [[ $current_player == "$PLAYER2" ]]; then
      echo "Kolej komputera!"
      pos=$((($RANDOM % 8)))
      while [ ${BOARD[$pos]} != 0 ]; do
        pos=$((($RANDOM % 8)))
      done

      BOARD[$pos]=$current_player
      break
    else
      echo "Kolej gracza: ${current_player}"
      read pos
    fi

    if [[ $pos == 's' ]]; then
      handle_save_game
      break
    fi

    if [[ $pos == 'r' ]]; then
      restore_from_save
      clear
      show_board
      echo "Kolej gracza: ${current_player}"
      read pos
    fi

    if [[ $pos == ?(-)+([0-9]) ]] && [ $pos -ge 0 ] && [ $pos -le 8 ] && [ ${BOARD[$pos]} == 0 ]; then
      BOARD[$pos]=$current_player
      break
    fi
    echo "Pozycja zajęta lub nieprawidłowy numer pola! Wprowadż ponownie numer pola."
  done
}

show_welcome_info() {
  clear
  echo -e "Witaj w grze! Aby wybrać pole użyj cyfr od 0 do 8 jak przedstawiono poniżej:\n"
  show_board_instruction
  echo -e "Aby zapisać stan gry podczas rozgrywki wciśnij klawisz 's' \n\n"
  echo -e "Aby wczytać ostatnio zapisany stan gry podczas rozgrywki wciśnij klawisz 'r' \n\n"
}

select_game_type() {
  echo "Wybierz tryb rozgrywki naciskając odpowiedni klawisz:"
  echo "1) 2 graczy"
  echo "2) gra z komputerem"

  read type
  case $type in
  "1") PLAY_WITH_PC=false ;;
  "2") PLAY_WITH_PC=true ;;
  esac
}

show_welcome_info
select_game_type
while [ $game_ended == false ]; do
  get_player_move
  show_board
  check_game_ended
  switch_player
done
