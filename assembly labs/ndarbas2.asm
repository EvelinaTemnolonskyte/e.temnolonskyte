.MODEL SMALL ; kodas dedamas i viena segmenta, o duomenys ir stekas kitame    
.STACK 100h  ; bus paskirta 100h baitu stekui
.DATA        ; programos duomenims apibrezti

errormsg1parameters db "Blogas parametru ivedimas", 0Dh, 0Ah, '$'
errormsgno db "Turi buti ivesti parametrai ", 0Dh, 0Ah, '$'
writtingrules db "Jums reikia ivesti tokius parametrus: ndarbas2 duom1.txt duom2.txt rez.txt, kur duom1.txt ir duom2.txt yra duomenu failai, pirmame pirmas skaicius, antrame - antras , o rez.txt - rezultatu failas.", 0Dh, 0Ah, '$'
warning db " Jeigu Jus ivesite daugiau failu jeigu reikia, tai tekstas po rez.txt bus ignoruojamas", 0Dh, 0Ah, '$'
nofile db "Nepavyko rasti, atidaryti failo", 0Dh, 0Ah, '$'
successmsg db "Sekmingai buvo ivesti parametrai, rezultatas dabar yra rezultatu faile", 0Dh, 0Ah, '$'
tusciasmsg db "Nebuvo rasti du sesioliktainiai skaiciai", 0Dh, 0Ah, '$'    
  
duomFile1   db 100h DUP(0)    ; duomfailo pavadinimas 
duomFile2   db 100h DUP(0) 
rezFile     db 100h DUP(0)   
duomFile1Handle dw 0 ; failo dekriptorius (DW - Define Word) - dokumentu turiniui aprasyti ir informacijai surasti formalizuotosiose informacinese paieskos sistemose.
duomFile2Handle dw 0
rezFileHandle dw 0   
readDuom1FileSize dw 0  
readDuom2FileSize dw 0  
fbuf1 DB 100h DUP(?) ; Skaitymo buferis 
fbuf2 DB 100h DUP(?)   
fbufSum DB 100h DUP(?)   
fbufSumNormal DB 100h DUP(?)


index db 0 
index2 db 0   
one db 0  
plus db 0
resultnumber db 0 
null db 0
  
notHex db "Hex numbers not found$"  
len=$-notHex-1  

.CODE    ; apibrezimas kodo segmenta
start: 

;kitos dvi eilutes susiejame duomenu segmento adresa su jo
;tikroji vieta atmintyje. Taip yra todel, 
;kad inicijuojant programa kodo segmentas ir duomenu segmentas yra tuo paciu adresu atmintyje. 

    mov ax, @data
    mov ds, ax 
    
    mov bx, 81h    ;Konstanta, kuri naudojama prieiti prie parametru
    mov plus, 0 
    mov resultnumber, 0 
    mov null, 0
    
parameterscheck:
    mov ax,es:[bx]  ;ax priskiriama parametro reiksme
    inc bx          ;Padidinamas bx 1, kitam kartui kai bus tikrinamas parametras                    
    cmp al,0Dh                                   
    je noValue                                
    cmp al,' ' 
    je parameterscheck                                                                                                                                                                                                                                                                        
    cmp ax,"?/"  ; jeigu vartotojas uzrasys /?                                   
    je help    
    
jmp noerrors  

noValue:
    lea dx, errormsgno   
    call WritetoScreen
    jmp help 
    
badParameters:
    mov dx,offset errormsg1parameters
    call WritetoScreen       
    jmp help    
    
help:
    lea dx, writtingrules
    call WritetoScreen 
    mov dx, offset warning
    call WritetoScreen 
    call ending
   
    
WritetoScreen PROC                                   
    push ax
    mov ah,09h  ; eilutes isvedimo funkcija
    int 21h
    pop ax
    ret
WritetoScreen ENDP

noerrors:  

    dec bx       ;Jei nustatoma, kad vartotojas ivede kazkokius parametrus, sumazinamas bx 1, kad kita sekcija toliau nagrinetu esanti simboli                                
    mov si,bx    ;Nustatomas atidaromo failo pavadinimo pradzios indeksas                                 
    mov cx,0     ;Ateinanciam LOOP bus naudojamas cx registras, kuris duoda parametro ilgi                               
    CALL nameLength   ;Randama duomenu failo pavadinimo ilgis                        
    cmp al,0Dh        ;Patikrinama, ar nebuvo irasytas tik vienas parametras                           
    je badParameters 
    
