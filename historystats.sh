#!/bin/bash

#+--------------------------+
#|chmod +x ./historystats.sh|
#+--------------------------+

# Declaration fonction pour sauter une ligne.
sauterLigne()
(
  echo -e "\\n"
)

sauterLigne
echo ">! Que faire? !<"
echo "1. Un back-up du fichier bash_history (recommandé pour une première utilisation)."
echo "2. Consulter un résumé de l'historique."
echo "3. Quitter"
read -r choixMenu

# Si 1 alors on sauvegarde le fichier de base
if [ "$choixMenu" = 1 ] ; then
  sauterLigne

  # Si le fichier n'existe pas.
  if [ ! -f ~/.bash_history ] ; then

    echo "!> Le fichier n'existe pas."
    sauterLigne
    echo "!> Voulez-vous le créer?"

    select on in "Oui" "Non" ; do
      case $on in

        Oui ) sauterLigne
        echo "#> Création du fichier..."; touch ~/.bash_history
        echo "#> Ajout des commandes suivantes dans le ~/.bash_profile... "
        echo "SHELL_SESSION_HISTORY=0" >> ~/.bashrc
        echo "HISTSIZE=1000" >> ~/.bashrc
        echo "HISTFILESIZE=4000" >> ~/.bashrc
        tail -n 3 ~/.bashrc
        source ~/.bashrc
        sauterLigne
        ./historystats.sh;;

        Non ) echo "!> Fin du programme."; exit;;

      esac
    done

  # Sinon si le fichier existe déjà.
  else

    cp ~/.bash_history ~/.bash_history.bak;
    echo "!> Fichier sauvegardé."
    realpath ~/.bash_history.bak
    sauterLigne
    ./historystats.sh

  fi

# Consulter résumé historique
elif [ "$choixMenu" = 2 ] ; then

  if [ ! -f ~/.bash_history ] ; then

    sauterLigne
    echo -e "/!\\ Le bash_history semble ne pas encore exister sur votre système.../!\\"
    sauterLigne
    echo ">! Vous pouvez le créer en sélectionnant le choix 1 dans le menu."
    echo ">! Revenir au menu?"

    select on in "Oui" "Non" ; do
      case $on in

        Oui ) ./historystats.sh;;

        Non ) echo ">! Au revoir!"; exit;;

      esac
    done

  elif [ ! -s ~/.bash_history ] ; then

    sauterLigne
    echo ">! Le fichier est vide ou pas suffisament rempli!"
    echo ">! Veuillez relancer le script d'ici quelques temps pour voir le résultat."
    kill $$; exit

  else

    sauterLigne
    # Copie toutes les lignes du fichier bash_history dans une variable afin de simplifier les manipulations.
    fichier=~/.bash_history

    # Nombre de lignes non uniques.
    nbCommandes=$(wc -l $fichier | awk '{ print $1 }')

    # Nombre de lignes uniques.
    nbLignes=$(sort $fichier | uniq -ui | wc -l)

    # Nombre de mots
    nbMots=$(wc -w $fichier | awk '{ print $1 }')

    # Pourcentage.
    pourcentage=$((100*nbLignes/nbCommandes))

    echo "=> Top 10 des commandes les plus utilisés"
    sort $fichier | uniq -c | sort -bgr | head -n 10

    sauterLigne
    echo "=> Il y a $nbLignes commandes différentes, sur un total de $nbCommandes commandes tapées, soit environ $pourcentage%. Entre autre, l'historique contient $nbMots mots ou groupe de caracteres."

    sauterLigne
    echo ">! Voulez-vous continuer? <!"
    select on in "Oui" "Non" ; do
      case $on in

        Oui ) ./historystats.sh;;

        Non ) exit;;

      esac
    done

    fi

# Quitter le programme
elif [ "$choixMenu" = 3 ] ; then

    sauterLigne
    echo "!> Fin du programme"

    # On kill directement le group de sous-processus
    # Il est preferable de proceder ainsi
    # s'il y a eu usage de pipes precedemment.
    PGID=$(ps -o pgid= $$ | grep -o [0-9]*)
    setsid kill -- -$PGID

# Si le choix est invalide, on ré-exécute le script.
elif [[ "$choixMenu" != [1-3] ]] ; then

  sauterLigne
  echo -e "/!\\ Choix non valide /!\\"
  ./historystats.sh

fi
