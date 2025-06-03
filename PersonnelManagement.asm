section .data

max_message db "Maximum personnel atteint!",10
max_message_len equ $ - max_message
S dd 0
 ; Variables de calcul
int_str times 12 db 0 ; Buffer pour partie entière
dec_str db 0, 0 ; Buffer pour décimale
int_part dd 0
dec_part dd 0
input_num db 0 
max_id dw 0 ; ID personne la plus âgée
min_id dw 0 ; ID personne la plus jeune
max_age dw 0 ; Âge maximum
min_age dw 0 ; Âge minimum (sera écrasé par première valeur) 
 
 ; Caractere utile
point db '.'
zero db '0'
espace db " ", 0 

 ; Messages existants
moyenne_msg db "Moyenne d'age: ", 0
moyenne_msg_len equ $ - moyenne_msg

msg_ages db ", listes des ages : ", 0
len_ages equ $ - msg_ages

result_msg db "Resultats:", 10, 0
result_msg_len equ $ - result_msg

oldest_msg db "Plus agee: ", 0
oldest_msg_len equ $ - oldest_msg

youngest_msg db "Plus jeune: ", 0
youngest_msg_len equ $ - youngest_msg

 
del_msg db "Entrez l'ID à supprimer (", 0
del_len equ $ - del_msg

msg_suppression2 db "): ", 0
len_suppression2 equ $ - msg_suppression2

del_success db "Suppression réussie.", 0xA, 0
del_success_len equ $ - del_success

del_fail db "ID invalide.", 0xA, 0
del_fail_len equ $ - del_fail

msg_err_sup db "La liste est vide.", 0xA, 0
len_err_sup equ $ - msg_err_sup

msg_ids_existants db "IDs existants : ", 0
len_ids_existants equ $ - msg_ids_existants

message1 db 'choisis l option',10,'1 Enregistrer du personnel',10,'2 Lister des personnes enregistrées',10,'3 Supprimer une personne spécifique',10,'4 Afficher la personne la plus âgée, et la personne la plus jeune.',10,'5 Afficher l’âge moyen de toutes les personnes enregistrées',10,'6 Quitter le programme',10
longueur1 equ $ - message1

msg_enreg db 'Enregistrement des personnes: ',10
len_enreg equ $ - msg_enreg ; Longueur du message d'enregistrement

msg_list db 'Liste du personnel:',10,0
len_list equ $ - msg_list

msg_choix db 'Donner votre choix (entre 1 et 6) : ', 0
lng_msg_choix equ $ - msg_choix

msg_err db 'Erreur!',10,0
len_err equ $ - msg_err ; Longueur du message d'erreur

message2 db 'error'
longeur2 equ $ - message2

input times 32 db 0
person_size equ 34; (2 octet ID, 30 octets pour le nom, 2 pour age)

person_count dd 0 ;compteur de persoones en mémoire
id_count dd 0 ;compteure pour donner les id a les utilisateur (auto increment)

space db ' '
newline db 10
personnel db 0;


section .text

global _start
_start :
jmp debut 
afficher :
  push eax
  push ebx
  mov eax, 4
  mov ebx,1
  int 80h
  pop ebx
  pop eax
  ret

lire :
  push eax
  push ebx
  mov eax, 3
  mov ebx,0
  int 80h
  pop ebx
  pop eax
  ret

empty:
  mov ecx, msg_err_sup
  mov edx, len_err_sup
 call afficher
  jmp debut

debut:

  mov ecx, message1
  mov edx,longueur1
 call afficher

  mov ecx, msg_choix
  mov edx, lng_msg_choix
 call afficher

  mov ecx, input
  mov edx, 2 
 call lire

;on choisis un pearmis 6 choix

  cmp byte [input],'1'
  je enregistrement
  cmp byte [input],'2'
  je lister
  cmp byte [input],'3'
  je supprimer
  cmp byte [input],'4'
  je min_max
  cmp byte [input],'5'
  je moyenne
  cmp byte [input],'6'
  je quitter
  mov ecx, msg_err
  mov edx, len_err
 call afficher
  jmp debut

