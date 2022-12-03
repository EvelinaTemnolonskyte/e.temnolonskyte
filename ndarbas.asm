;16 uzd hex to decimal (max dec= 65535 = FFFFh)
.model small ; kodas dedamas i viena segmenta, o duomenys ir stekas kitame
.stack 100h  ; bus paskirta 100h baitu stekui
.data    ; programos duomenims apibrezti

message1 db 10,13,'Iveskite skaiciu 16 sistemoje: $' ; pranesimas1
message2 db 10,13,'Desimtaineje sistemoje tai:$'
message3 db 10,13,'Neteisingas ivedimas skaitmenis turi buti 0-9 arba A-F$'

hex  db  5,?,5 dup(?) ; db 5 maksimalus ilgis, db ? ilgis vartotojo ivestas, db 5 dup(?) ielutes simboliai + enter pabaigoje 
buffer  db 6 dup('$') ;rezultatas gali tureti 5 skaitmenu (digits)  
count db ?

.code ; apibrezimas kodo segmenta
  
;kitos dvi eilutes susiejame duomenu segmento adresa su jo
;tikroji vieta atmintyje. Taip yra todel, 
;kad inicijuojant programa kodo segmentas ir duomenu segmentas yra tuo paciu adresu atmintyje.                      
  mov  ax, @data
  mov  ds, ax

start:

;Atspausdina message 1:
  mov  ah, 9     ;eilutes isvedimo DOS funkcija
  lea  dx, message1 ;  kitas variantas mov dx, offset message1   nurodo i message1 
  int  21h  ; isvedamas pranesimas

;Ima sesioliktaini skaiciu kaip stringa
  mov  ah, 0ah  ;  eilutes ivedimui is klaviaturos.       
  lea  dx, hex  ; i dx irasomas eilutes adresas
  int  21h

; konvertacija stringo sesioliktainio i skaiciu
  lea  si, hex+2        ;simboliai hex-stringo (nukreipia i pirma ivesta simboli).
  mov  bh, [si-1]       ;antras baitas - ilgis, BH=skaicius ivestu skaitmenu 
  call hex2number       ;skaicius grizta i ax 

;konvertuoti skaiciu i desimtaini pavydala kaip stringa 
  lea  si, buffer
  call number2string    ;stringas grizta i si <buffer> 

;Isvedimas message 2
  mov  ah, 9
  lea  dx, message2
  int  21h            

;isvesti skaiciu kaip stringas
  mov  ah, 9
  lea  dx, buffer
  int  21h     ; DOS funkcijos iskvietimas.

  mov dl, count
  add dl, 30h
  mov ah, 2
  
  int 21h 

;programos baigimas 
  mov  ax, 4c00h   ; DOS baigimo funkcija
  int  21h       ;

;---------------------------------------------  
;Uzpildyti "BUFFER" su "$".
 
;INPUT  : BH = stringo ilgis gali buti (1,4).

;OUTPUT : AX = skaicius
  
  
;PROC ir ENDP yra kompiliatoriaus direktyvos, nurodancios kompiliatoriu i proceduros adresa
;Tarp siu zodziu yra proceduros kodas.
hex2number proc  
      MOV  AX, 0       ;skaicius
   Ciclo:
; RANKINIU BUDU 4 KARTUS PASTUMSIME KAIREN AL IR AH, KAD IMULIUOTUME SHL AX,4.
      shl  al, 1
      rcl  ah, 1
      shl  al, 1
      rcl  ah, 1
      shl  al, 1
      rcl  ah, 1
      shl  al, 1
      rcl  ah, 1



      MOV  BL, [ SI ]  ;gauti viena hex simboli is stringo 

      call validate

      CMP  BL, 'A'     ;BL = 'A'..'F' : Raide
      JAE  letterAF    ;BL = '0'..'9' : Skaitmuo.  JAE - JUMP IF ABOVE OR EQUAL
   ;CharIsDigit09.
      SUB  BL, 48      ;konvertuoti skaitmeni i skaiciu  48 = 30h
      JMP  continue   
   letterAF:               
      SUB  BL, 55      ;konvertuoti raide i skaiciu     55 = 37h
   continue: 
      OR   AL, BL      ;CLEAR UPPER 4 BITS.
      INC  SI          ;kitas hex simbolis 
      DEC  BH          ;DEC instrukcija sumazina skaiciu vienetu
      ;BH == 0 : baigti
      JNZ  Ciclo       ;BH != 0 : kartuoti.
   Fin:
      RET  ; i 39 eilute
      
;RET - komanda, kuri naudojama grizti i operacine sistema, jei ji vykdoma programoje.
; Jei ji yra proceduroje, tada ji naudojamas norint grizti i pagrindine programa is proceduros.
hex2number endp




validate proc
    cmp bl, '0'
    jb  error     ;jeigu BL < '0'
    cmp bl, 'F'
    ja  error     ;jeigu BL > 'F'
    cmp bl, '9'
    jbe ok        ;jeigu BL <= '9'
    cmp bl, 'A'
    jae ok        ;jeigu BL >= 'A'
error:    
    pop  ax ; Isimti operanda is steko:      
    pop  ax       

;Isvesti message 3
    mov  ah, 9
    lea  dx, message3
    int  21h
   
ok:    
    ret    ;  87 eilute 
validate endp


;AX = skaicius, kuris bus konvertuojams i desimtaini skaiciu 
;SI = offsetine eilute
;Iskirti skaitmenis vienas nuo kito, issaugoti steke, isaugoti atvirksciai

;sugrazinti tvarka

number2string proc 
  mov  bx, 10 ;
  mov  cx, 0 ;skaiciuoti kiek skaitmenu isskirta
cycle1:       
  mov  dx, 0 
  div  bx ; DX:AX / 10 = AX:op DL-liekana.
  push dx ;ISSAUGOTI SKAITMENYS, ISTRAUKTI VELIAU , steke
  inc  cx ;Vienetu padidinti   
  mov count, cl
  
  cmp  ax, 0  ;Jeigu skaicius nera nulis, ciklas tesiamas
  jne  cycle1  
; kad gautum skaitmenis 
  lea  si, buffer   

cycle2:  
  pop  dx        
  add  dl, 48 ;konvertuoti skaitmenis i simboli  ; +30h
  mov  [ si ], dl  ; si naudojamas kaip zymeklis i atminties vieta, jau i bufferi irasys
  inc  si
  loop cycle2                                                                                                                     

  ret
number2string endp  



end