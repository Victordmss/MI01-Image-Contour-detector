.file "process.S"
.intel_syntax noprefix

.text

/***********************************************************************
            Largeur de l'image : rdi
            Hauteur de l'image : rsi
            Pointeur sur l'image source : rdx
            Pointeur sur l'image tampon 1 : rcx
            Pointeur sur l'image tampon 2 : r8
            Pointeur sur l'image finale : r9
  
  Les registes rbx, rbp, r12, r13, r14, et r15 doivent être sauvegardés
  par l'appelé. Les autres registres peuvent être modifiés sans risque.
***********************************************************************/

.global process
process:
	push    rbp
	mov     rbp, rsp
	push rbx		//On utilise ebx, on sauvegarde donc le registre
	push r15
	push r14
	push r12
	push r13
	push    rdi           	//Sauvegarde de la largeur de l'image
	imul    rdi, rsi      	//rdi <- largeur x hauteur
//Niveau de gris
loop_gs:
	mov eax, [rdx+4*rdi] 	//Adresse du pixel traité
	xor r11d, r11d

	mov ebx, eax 		//On copie le pixel pour le traiter plusieurs fois
	and ebx, 0x000000ff  	//Masque de rouge
	imul ebx, 0x36	     	//Multiplication par le coefficient correspondant
	add r11d, ebx		//Stockage de la valeur dans le registre rbx

	mov ebx, eax 		//On copie le pixel pour le traiter plusieurs fois
	and ebx, 0x0000ff00  	//Masque de vert
	shr ebx, 8		//Décalage pour traitement
	imul ebx, 0xB7       	//Multiplication par le coefficient correspondant
	add r11d, ebx		//Addition de la valeur dans le registre rbx

	mov ebx, eax 		//On copie le pixel pour le traiter plusieurs fois
	and ebx, 0x00ff0000  	//Masque de bleu
	shr ebx, 16		//Décalage pour traitement
	imul ebx, 0x13	     	//Multiplication par le coefficient correspondant
	add r11d, ebx		//Addition de la valeur dans le registre rbx

	shr r11d, 8		//Décalage pour suppression des 8 bits après la virgule
	//shl r11d, 8		//Filtre d'intensité vert
	//shl r11d, 8		//Filtre d'intensité bleu
	or r11d, 0xff000000	//Masque de transparence
	mov [rcx+4*rdi], r11d	//On enregistre le pixel traité dans l'image tampon 1

	sub     rdi, 1      //Un pixel de moins à traiter
	ja      loop_gs
	pop     rdi         //rdi <- largeur de l'image en pixels



//Filtre de Sobel
	push rcx             //Sauvegarder le pixel pointant sur l'image tampon 2
	lea r11, [rsi-2]     //Nombre de lignes
lignes:
	lea r10, [rdi-2]     //Nombre de colonnes
colonnes:
	//mov dword ptr[rcx], 0xffff00ff
	xor r15, r15 			//M1
	sub r15d, [rcx]			//-a11 M1
	add r15d, [rcx+8]		//+a31 M1
	sub r15d, [rcx+rdi*4]		//-a12 M1
	sub r15d, [rcx+rdi*4]		//-a12 M1
	add r15d, [rcx+rdi*4+8]  	//+a32 M1
	add r15d, [rcx+rdi*4+8]  	//+a32 M1
	sub r15d, [rcx+rdi*4*2]  	//-a13 M1
	add r15d, [rcx+rdi*4*2+8]	//+a33	M1

	xor r14, r14			//M2
	add r14d, [rcx]			//+a11 M2
	add r14d, [rcx+4]		//+a21 M2
	add r14d, [rcx+4]		//+a21 M2
	add r14d, [rcx+8]		//+a31 M2
	sub r14d, [rcx+rdi*4*2]	 	//-a13 M2
	sub r14d, [rcx+rdi*4*2+4] 	//-a23 M2
	sub r14d, [rcx+rdi*4*2+4] 	//-a23 M2
	sub r14d, [rcx+rdi*4*2+8] 	//-a33 M2

	//GX dans r15
	//GY dans r14
	
	mov r12d, r15d
	neg r12d
	cmovns r15d, r12d		//r15d = |Gx|

	mov r12d, r14d
	neg r12d
	cmovns r14d, r12d		//r14d = |Gy|

	add r14d, r15d			//r14d = |Gx| + |Gy| = G
	neg r14d			//r14d = -G
	add r14d, 255			//r14d = 255-G
	mov r12d, 0
	cmp r14d, 0
	cmovl r14d, r12d		//Si 255-G<0 alors r14d = 0

	mov r13d, r14d			//r13d registre cache de G
	shl r14d, 8			//G est appliqué sur la partie V
	add r14d, r13d			//On rajoute G sur la partie R
	shl r14d, 8			//G est appliqué sur la partie B
	add r14d, r13d		    	//On rajoute G sur la partie R
	or r14d, 0xff000000
	mov dword ptr[r8+4*rdi+4], r14d

	add r8, 4
	add rcx, 4
	sub r10, 1              	//Une colonne de moins à traiter
	ja colonnes             	//Traitement de la colonne suivante s'il en reste

	add r8, 8
	add rcx, 8
	sub r11, 1             	//Une ligne de moins à traiter
	ja lignes              	//Traitement de la ligne suivante s'il en reste

	pop rcx




epilogue:   
	pop r13			//Dépiler r13
	pop r12			//Dépiler r12
	pop r14			//Dépiler r14
	pop r15			//Dépiler r15
	pop rbx			//Dépiler rbx
	pop rbp     		//Dépiler le pointeur de cadre de pile sauvegardé
            ret                  