enregistrement:
 ; Initialiser la zone mémoire à 0 (34 octets)

  cmp dword [person_count], 99 ;teste si id attiend au nombre 99
  jle enreg
 ; Affichage du message de max atteint
  mov edx, max_message 
  mov ecx, max_message 
 call afficher
  jmp debut
 
enreg:
  mov edi, personnel ;Adresse de base du tableau
  mov eax, [person_count] ;Index de la nouvelle personne
  imul eax, person_size ;Calcul offset (index * taille personne)
  add edi, eax ;EDI pointe maintenant sur la nouvelle entrée
 
  push ecx
  mov ecx, person_size
  xor eax, eax

clear_loop:
  mov [edi], al ;Mettre à 0 l'octet courant
  inc edi ;Passer à l'octet suivant
 loop clear_loop ;Répéter jusqu'à ce que ECX = 0
  pop ecx ;Restaurer ECX

 ; Demander les informations
  mov ecx, msg_enreg
  mov edx, len_enreg
 call afficher
 
 ; Lire l'entrée utilisateur
  mov ecx, input
  mov edx, 32
 call lire

 ; Trouver l'espace séparateur
  mov esi, input
  mov ecx, 32
find_space_loop:
  mov al, [esi]         ; Charger le caractère courant dans AL
  inc esi               ; Avancer le pointeur au caractère suivant
  cmp al, ' '           ; Comparer le caractère avec un espace
  je space_found        ; Si égal, sauter à space_found (espace trouvé)

  cmp al, 10            ; Comparer avec le caractère de nouvelle ligne (fin de saisie)
  je input_error        ; Si nouvelle ligne trouvée avant espace → erreur
  loop find_space_loop
 
  jmp input_error

space_found:
 ; Préparer la position de stockage
  mov edi, personnel
  mov eax, [person_count]
  imul eax, person_size
  add edi, eax
 
 ; 1. Stocker l'ID (2 octets)
mov eax, [id_count]           ; Charger le compteur d'ID actuel
    inc eax                       ; Incrémenter l'ID pour la nouvelle personne
    mov [id_count], eax           ; Sauvegarder le nouveau compteur
    
    ; Convertir le nombre en deux chiffres ASCII
    mov bl, 10                    ; Préparer la division par 10
    div bl                        ; AL = quotient (dizaines), AH = reste (unités)
    add al, '0'                   ; Convertir la dizaine en ASCII
    add ah, '0'                   ; Convertir l'unité en ASCII
    
    ; Stocker les deux chiffres dans la structure
    mov [edi], al                 ; Stocker le chiffre des dizaines
    mov [edi+1], ah               ; Stocker le chiffre des unités
    add edi, 2                    ; Avancer le pointeur de 2 octets

 ; 2. Stocker le Nom (30 octets)
    mov esi, input                ; Pointeur vers le début de l'entrée utilisateur
    mov ecx, 30                   ; Nombre maximum de caractères pour le nom
    
copy_name_loop:
    mov al, [esi]                 ; Charger le caractère actuel
    cmp al, ' '                   ; Vérifier si c'est l'espace séparateur
    je end_name_copy              ; Si oui, fin du nom
    cmp al, 10                    ; Vérifier si c'est un saut de ligne
    je end_name_copy              ; Si oui, fin du nom
    mov [edi], al                 ; Stocker le caractère dans la structure
    inc esi                       ; Avancer dans l'entrée utilisateur
    inc edi                       ; Avancer dans la structure
    loop copy_name_loop           ; Continuer jusqu'à ce que ECX atteigne 0


end_name_copy:
 ; Remplir avec des espaces si nécessaire
  cmp ecx, 0
  je store_age
fill_spaces:
  mov byte [edi], ' '
  inc edi
 loop fill_spaces

