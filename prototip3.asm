
; Standard header:
	#make_COM#
        ORG  100H  
        

START:  

;--time operations
    call show_time  ; display curr time
    mov ah,9
    lea dx,promt    ; show prompt to enter the new time
    int 21h
    lea si,hour     ; read hours

    call input      ; 
    cmp cl,0ffh     ; if error
    jz endtime      ; stop enter time

    mov dl,':'      ; add ":" after hours
    mov ah,2
    int 21h
    lea si,min      ; read mins
    call input
    mov ch,[hour]
    cmp ch,23h      ; if hours not more than 23
    jg  errortime   ; if more - display error
    mov cl,[min]    ; if mins not more than 59
    cmp cl,59h
    jg  errortime   ; if more - display error
    mov ah,03
    int 1ah         ; setup new time

    call show_time  ; display curr time
endtime:
;--date operations
    call show_date  ; display curr date
    mov ah,9
    lea dx,promt2   ; show prompt to enter the new date
    int 21h
    lea si,day      ; read date
    call input
    cmp cl,0ffh     ; if error
    jz enddate      ; close program
    mov dl,'.'      ; add "." as separator
    mov ah,2
    int 21h
    lea si,month    ; read month
    call input
    cmp cl,0ffh     ; if error
    jz enddate      ; close program
    mov dl,'.'      ; add "." as separator
    mov ah,2
    int 21h
    lea si,century  ; read century
    call input
    cmp cl,0ffh     ; if error - close program
    jz enddate
    lea si,year     ; read year, without separator
    call input
    mov dh,[month]
    cmp dh,12h      ; if month more than 12
    jg  errortime   ; close program
    mov dl,[day]
    cmp dl,31h      ; if days more than 31
    jg  errortime   ; close program
    mov ch,[century]    ; load century in ch
    mov cl,[year]       ; load year in cl
    mov ah,5
    int 1ah         ; setup new date
    call show_date  ; display the new date
enddate:
    ret

errortime:  ; if time/date was entered incorect then show error msg
    lea dx,ertime
    mov ah,9
    int 21h 
    ret     ; and close program

;---input proc. Entered number stored in [si] (in BCD format).
input:
    mov cx,2    ; enter 2 symbols
    mov bx,0    ; number will be created in bx
inhour:
    mov ah,01h
    int 21h     ; get 1 symbol
    cmp al,':'  ; if ":"
    jz endhour
    cmp al,'.'  ; or "."
    jz endhour
    cmp al,2fH  ; if was pressed enter, backspace etc.
    jl endinput
    cmp al,3AH  ; if was entered not number
    jg endinput ; 
    xor ah,ah   ; if all good, then clear ah
    sub al,30h  ; convert symbol to num
    xchg bx,ax  ; ax = bx, bx = ax
    mov dl,10h
    mul dl      ; 
    add bl,al   ; 
    mov [si],bl ; save number in [si]
    loop inhour ;
endhour:
    ret ; close program

endinput:
    mov cl,0ffh ; if error while input
    ret         ; close program

;---display curr time 
show_time:
    mov ah,2
    int 1ah     ; get curr time
    xor ah,ah
    mov bl,10h
    mov al,ch
    mov [hour],ch   ; 
    div bl          ; div by 10h
    add ax,'00'     ;
    mov word ptr [hourp],ax ; 
    xor ah,ah       ;
    mov al,cl
    mov [min],cl    ; 
    div bl          ; div by 10h
    add ax,'00'     ; 
    mov word ptr [minp],ax  ; 
    xor ah,ah
    mov al,dh
    div bl          ; div by 10h
    add ax,'00'     ; 
    mov word ptr [secp],ax
    mov ah,9
    lea dx,msg      ; show curr time msg
    int 21h
ret


;---display curr date
show_date:
    mov ah,04
    int 1ah         ; get curr date  
    xor ah,ah
    mov bl,10h
    mov al,ch
    mov [century],ch    ; 
    div bl      ; div by 10h
    add ax,'00' ; 
    mov word ptr [centuryp],ax  ; 
    xor ah,ah
    mov al,cl
    mov [year],cl
    div bl      ; div by 10h
    add ax,'00' ; 
    mov word ptr [yearp],ax
    xor ah,ah
    mov al,dl
    mov [day],dl
    div bl      ; div by 10h
    add ax,'00' ; 
    mov word ptr [dayp],ax
    xor ah,ah
    mov al,dh
    mov [month],dh
    div bl      ; div by 10h
    add ax,'00'     
    mov word ptr [monthp],ax

    mov ah,9
    lea dx,msg2     ; display curr date msg
    int 21h
    ret

msg     db 0dh,0ah,'Now time is ';  \
hourp   db '00:';                   curr time msg
minp    db '00:';                   /
secp    db '00',0dh,0ah,'$'
promt   db 'Please enter new time in format HH:MM',0dh,0ah,'$' ; enter new time msg
promt2  db 'Please enter new date in format DD.MM.YYYY',0dh,0ah,'$' ; enter new date msg
ertime  db 0dh,0ah,'Error in format time or date$' ; error msg
msg2    db 0dh,0ah,'Now date is ';  \
dayp    db '00.';                   
monthp  db '00.';                   curr date msg
centuryp    db '00';
yearp   db '00',0dh,0ah,'$';        /
hour    db ? ; vars to store hours, mins, century, year, month, day
min     db ?
century db ?
year    db ?
month   db ?
day     db ?

end start

; Print using DOS interrupt:
        MOV AH, 9
        INT 21h

; Exit to operating system:
        MOV AH, 4Ch
        INT 21h