WSNEWPARAMETRCHECK1:
    inc bx             ;Padidinamas bx 1 naujo simbolio tikrinimui                           
    mov al,es:[bx]     ;Ikeliamas naujas simbolis i registra al is parametru                         
    cmp al,' '         ;Tikrinama, ar naujas simbolis yra tarpas                          
    je WSNEWPARAMETRCHECK1                       
    cmp al,0Dh             ;Jei al reiksme ne tarpas, tikrinama ar ten enter simbolis                        
    je badParameters    
    
mov dx,0                 ;Registras dx naudojamas '.' simboliui skaiciuoti
jmp getduom1SizeName

badParameters2:
    jmp  badParameters
                                     
getduom1SizeName:
    push bx                                       
    mov bx,cx                                     
    mov al, es:[bx+si-1]     ;I al perkeliamas sekamas simbolis                      
    cmp al,'.'                                    
    je callformatCheck                                      
    jmp continue                                   
    callformatCheck:
        CALL formatCheck                                
    continue:                                      
        push si                                       
        mov si,OFFSET duomFile1  ;I si patalpinama atidaromo dokumento pavadinimo laikymo kintamojo adresas                      
        mov [bx+si-1],al         ;I tam tikra pozicija patalpinama pavadinimo atitinkamas simbolis                     
        pop si                                        
        pop bx                                        
        LOOP getduom1SizeName                     
        cmp dx,0               ;Patikrinama, ar buvo rastas failo tipas                       
        je badParameters
        

mov si,bx          ;Nustatomas antro parametro pradzios indeksas                           
mov cx,0                                      
CALL nameLength  

WSNEWPARAMETRCHECK2: 
    
    inc bx                                        
    mov al,es:[bx]                               
    cmp al,' '                                    
    je WSNEWPARAMETRCHECK2                       
    cmp al,0Dh                                    
    je badParameters2 
    mov dx, 0
    jmp getduom2SizeName

getduom2SizeName:
    push bx                                      
    mov bx,cx                                     
    mov al,es:[bx+si-1]    ;I al perkeliamas sekamas simbolis                        
    cmp al,'.'                                    
    je callformatcheck2                                     
    jmp nope2                                  
    callformatcheck2:
        CALL formatCheck                                
    nope2:                                      
    push si                                       
    mov si,OFFSET duomFile2                      
    mov [bx+si-1],al         ;I tam tikra pozicija patalpinama pavadinimo atitinkamas simbolis                     
    pop si                                        
    pop bx                                        
    LOOP getduom2SizeName                     
    cmp dx,0                                      
    je badParameters2  
    
mov si,bx                                     
mov cx,0                                     
CALL nameLength 

jmp WSNEWPARAMETRCHECK3




WSNEWPARAMETRCHECK3:
    inc bx                                        
    mov al,es:[bx]                                
    cmp al,' '                                    
    je WSNEWPARAMETRCHECK3                        
    cmp al,0Dh                                     
    je badParameters2
    mov dx,0
    jmp getRezFileSizeName  

getRezFileSizeName:
    push bx                                       
    mov bx,cx                                     
    mov al,es:[bx+si-1]                          
    cmp al,'.'                                   
    je callformatcheck3                                     
    jmp nope3                                  
    callformatcheck3:
    CALL formatCheck                                
    nope3:                                      
    push si                                       
    mov si,OFFSET rezFile                       
    mov [bx+si-1],al                             
    pop si                                        
    pop bx                                       
    LOOP getRezFileSizeName                     
    cmp dx,0                                      
    je badParameters3   
    jmp openFile1 

badParameters3:
     jmp badParameters2
                  

nameLength PROC
                              
    next:
        mov al,es:[bx]                                
        cmp al,' '                                   
        je done                                 
        cmp al,0Dh                                    
        je done                                  
        inc bx                                        
        inc cx                                        
        jmp next                             
    done:
        ret
nameLength ENDP 