store_age:
 ; Vérifier si l'âge a un ou deux chiffres
  mov al, [esi+1] ; Premier caractère d'âge
  mov bl, [esi+2] ; Deuxième caractère
 
 ; Vérifier si c'est un retour à la ligne (âge à un chiffre)
  cmp bl, 10
  je single_digit_age
 
 ; Vérifier si c'est un espace (âge à un chiffre avec espace après)
  cmp bl, ' '
  je single_digit_age
 
 ; Cas à deux chiffres (10-99)
  mov [edi], al ; Stocker premier chiffre
  mov [edi+1], bl ; Stocker deuxième chiffre
  jmp age_stored

single_digit_age:
 ; Cas à un chiffre (0-9)
  mov byte [edi], '0' ; Ajouter un zéro devant
  mov [edi+1], al ; Stocker le chiffre

age_stored:
 ; Incrémenter le compteur de personnes
  inc dword [person_count]
  jmp debut

input_error:
  jmp debut


lister:
 ; Afficher en-tête 
  mov ecx, msg_list
  mov edx, len_list
 call afficher

 ; Vérifier si vide 
  mov eax, [person_count]
  and eax, eax ; Remplace test 
  mov ebx, done_listing
  mov edx, init_listing
  je skip_init 
  mov ebx, edx
skip_init:
  jmp ebx

init_listing:
 ; Initialisation de esi et ecx
  mov esi, personnel
  xor ecx, ecx

list_loop:
 
  push ecx
  push esi

 ; 1. Afficher ID
  mov ecx, esi
  mov edx, 2
 call afficher

 ; Afficher espace
  mov ecx, space
  mov edx, 1
 call afficher

 ; 2. Afficher Nom
  mov ecx, esi
  add ecx, 2
  push ecx
  xor edx, edx

count_name_chars:
 ; Boucle avec instructions autorisées
  cmp edx, 30
  jae print_name 
  mov al, [ecx+edx]
  cmp al, ' '
  je print_name 
  inc edx
  jmp count_name_chars 

print_name:
  pop ecx
 call afficher

 ; Afficher espace
  mov ecx, space
  mov edx, 1
 call afficher

 ; 3. Afficher Âge
  mov ecx, esi
  add ecx, 32
  mov edx, 2
 call afficher

 ; Nouvelle ligne
  mov ecx, newline
  mov edx, 1
 call afficher

 ; Restaurer contexte
  pop esi
  pop ecx
  add esi, 34
  inc ecx

 ; Condition de boucle finale
  cmp ecx, [person_count]
  jb list_loop 

done_listing:
  jmp debut

supprimer:
 ; Vérifier si vide
  cmp dword [person_count], 0
  je empty

 ; Afficher message demande ID
  mov ecx, del_msg
  mov edx, del_len
 call afficher
 
 call afficher_tous_ids
 
 ; Afficher "): "
  mov ecx, msg_suppression2
  mov edx, len_suppression2
 call afficher
 
 ; Lire ID
  mov ecx, input
  mov edx, 3
 call lire
 
 ; Convertir l'ID saisi
  xor eax, eax       ;eax=0
  mov al, [input]       ;Premier caractère de l'ID
  sub al, '0'           ;Conversion ASCII -> numérique
  cmp byte [input+1], 10;Vérifier si le 2ème caractère est un retour chariot
  je chiffre_unique     ;Si oui, ID à un seul chiffre
 
; Traitement pour ID à deux chiffres
    mov bl, 10            ; Préparer la multiplication par 10
    mul bl                ; AL = AL * 10 (dizaines)
    mov bl, [input+1]     ; Deuxième caractère
    sub bl, '0'           ; Conversion ASCII -> numérique
    add al, bl            ; Ajouter les unités
 
