; multi-segment executable file template.  

new_line macro
    print 0ah       
    print 0dh      ; Carriage return
endm   

print_str macro string 
    mov dx, offset string
    mov ah, 9
    int 21h
endm       

print macro char
    mov dl, char
    mov ah, 2
    int 21h
endm


data segment
    ; add your data here!   
    input db 21 dup(?)      
ends

stack segment
    
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax
    
    ; add your code here 
    
    mov di, offset input
    cld             ; df = 0
    mov cx, 20      ; Μετρητής 
    
again:        
    call read_key   ; Ανάγνωση
    cmp al, '='     ; Πλήκτρο τερματισμού
    je stop     
    cmp al, 0dh     ; Πλήκτρο enter
    je process  
    stosb           ; Αποθήκευση στη μνήμη 
    print al
    
    loop again     
                     
process:            ; Επεξεργασία δεδομένων    
    new_line 
    cld
    mov si, offset input 
    mov cx, 20
again_1:
    lodsb
    call capitalize
    print al       
    loop again_1
        
    
   
stop:
    mov ax, 4c00h   ; exit to operating system.
    int 21h    
ends
  

capitalize proc near
    cmp al, 'a'
    jl cap_end
    cmp al, 'z'
    jg cap_end
    sub al, 32   
cap_end:
    ret
capitalize endp 

; Reads ascii codes of non capitalized letters and numbers 
read_key proc near 
ignore:
    ; Read 
    mov ah, 8
    int 21h
    
    ; Check if exit key pressed
    cmp al, '='
    je exit  
    
    ; Check if enter key was pressed
    cmp al, 0dh
    je exit
                       
    cmp al, 30h
    jl ignore
    
    cmp al, 39h
    jg addr_1
    
    jmp exit
    
addr_1:
    cmp al, 'a'
    jl ignore
    cmp al, 'z'
    jg ignore                      
exit: 
    ret
read_key endp 
  
     
end start ; set entry point and stop the assembler.