formatCheck PROC              ;Funkcija, skirta patikrinti, ar failas turi pavadinima ir tipa
    mov al, es:[bx+si]        ;Paimamas uz '.' simbolio esantis simbolis
    cmp al, 0Dh               
    je  badParameters3
    cmp al, ' '   
    je  badParameters3
    cmp dx,0                ;Kadangi failas turi tipa, patikrinama, ar analizuojamas '.' simbolis rastas pirma karta                        
    je nameCheck            ;Jei '.' rastas pirma karta, tikrinama ar failas turi ir pavadinima                                                    
    jmp nextOne             ;Jei '.' rastas ne pirma karta, grazinamas simbolis ivedimui i kintamaji  
    nameCheck:                                  
        mov al,es:[bx+si-2]   ;Paimamas pirmas simbolis pries '.' simboli                      
        cmp al,' '                                    
        je  badParameters3                       
    nextOne:
        inc dx                 ;Registras dx padidinamas 1 ir nurodo, kad rastas +1 '.' simbolis                         
        mov al,es:[bx+si-1]    ;I registra al grazinamas '.' simbolis, kuris buvo tikrinamas                       
        ret
formatCheck ENDP

openFile1:
    mov dx,offset duomFile1   ;I dx perkeliamas pirmo duomenu failo pavadinimas
    mov ax,3D00h              ;Failo atidarymas
    int 21h 
    mov si, offset duomFile1   ;I si perkeliamas atidaromo failo pavadinimas klaidos atveju
    jc openFileError2          ;Patikrinama ar failas neatsidare
    mov [duomFile1Handle],ax   ;Jei failas atsidare, issaugojamas bylos deskriptorius
    jmp openFile2

openFile2:
    mov dx,offset duomFile2
    mov ax,3D00h                
    int 21h 
    mov si, offset duomFile2
    jc openFileError2          ; Jump near if carry (CF=1)
    mov [duomFile2Handle],ax  
    jmp createRezFile

createRezFile:
    
    mov dx,OFFSET rezFile                       
    mov ah,3Ch                ;Sukurimo funkcija                    
    mov cx,0                  ;Failas sukuriamas paprastai, be papildomu daliu                   
    int 21h                                       
    mov si,OFFSET rezFile                       
    jc openFileError2                          
    mov [rezFileHandle],ax    ;Jei sekmingai sukurtas failas, sukurtos bylos deskriptorius irasomas i kintamaji                     
    jmp readFile1                                  
   
openfileError2:
       call openFileError

readFile1:
    mov ah,3Fh                 ;Failo skaitymo funkcija                   
    mov bx,[duomFile1Handle]   ;I bx perkeliama skaitomo failo bylos deskriptorius
    push bx                        
    mov cx,100h                ;Irasoma, kiek simboliu bandys perskaityti failas (512)                  
    mov dx,OFFSET fbuf1        ;Irasomas bufferio pavadinimas i kuri bus rasomas failas                 
    int 21h                                       
    jc  close                  ;Jei nebegalima skaityti failo, failai uzdaromi
    or ax, ax                  ;Patikrinama, ar neperskaityta 0 simboliu
    jz tuscias
    mov [readDuom1FileSize], ax ;Issaugoma, kiek failo yra perskaityta
    mov cx, ax 
    mov index,cl
    jmp readFile2

tuscias:
    mov dx, offset tusciasmsg
    call WriteToScreen
    
ending1:
    call ending
close:
    mov bx, [duomFile1Handle]     ; i bx skaitomo(duomenu 1) failo deskriptorius
    or bx, bx                     ;Patikrinama, ar skaitomos bylos deskriptorius nelygus 0
    jz  ending1                   ;Jei deskriptorius lygus 0, baigiamas darbas
    mov ah, 3Eh                   ;Failo uzdarymas
    int 21h                       

readFile2:
    mov ah,3Fh                                    
    mov bx,[duomFile2Handle]   
    push bx                      
    mov cx,100h                                  
    mov dx,OFFSET fbuf2                         
    int 21h                                       
    jc  close2 
    or ax, ax
    jz tuscias 
    mov [readDuom2FileSize], ax
    mov cx, ax
    mov index2, cl
    
    