chiffre_unique:
  mov [input_num], al
 
 ; Initialisation pour la recherche
    mov esi, personnel    ; ESI = pointeur source (lecture)
    mov edi, personnel    ; EDI = pointeur destination (écriture)
    mov ecx, [person_count] ; Nombre de personnes à traiter
    xor ebx, ebx          ; EBX = nouveau compteur de personnes (après suppression)
    xor edx, edx          ; EDX = flag de recherche (0: non trouvé, 1: trouvé)


boucle_suppression:
  ; Convertir l'ID stocké (2 chiffres ASCII) en nombre
    xor eax, eax          ; RAZ de EAX
    mov al, [esi]         ; Premier chiffre ASCII
    sub al, '0'           ; Conversion en numérique
    imul eax, 10          ; Multiplier par 10 pour les dizaines
    mov al, [esi+1]       ; Deuxième chiffre ASCII
    sub al, '0'           ; Conversion en numérique
    add eax, edx          

 
 ; Comparer avec ID saisi
  cmp al, [input_num]
  je element_trouve     ; Si correspondance, sauter
 
 ; Copier l'élément
  push ecx
  mov ecx, person_size
copie_loop:
  mov al, [esi]
  mov [edi], al
  inc esi
  inc edi
 loop copie_loop    ;Répéter pour tous les octets de la structure
  pop ecx           ;Restaurer le compteur principal
  inc ebx           ;Incrémenter le nouveau compteur de personnes
  jmp suivant

element_trouve:
  add esi, person_size
  mov edx, 1 ; Marquer comme trouvé
  jmp suivant

suivant:
 loop boucle_suppression        ; Décrémenter ECX et boucler si > 0
 
 ; Mettre à jour compteur
  mov [person_count], ebx
 
 ; Vérifier si trouvé et afficher message approprié
  cmp edx, 1
  je suppression_reussie
  jmp suppression_invalid

suppression_reussie:
  mov ecx, del_success
  mov edx, del_success_len
 call afficher
  jmp debut

suppression_invalid:
  mov ecx, del_fail
  mov edx, del_fail_len
 call afficher
  jmp debut

afficher_tous_ids:
  pusha
  mov ecx, msg_ids_existants
  mov edx, len_ids_existants
 call afficher
 
  mov esi, personnel
  mov ecx, [person_count]
  and ecx, ecx
  je fin_affichage
 
boucle_affichage:
  push ecx
  mov ecx, esi
  mov edx, 2
 call afficher
 
  mov ecx, espace
  mov edx, 1
 call afficher
 
  add esi, person_size
  pop ecx
 loop boucle_affichage

fin_affichage:
  popa
  ret
  
min_max:
 ; vérifier si vide
  cmp dword [person_count], 0
  je empty

 ; Initialisation
  mov word [max_id], '00'
  mov word [min_id], '00'
  mov esi, personnel
 
 ;première personne comme réfirence
  mov al, [esi+32]
  mov bl, [esi+33]
 call convert_age_to_number
  mov [max_age], ax
  mov [min_age], ax
  mov ax, [esi]
  mov [max_id], ax
  mov [min_id], ax

 ; si une seule personne
  mov ecx, [person_count]
  dec ecx
  jz display_results
 
  add esi, person_size

find_age_loop:
  mov al, [esi+32]      ;Premier chiffre d'âge
  mov bl, [esi+33]      ;Deuxième chiffre d'âge
 call convert_age_to_number ;Conversion en AX

 ; Comparer avec l'âge maximum
    cmp ax, [max_age]
    jle not_older            ; Si <= max_age, sauter
    mov [max_age], ax        ; Sinon, nouveau max_age
    mov ax, [esi]            ; Charger l'ID
    mov [max_id], ax         ; Mettre à jour max_id
not_older:
 
; Comparer avec l'âge minimum
    cmp ax, [min_age]
    jge not_younger          ; Si >= min_age, sauter
    mov [min_age], ax        ; Sinon, nouveau min_age
    mov ax, [esi]            ; Charger l'ID
    mov [min_id], ax         ; Mettre à jour min_id
