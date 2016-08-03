#!/bin/bash 
# Programa para autenticação de usuario no gnome-terminal
#
# Mateus 07-05-2016
# 
# Versao 1 Realiza autenticacao e caso falhe o usuario nao podera usar o terminal
#
# Mateus 25-05-2016
# 
# Versao 2 Realiza autenticacao e evita que o usuário evite a autenticacao digitando ^C 
#    -Alem de utilizar um sal aleatorio para o hash.
#
# Mateus 11-06-2016
#
# Versao 3 Correcao da falha de caracteres "estranhos", caso o usuario teclasse end,
# up, ctrl+<letra>, etc, a autenticação seria burlada. 
######################################################################################

CONT=1
yn=' '

/usr/local/bin/term_stats &

echo -e "\tXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n"
echo -e "\t\tWELCOME TO THE TERMINAL AUTHENTICATION SYSTEM (TAS) \n"
echo -e "\t\t\t\tby Mateus Sousa"
echo -e "\tXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n\n"

if [ ! -f "/etc/term_pass" ] 
then 
    echo "File /etc/term_pass not found!! Exiting..."
    exit 2
fi 

if grep $(whoami) "/etc/term_account" > /dev/null 2> /dev/null
then
	yn='y'
else
	yn='n'
fi

if [ "$yn" = 'n' ] 
then
    /usr/local/bin/create_term_account
fi

SALT=$(grep $(whoami) /etc/term_account |cut -d: -f1)

while :
do
   if ps -aux | grep "gnome-terminal-server"  > /dev/null 2> /dev/null
   then
	while [ $CONT -lt 4 ] ; do	      
	      stty -echo 
	      echo " " 
	      read -p "Insert your password to access the terminal: " passw
	      [ -z "$passw" ] && passw=0
	      [ -z "$SALT" ] && SALT=0

		   if grep "$(perl -e "print crypt($passw,$SALT)")" /etc/term_pass &> /dev/null 
		   then
		   		perl -e "crypt($passw,$SALT)" &> /dev/null
			    if [ $? -ne 0 ]  
			    then
			    	echo -e "\t\tInvalid password! Try again." 
			     	let CONT++			     	
			     	continue
			 	fi
				
				echo " " 
				echo 1 > /tmp/status
				clear
				echo -e "\t\t\t\tWELCOME $(whoami | tr [a-z] [A-Z])\n"
				stty echo 			
				exit			
		   else
			echo " " 
			echo -e "\t\tInvalid password! Try again."
			let CONT++
		  fi			
	done
	echo " " 
	echo -e "\t\tTries has reached a limit.\nBYE" 
        sleep 4
	killall "gnome-terminal-server"
	exit
  fi
done