close2:
    mov bx, [duomFile2Handle]  
    or bx, bx
    jz  ending1
    mov ah, 3Eh
    int 21h 
    jmp check 

check:
    mov si, 0 
    mov cl, index 
    ciklas:
    mov bl, fbuf1[si]  
    cmp bl, '0'
    jb notNumber 
    cmp bl, 'F'
    ja notNumber
    cmp bl, '9'
    jbe ok
    cmp bl, 'A'
    jae ok
    ok:
        inc si   
        cmp si, cx 
        jb ciklas 
        jmp check2
       
NotNumber: 
    mov cx, len
    mov bx, [rezFileHandle]
    mov ah, 40h  
    mov dx, offset notHex
    int 21h 
    mov dx, offset successmsg  
            call WritetoScreen
    jmp ending1   

check2:
    mov si, 0 
    mov cl, index2 
    ciklas2:
    mov bl, fbuf2[si]  
    cmp bl, '0'
    jb notNumber 
    cmp bl, 'F'
    ja notNumber
    cmp bl, '9'
    jbe ok2
    cmp bl, 'A'
    jae ok2
    ok2:
        inc si   
        cmp si, cx 
        jb ciklas2  
        mov dl, index
        mov cl, index2
        cmp dl, cl
        jae countsum
        cmp dl, cl 
        jb secondSum
        
countsum: 
    mov one, 0
    mov si, 0 
    mov di, 0 
    mov cl, index 
    mov dx, 0
    mov dl, index2
   
    
    
sumHex:
    dec cx
    cmp null, 0
    je decdx
    jmp skip
    decdx:
    dec dx 
    skip: 
    cmp dh, 255
    je dxnull  
    jmp c1
    dxnull: 
    mov null, dl
    mov dl, index2 
    mov dh, 0
    jmp c1
  
secondSum:
    jmp SecondSum2   
    
     
c1:
    mov si, cx
    push dx    
    mov bl, fbuf1[si] 
    mov si, dx 
    mov al, bl
    cmp al, 0 
    je cont 
    cmp al, 'A'
    jae letter 
    jmp number
    letter: 
        sub al, 55 
        jmp cont 
    number:
        sub al, 48
        jmp cont  
    cont:
        mov bl, fbuf2[si] 
        cmp bl, 0
        je sum
        cmp bl, 'A'
        jae letter2
        jmp number2
    letter2:
        sub bl, 55
        jmp sum 
sumHex4:
    jmp sumHex
    
    number2:   
        sub bl, 48  
        jmp sum
    sum:
        mov dx, 0   
        push dx
        mov dl, plus
        mov si, dx
        inc plus
        pop dx 
        add dx, ax
        add dx, bx
        add dl, one 
        cmp dl, 10h
        jae change
        jmp nochange

secondSum2:
    jmp secondSum3        
  
    change:
        sub dl,16   
        mov one, 1  
        mov bl, dl
        mov fbufSum[si], bl
        inc resultnumber 
        jmp go
        
    nochange:  
        mov one, 0
        mov bl, dl
        mov fbufSum[si], bl 
        inc resultnumber
        jmp go
    go:  
        pop dx 
        cmp cx, 0h
        je plusone  
        jmp sumHex4
            
plusone:
   mov dx, 0  
   mov cx, 0
   mov dl, one 
   mov cl, resultNumber 
   mov bx, 0
   mov bl, resultNumber
   mov si, cx   
   cmp si, bx
  ; je CheckForZero
   ;jmp n
  ; CheckForZero:
   ;cmp dl, 0 
   ;je ChangeZ 
   ;jmp n
   ;ChangeZ:
   ;mov dl, 0
   n:
   mov fbufSum[si], dl
   call changeToASCII 
   
changeToASCII proc
    mov cx, 0 
    mov cl, resultNumber 
ASCIIcycle:
    mov si, cx  
    mov bl,fbufSum[si] 
   ; cmp si, cx  
   ; je ZeroNULL 
   ; jmp @n
   ; ZeroNULL:
    ;cmp bx, 0
   ; je KeepZero
    @n:
    cmp bx, 9
    ja letterASCII
    jmp numberASCII
    letterASCII: 
        add bx, 55
        mov fbufSum[si], bl
        dec cx 
        jmp compaireCx
    numberASCII:
        add bx, 48 
        mov fbufSum[si], bl 
        dec cx 
        jmp compaireCx  
   ; KeepZero:
       ; dec cx
    compaireCx:
        cmp ch, 255
        je ReverseNumber 
        jmp ASCIIcycle
                
         ret