not_younger:
 
; Passer à la personne suivante
    add esi, person_size     ; Avancer dans le tableau
    loop find_age_loop       ; Boucler jusqu'à ce que ECX = 0

display_results:
 ; Display header
  mov ecx, result_msg
  mov edx, result_msg_len
 call afficher

 ; Oldest
  mov ecx, oldest_msg
  mov edx, oldest_msg_len
 call afficher

 ; Find oldest person
  mov esi, personnel
  mov ecx, [person_count]
find_oldest:
  mov ax, [esi]
  cmp ax, [max_id]
  je display_oldest
  add esi, person_size
 loop find_oldest

display_oldest:
 ; Display ID + name (until first space) + age
  push ecx
  push esi
 
 ; Display ID (2 bytes)
  mov ecx, esi
  mov edx, 2
 call afficher
 
 ; Space after ID
  mov ecx, space
  mov edx, 1
 call afficher
 
 ; Display name (until first space)
  mov edi, esi
  add edi, 2 ; Pointer to name start
  mov ecx, 30 ; Max name length
 
print_name_oldest:
  mov al, [edi]
  cmp al, ' '
  je print_age_oldest
 ; Display character
  push ecx
  mov ecx, edi
  mov edx, 1
 call afficher
  pop ecx
  inc edi
 loop print_name_oldest

print_age_oldest:
 ; Space before age
  mov ecx, space
  mov edx, 1
 call afficher
 
 ; Age (2 bytes)
  mov ecx, esi
  add ecx, 32
  mov edx, 2
 call afficher
 
 ; Newline
  mov ecx, newline
  mov edx, 1
 call afficher
 
  pop esi
  pop ecx

 ; Youngest
  mov ecx, youngest_msg
  mov edx, youngest_msg_len
 call afficher

 ; Find youngest person
  mov esi, personnel
  mov ecx, [person_count]
find_youngest:
    mov ax, [esi]            ; Charger l'ID
    cmp ax, [min_id]         ; Comparer avec min_id
    je display_youngest      ; Si égal, trouvé
    add esi, person_size     ; Sinon, personne suivante
    loop find_youngest       ; Continuer
display_youngest:
 ; Display ID + name (until first space) + age
  push ecx
  push esi
 
 ; Display ID (2 bytes)
  mov ecx, esi
  mov edx, 2
 call afficher
 
 ; Space after ID
  mov ecx, space
  mov edx, 1
 call afficher
 
 ; Display name (until first space)
  mov edi, esi
  add edi, 2 ; Pointer to name start
  mov ecx, 30 ; Max name length
 
print_name_youngest:
  mov al, [edi]
  cmp al, ' '
  je print_age_youngest
 ; Display character
  push ecx
  mov ecx, edi
  mov edx, 1
 call afficher
  pop ecx
  inc edi
 loop print_name_youngest

print_age_youngest:
 ; Space before age
  mov ecx, space
  mov edx, 1
 call afficher
 
 ; Age (2 bytes)
  mov ecx, esi
  add ecx, 32
  mov edx, 2
 call afficher
 
 ; Newline
  mov ecx, newline
  mov edx, 1
 call afficher
 
  pop esi
  pop ecx

  jmp debut



convert_age_to_number:
    sub al, '0'           ; Convertir premier chiffre
    cmp bl, ' '           ; Deuxième caractère est-il un espace?
    je single_digit_age_1  ; Si oui, âge à un chiffre
    sub bl, '0'           ; Convertir deuxième chiffre
    mov ah, 10            
    mul ah                ; AL = premier_chiffre * 10
    add al, bl            ; Ajouter deuxième chiffre
    
single_digit_age_1:
  ret

moyenne:
 ; Vérification liste vide
  cmp dword [person_count], 0
  je empty

 ; Initialisation somme
  mov dword [S], 0
  mov esi, personnel
  mov ecx, [person_count]