changeToASCII endp   

ReverseNumber:
   mov dx, 0 
   mov si, 0 
   mov cx, 0 
   mov cl, resultNumber 
   push si
getNormalNum:
   mov si, cx  
   mov bl, fbufSum[si]  
   pop si
   mov fbufSumNormal[si], bl
   inc si
   push si
   dec cx
   cmp ch, 255
   je resultFound  
   jmp getNormalNum 
   
secondSum3:
    jmp countsum2
    
   resultFound:
        call printTheResult
        
printTheResult proc
    mov cx, 0
    mov cl, resultNumber
    inc cl
    mov ah, 40h       ;  isvedimas i faila
    mov bx, [rezFileHandle] 
    mov dx, offset fbufSumNormal
    int 21h 
    call closeRezFile
    
printTheResult endp
   
closeRezFile proc 
    mov bx, [rezFileHandle]  
    or bx, bx  ;Patikrinama, ar skaitomos bylos deskriptorius nelygus 0
    jz success 
      success:
            mov dx, offset successmsg  
            call WritetoScreen
            call ending  
    mov ah, 3Eh
    int 21h    
closeRezFile endp
  
  
     
countsum2: 
    mov one, 0
    mov si, 0 
    mov di, 0 
    mov cl, index 
    mov dx, 0
    mov dl, index2
    
sumHex2:
    dec dx 
    cmp null, 0
    je deccx 
    jmp skip2
    deccx:
    dec cx
    skip2:
    cmp ch, 255
    je cxnull  
    jmp c2
    cxnull:
    mov null, cl
    mov cl, index 
    mov ch, 0
    jmp c2 
c2:
    mov si, cx     
    push dx
    mov bl, fbuf1[si] 
    mov si, dx 
    mov al, bl 
    cmp al, 0
    je cont2 
    cmp al, 'A'
    jae letter3 
    jmp number3
    letter3: 
        sub al, 55 
        jmp cont2 
    number3:
        sub al, 48
        jmp cont2 
sumHex3:
    jmp sumHex2
     
    cont2:
        mov bl, fbuf2[si]  
        cmp bl, 0
        je sum2
        cmp bl, 'A'
        jae letter4
        jmp number4
    letter4:
        sub bl, 55
        jmp sum2
    
    number4:   
        sub bl, 48  
        jmp sum2
    sum2:
        mov dx, 0   
        push dx
        mov dl, plus
        mov si, dx
        inc plus
        pop dx 
        add dx, ax
        add dx, bx
        add dl, one 
        cmp dl, 10h
        jae change2
        jmp nochange2
    
    change2:
        sub dl, 16   
        mov one, 1  
        mov bl, dl
        mov fbufSum[si], bl
        inc resultnumber 
        jmp go2
    nochange2:
        mov one, 0
        mov bl, dl
        mov fbufSum[si], bl 
        inc resultnumber
        jmp go2
    go2:  
        pop dx
        cmp dx, 0h
        je plusone2 
        jmp sumHex3  
        
     
plusone2:
   mov dx, 0  
   mov cx, 0
   mov dl, one
   mov cl, resultNumber
   mov bx, 0
   mov bl, resultNumber
   mov si, cx 
   cmp si, bx
   je CheckForZero2
   jmp n2
   CheckForZero2:
   cmp dl, 0
   je ChangeZ2
   ChangeZ2:
   mov dl, 0
   n2:
   mov fbufSum[si], dl
   call changeToASCII 
   
     
openFileError proc                      
    mov dx, offset nofile
    call WritetoScreen  
    lea dx, writtingrules
    call WritetoScreen 
    mov dx, offset warning
    call WritetoScreen 
    jmp ending  
openFileError endp  
    


ending proc     
    mov ax, 4C00h
    int 21h 
ending endp
    

      
      
    
end start
    
       
    