sum_loop:
 ;Conversion âge ASCII (2 caractères) -> valeur numérique
    mov al, [esi+32]         ; Premier chiffre ASCII
    sub al, '0'              ; Conversion en valeur numérique
    cmp byte [esi+33], ' '   ; Vérifier si 2ème caractère est espace
    je single_digit          ; => âge à 1 chiffre
    cmp byte [esi+33], 10    ; Vérifier si 2ème caractère est retour chariot
    je single_digit          ; => âge à 1 chiffre
 ; Cas âge à 2 chiffres
    mov bl, [esi+33]         ; Deuxième chiffre ASCII
    sub bl, '0'              ; Conversion en valeur numérique
    mov dl, 10
    mul dl                   ; AL = premier_chiffre * 10
    add al, bl               ; AL = premier_chiffre*10 + deuxième_chiffre
single_digit:
    ; Ajouter l'âge converti à la somme totale
    add [S], al
    ; Passer à la personne suivante
    add esi, person_size
    loop sum_loop            ; Répéter pour toutes les personnes

 ; Calcul de la moyenne (partie entière et décimale)
    mov eax, [S]             ; Charger la somme totale
    xor edx, edx             ; EDX:EAX = dividende
    div dword [person_count] ; Division par nombre de personnes
    mov [int_part], eax      ; Stocker partie entière (quotient)
    
    ; Calcul partie décimale (2 chiffres)
    mov eax, edx             ; Reste de la division
    mov ecx, 100
    mul ecx                  ; Multiplier par 100 pour avoir 2 décimales
    div dword [person_count] ; Re-diviser
    mov [dec_part], eax      ; Stocker partie décimale (0-99)

 ; Affichage "Moyenne: "
    mov ecx, moyenne_msg
    mov edx, moyenne_msg_len
    call afficher

 ; Affichage partie entière (méthode alternative)
  mov eax, [int_part]
  mov ebx, 10
  mov edi, int_str+11 ; Buffer dans section data
  mov byte [edi], 0 ; Fin de chaîne

convert_int:
    dec edi                  ; Avancer dans le buffer
    xor edx, edx             ; edx=0
    div ebx                  ; Diviser par 10
    add dl, '0'              ; Convertir reste en ASCII
    mov [edi], dl            ; Stocker le chiffre
    cmp eax, 0               ; Vérifier si quotient = 0
    jg convert_int           ; Continuer si > 0

 ; Affichage partie entière
    mov ecx, edi             ; Adresse du début du nombre
    mov edx, int_str+12      ; Calcul longueur
    sub edx, edi             ; EDX = longueur
    call afficher

 ; Affichage point décimal
    mov ecx, point
    mov edx, 1
    call afficher

 ; Affichage décimale
    mov eax, [dec_part]      ; Charger décimale (0-99)
    mov bl, 10
    div bl                   ; AL = dizaines, AH = unités
    add al, '0'              ; Convertir en ASCII
    mov [dec_str], al        ; Stocker dizaine
    mov ecx, dec_str
    mov edx, 1
    call afficher

 ; Affichage des âges
  mov ecx, msg_ages
  mov edx, len_ages
  call afficher

  mov esi, personnel       ; Reinitialiser pointeur
  xor ebx, ebx             ; Compteur = 0

ages_loop:
  cmp ebx, 0        ;Premier âge?
  je first_age      ; Pas d'espace avant
  ; Afficher espace séparateur
  mov ecx, space
  mov edx, 1
 call afficher
 
first_age:
  mov ecx, esi
  add ecx, 32
  mov edx, 2
 call afficher

  add esi, person_size
  inc ebx
  cmp ebx, [person_count]
  jl ages_loop

  mov ecx, newline
  mov edx, 1
 call afficher
  jmp debut


quitter:
  mov eax, 4
  mov ebx, 1
  mov ecx, message2
  mov edx,longeur2
  int 80h
  jmp fin

fin:
  mov eax, 1
  mov ebx, 0
  int 80h
