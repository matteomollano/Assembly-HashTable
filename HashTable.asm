; Assembly HashTable (HashTable.asm)

; Either include the Irvine libary
INCLUDE Irvine32.inc

; or include the .386 and .model directives
; .386
; .model flat, stdcall

.stack 4096; declare your stack size

; Declare the function prototype for the ExitProcess function
ExitProcess PROTO dwExitCode : DWORD

HT_CREATE PROTO hashSize: DWORD, tableName: PTR BYTE

ComputeHash PROTO ptrKey: PTR BYTE, tableSize: DWORD

HT_INSERT PROTO ptrTable: PTR DWORD, ptrKey: PTR BYTE, ptrValue: PTR BYTE

HT_REMOVE PROTO ptrTable: PTR DWORD, ptrKey: PTR BYTE

RemoveAtHead PROTO bucketAddress: PTR DWORD, nodeAddress: PTR DWORD

RemoveBetween PROTO prevAddress: PTR DWORD, nodeAddress: PTR DWORD

HT_SEARCH PROTO ptrTable: PTR DWORD, ptrSearch: PTR BYTE

HT_PRINT PROTO ptrTable: PTR DWORD

HT_DESTROY PROTO ptrTable: PTR DWORD, HeapHandle: HANDLE

ClearTable PROTO ptrTable: PTR DWORD

GetLoadFactor PROTO ptrTable: PTR DWORD

RehashTable PROTO ptrTable: PTR DWORD

;; /* FOR UI Implementation */
PromptString PROTO ptrString: PTR BYTE

AddToArrays PROTO ptrTable: PTR DWORD, ptrHandle: PTR DWORD


.data

;; /* For HashTable */
HT_CREATE_SUCCESS BYTE "Hash Table created successfully", 0
HT_CREATE_SIZE BYTE "Size of Hash Table: ", 0
hashIndexLabel BYTE "Hash Index", 0
emptySpace BYTE "     ", 0
moreEmptySpace BYTE "             ", 0
pairLabel BYTE "Key:Value Pair", 0
emptyPair BYTE "-----<empty>-----", 0
heading BYTE " Hash Table", 0
numOfElementsString BYTE "Number of Elements: ", 0
tableSizeString BYTE "Table Size: ", 0
loadFactorString BYTE "Load Factor: ", 0
numberOfElements DWORD ?
hashTableSize DWORD ?
colonString BYTE ":", 0
arrow BYTE " -> ", 0
keyNotFound BYTE "Key Not Found!", 0
itemNotFound BYTE "The item you are trying to remove cannot be found", 0
valueFor BYTE "The value for key ", 0
quote BYTE "'", 0
is BYTE " is ", 0
dot BYTE ". ", 0
destroySuccess BYTE "Hash Table successfully destroyed", 0

;; FOR HT_INSERT
currentLoadFactor REAL4 ?
maxLoadFactor REAL4 0.75

;; FOR HT_REMOVE
prev DWORD ?
current DWORD ?
after DWORD ?


;; /* FOR TEST CASES */

;; Avengers
;; 1.
creatingAvengers BYTE "1. Creating Avengers Table...", 0
ptrAvengersTable DWORD ?
avengersHandle HANDLE ?
avengersName BYTE "Avengers", 0

;; 2.
addingKey1 BYTE "2. Adding Thor:Hemsworth...", 0
keyThor BYTE "Thor", 0
valueHemsworth BYTE "Hemsworth", 0

;; 3.
addingKey2 BYTE "3. Adding Ironman:Downey...", 0
keyIronman BYTE "Ironman", 0
valueDowney BYTE "Downey", 0

;; 4.
addingKey3 BYTE "4. Adding Hulk:Ruffalo...", 0
keyHulk BYTE "Hulk", 0
valueRuffalo BYTE "Ruffalo", 0

;; 5.
printingAvengers5 BYTE "5. Printing Avengers...", 0

;; 6.
searchingKey1 BYTE "6. Searching for Ironman...", 0
searchIronman BYTE "Ironman", 0

;; 7.
searchingKey2 BYTE "7. Searching for Thor...", 0
searchThor BYTE "Thor", 0

;; 8.
removingThor BYTE "8. Removing Thor...", 0
removeThor BYTE "Thor", 0

;; 9.
removingOdin BYTE "9. Removing Odin...", 0
removeOdin BYTE "Odin", 0

;; 10 and 11 -> use 6 and 7
searchingIronman BYTE "10. Searching for Ironman...", 0
searchingThor BYTE "11. Searching for Thor...", 0

;; 12 -> use 2
addingThor BYTE "12. Adding Thor:Hemsworth...", 0

;; 13.
addingJarvis BYTE "13. Adding Jarvis:Bettany...", 0
keyJarvis BYTE "Jarvis", 0
valueBettany BYTE "Bettany", 0

;; 14.
addingFury BYTE "14. Adding Fury:Jackson...", 0
keyFury BYTE "Fury", 0
valueJackson BYTE "Jackson", 0

;; 15.
printingAvengers15 BYTE "15. Printing Avengers...", 0

;; Bad Guys
;; 16.
creatingBadGuys BYTE "16. Creating Bad Guys Table...", 0
ptrBadGuysTable DWORD ?
badGuysHandle HANDLE ?
badGuysName BYTE "Bad Guys", 0

;; 17.
addingLoki BYTE "17. Adding Loki:Hiddleston...", 0
keyLoki BYTE "Loki", 0
valueHiddleston BYTE "Hiddleston", 0

;; 18.
addingUltron BYTE "18. Adding Ultron:Spader...", 0
keyUltron BYTE "Ultron", 0
valueSpader BYTE "Spader", 0

;; 19, 23, 24
printingBadGuys19 BYTE "19. Printing Bad Guys...", 0
destroyingBadGuys BYTE "23. Destroying Bad Guys...", 0
printingBadGuys24 BYTE "24. Printing Bad Guys After Destruction...", 0

;; 20, 21, and 22
printingAvengers20 BYTE "20. Printing Avengers...", 0
destroyingAvengers BYTE "21. Destroying Avengers...", 0
printingAvengers22 BYTE "22. Printing Avengers After Destruction...", 0


;; /* For UI */
inputSize = 20
promptMsg BYTE "Enter a key: ", 0

welcome BYTE "Welcome to Hash Table in Assembly!", 0
option1 BYTE "1. Create your own hash table (max of 5)", 0
option2 BYTE "2. Run tests on two precomputed hash tables", 0
choice BYTE "Choose one of the above options (1 or 2): ", 0
promptBad BYTE "Invalid input, please choose either 1 or 2: ", 0

promptName BYTE "Enter a name for your hash table: ", 0
promptKey BYTE "Enter a key to insert: ", 0
promptValue BYTE "Enter a value to insert: ", 0
promptRemove BYTE "Enter a key for removal: ", 0
promptSearch BYTE "Enter a key to search for: ", 0
promptSize BYTE "Enter a size for your hash table: ", 0

currentTable DWORD ?
currentHandle HANDLE ?

arrayOfHashTables DWORD 5 DUP(?)
arrayOfHandles    DWORD 5 DUP(?)

arrayFull BYTE "You have reached the maximum number of hash tables (5)", 0

operations BYTE "Hash Table Operations: ", 0
operation1 BYTE "1. Insert a key:value pair", 0
operation2 BYTE "2. Remove a key:value pair", 0
operation3 BYTE "3. Search for a key:value pair", 0
operation4 BYTE "4. Print the hash table", 0
operation5 BYTE "5. Destroy the hash table", 0
operation6 BYTE "6. Switch to a different hash table", 0
operation7 BYTE "7. Create a new hash table", 0
operationChoice BYTE "Choose one of the above operations (1, 2, 3, 4, or 5): ", 0
hashTableChoice BYTE "Choose one of the above hash tables to switch to (enter number): ", 0
promptBad2 BYTE "Invalid input, please choose either 1, 2, 3, 4, or 5: ", 0
promptBad3 BYTE "Invalid choice, please choose one of the above tables (enter number): ", 0
promptBadSize BYTE "Invalid input, please enter a size of at least 1: ", 0
currentHashTableSelection BYTE "Current Hash Table Selection: ", 0
displayTableString BYTE "Hash Table Options:", 0


.code
;------------------------------------------------------------------
;
; Initializes an empty hash table
; Receives: size of hash table
; Returns: pointer to the hash table in eax register and
;          its corresponding heap handle in ebx register
; Requires: nothing
;
;------------------------------------------------------------------

HT_CREATE PROC,
    hashSize: DWORD,
    tableName: PTR BYTE

    INVOKE GetProcessHeap
    mov ebx, eax ; move ptr to the heap into ebx register
    push ebx ; save the heap handle to return later

    ; calculate memory size for the hash table
    mov eax, hashSize
    add eax, 2 ; add two more buckets to eax (first bucket = pointer to hashtable name, second bucket = hashtable size)

    mov edx, SIZEOF DWORD ; (size of each bucket will be 4 bytes)
    mul edx ; multiply eax (hashSize) * edx (number of bytes in DWORD)
    ; eax now stores the memory size for this hash table

    ; allocate memory for the hash table
    INVOKE HeapAlloc, ebx, HEAP_ZERO_MEMORY, eax
    ; ebx = pointer to the heap
    ; eax will now store a pointer to the hash table

    ; display success message
    mov edx, offset HT_CREATE_SUCCESS
    call WriteString
    call crlf

    ; display size message
    mov edx, offset HT_CREATE_SIZE
    call WriteString

    ; push pointer to address to stack
    push eax
    
    ; display size of hashtable
    mov eax, hashSize
    call WriteInt
    call crlf
    call crlf

    ; pop pointer to address from stack
    pop eax

    ; store the tableName and tableSize into the first two buckets of hashtable
    mov esi, eax ; move pointer to hashtable into esi
    mov edx, tableName
    mov [esi], edx ; move the table name into the first bucket of the hashtable
    add esi, 4 ; move to the second bucket of the hashtable
    mov ebx, hashSize ; move the table size into ebx
    mov [esi], ebx

    ; pop pointer to the heap handle from stack
    pop ebx

    ret

HT_CREATE ENDP


;------------------------------------------------------------------
;
; Computes the hash value of a key
; Receives: key string and size of hash table
; Returns: computed hash of key in ebx register
; Requires: nothing
;
;------------------------------------------------------------------

ComputeHash PROC,
    ptrKey: PTR BYTE,
    tableSize: DWORD

    mov esi, ptrKey

    ; get the length of the string
    mov edx, ptrKey ; move the address of the key into edx
    call StrLength  ; eax now stores the string's length

    mov ecx, eax ; store the key's length in ecx for loop

    ; clear eax store char in key string through each iteration
    ; clear ebx to store sum of char values
    mov eax, 0
    mov ebx, 0

    L1:
        mov al, [esi] ; mov into al the char at given index of key string
        add ebx, eax ; add the char's value to ebx
        inc esi
    loop L1

    mov edx, 0 ; clear edx for remainder
    mov edi, tableSize ; move the hashtable size into edi

    ; perform the division
    mov eax, ebx
    div edi

    ; remainder is in edx
    mov ebx, edx ; return the remainder in the ebx register
    
    ret

ComputeHash ENDP


;------------------------------------------------------------------
;
; Inserts a key:value pair into the hash table
; Receives: a pointer to the hash table, a pointer to a key string,
;           and a pointer to a value string
; Returns: nothing
; Requires: nothing
;
;------------------------------------------------------------------

HT_INSERT PROC,
    ptrTable: PTR DWORD,
    ptrKey: PTR BYTE,
    ptrValue: PTR BYTE

    ;; before inserting any key:value pairs, we must check if the key already exists in the hash table
    ;; if it does, then we will not insert the key:value pair

    INVOKE HT_SEARCH, ptrTable, ptrKey
    ; eax = 1 if the key is found

    ; INVOKE GetLoadFactor, ptrTable
    ; currentLoadFactor = load factor after insertion

    ; fld maxLoadFactor ; goes into ST(0)
    ; fld currentLoadFactor ; goes into ST(0), maxLoadFactor moves to ST(1)
    ; fcomi ST(0), ST(1) ; checks ST(1) on left side, ST(0) on right side
    ; jg GoodSize ; if maxLoadFactor is greater than currentLoadFactor, then we can insert the key

    ;; code here for when maxLoadFactor <= currentLoadFactor
    ;; in this case, we need to resize the table and rehash all input elements
    ; INVOKE RehashTable, ptrTable

    ; GoodSize:
    cmp eax, 1
    je bottom

    ; create a four bucket array
    ; - first slot contains the key address
    ; - second slot contains the value address
    ; - third slot contains a "next" attribute, which will point to the next key:value pair in the linked-list
    ; - fourth slot contains the node's heap process (will be used when deleting the node in HT_REMOVE)

    INVOKE GetProcessHeap
    mov ebx, eax ; move ptr to the heap process into ebx register
    push ebx ; save the heap handle to return later

    ; calculate memory size for the key:value pair
    mov eax, 4 ; four buckets as mentioned before
    mov edx, SIZEOF DWORD ; (size of each bucket will be 4 bytes)
    mul edx ; multiply eax (4 buckets in key:value pair array) * edx (number of bytes in DWORD)
    ; eax now stores the memory size for the key:value pair --> 16 bytes

    ; allocate memory for the key:value pair
    INVOKE HeapAlloc, ebx, HEAP_ZERO_MEMORY, eax
    ; ebx = pointer to the heap
    ; eax will now store a pointer to the key:value pair entry

    mov esi, eax ; move the key:value pair's address into esi
    mov edx, ptrKey
    mov [esi], edx ; put the address of the key into the first slot of the 4-bucket array
    add esi, 4 ; move to second bucket

    mov edx, ptrValue
    mov [esi], edx ; put the address of the value into the second slot of the 4-bucket array
    ; leave the "next" link as 0, since it doesn't refer to any other nodes yet
    add esi, 8 ; skip the third bucket and move to the fourth bucket of the 4-bucket array
    mov [esi], ebx ; store the key:value pair's heap process into the fourth bucket
    ; eax still stores the pointer to the key:value pair here
    push eax ; push the key:value pair's address for later use

    ;; now we need to compute the hash for the key

    ; first get the table size of the hash table
    mov edi, ptrTable
    add edi, 4 ; move to the second bucket of the hash table, which stores the table size
    mov ebx, [edi]
    ; ebx now stores the size of the hash table

    ; call ComputeHash to get the index of where the key:value pair should be inserted
    mov edx, ptrKey ; move the address of the key into edx
    INVOKE ComputeHash, edx, ebx    ; edx = string address, eax = string length, ebx = hash table size
    ; intended index is returned in ebx

    pop eax ; pop the key:value pair's address to use for insertion
    ; eax = pointer to key:value pair
    ; ebx = index to insert at

    mov esi, ptrTable
    add esi, 8 ; move to index 0 of hash table

    push eax ; push the key:value pair's address to the stack for later insertion into hash table

    ; now we will calculate the offset to travel to get to the correct index
    mov eax, ebx
    mov edx, SIZEOF DWORD
    mul edx ; multiply the index by size of DWORD to determine which bucket to move to
    ; eax now stores the offset to travel by

    add esi, eax ; add the offset to the hash table's address to get to the intended bucket
    ; esi now points to the correct hash index

    pop eax ; get the address of the key:value pair since we will now insert into the hash table

    mov ebx, [esi] ; check the current value at the intended index of the hash table

    cmp ebx, 0
    jne NotEmpty

    ;; code for if bucket is empty here
    ;; if the bucket is empty, we can simply store the address of the key:value pair here
    mov [esi], eax
    jmp bottom
    
    ;; if the bucket is not empty, we have to do the following:
    ;; - set the key:value pair's "next" link to the current address stored at [esi]
    ;; - update [esi] to be equal to the address of the key:value pair
    ;; we are essentially always inserting the new key:value pair at the head of the linked list, as this is O(1)
    
    ;; what the registers are currently:
    ; eax = address of key:value pair
    ; esi = points to the current index in the hash table
    ; ebx = stores the value at the current index in the hash table
    ; will use edi to move through the key:value pair array

    NotEmpty: 
    mov edi, eax
    add edi, 8 ; move to the third bucket, which stores the "next" link
    mov [edi], ebx ; move the current head into the "next" link of the key:value pair array
    mov [esi], eax ; update the head to now store the address key:value pair array
    ; we have now created a linked list to store multiple key:value pairs that hash to the same index

    bottom:
    ret

HT_INSERT ENDP


;---------------------------------------------------------------------
;
; Determines what the load factor will be if another key is inserted
; Receives: a pointer to the hash table
; Returns: nothing
; Requires: nothing
;
;---------------------------------------------------------------------

GetLoadFactor PROC,
    ptrTable: PTR DWORD

    ; move the pointer to the hash table into esi
    mov esi, ptrTable

    add esi, 4 ; add size of DWORD to esi to move to the second bucket (which contains the table size)
    mov ecx, [esi] ; move the table size into ecx register for loop
    add esi, 4 ; now move to the third bucket, which is the actual start of the hash table
    mov edi, 0 ; used to keep track of the number of elements in the hash table

    L1:
        mov ebx, [esi] ; get the value at the given bucket and store it in esi

        ;; if the value is 0, then that position in the hash table is empty
        cmp ebx, 0
        jne NotEmpty

        ;; if ebx == 0, then jump to the end of the loop and proceed to the next hash table bucket
        jmp loopEnd

        ;; code here for when bucket isn't empty
        NotEmpty:
        FindAgain:
        inc edi ; add 1 to edi to keep track of the number of elements in the table
        ; ebx stores the address of the given key:value pair in the linked-list (which points to the first element, namely, the key string)
        
        ;; check the link
        add ebx, 8 ; move to the third bucket, which stores the next link reference
        mov edx, ebx ; move third bucket's address into edx
        mov ebx, [edx] ; dereference the memory address to get the value at the third bucket (which is the next link)
        ; ebx now stores the link reference address (address of the next key:value pair in the linked-list)

        ;; if the next link value == 0, then we can end here, as there is only one element at this hash table index
        ;; if the next link is set, then we have to repeat the process and find the next key:value pair in the linked-list
        cmp ebx, 0
        je loopEnd ; if ebx == 0, jump to bottom and move to the next bucket in the hash table
        
        ;; code for if ebx != 0:
        jmp FindAgain ; jump back up to continue the process

        loopEnd:
        add esi, 4 ; move to next bucket in hash table
    loop L1

    inc edi ; add 1 to esi because we are calling this function in anticipation of another key:value pair being added to the hash table
            ; we want to determine what the load factor would be when adding an additional element
    ; move the number of elements in eax to display
    mov edx, offset numOfElementsString
    mov eax, edi
    call WriteString
    call WriteInt
    call crlf

    ; get the table size
    mov esi, ptrTable
    add esi, 4
    mov eax, [esi] ; eax now stores the table size, which will be used to compute the load factor
    mov edx, offset tableSizeString
    call WriteString
    call WriteInt
    call crlf

    mov hashTableSize, eax
    mov numberOfElements, edi

    fild numberOfElements ; stores the number of elements into ST(0)
    fild hashtableSize ; stores the table size into ST(0), number of elements moved to ST(1)
    fdiv ; performs ST(1) / ST(0) --> result (load factor) stored into ST(0)

    mov edx, offset loadFactorString
    call WriteString
    call WriteFloat ; print the computed load factor that is stored in ST(0)
    call crlf

    fstp currentLoadFactor ; save the current load factor into variable

    ffreep st(0)  ; Clear ST(0) register
    ffreep st(1)  ; Clear ST(1) register
    ffreep st(2)  ; Clear ST(2) register

    ret

GetLoadFactor ENDP

;; /* I couldn't get this working. However, I have left the code here to show my intention */
;------------------------------------------------------------------------
;
; Rehashes a table that has exceeded its load factor
; Receives: a pointer to the hash table
; Returns: nothing
; Requires: nothing
;
;------------------------------------------------------------------------

RehashTable PROC,
    ptrTable: PTR DWORD

    mov esi, ptrTable
    mov edx, [esi] ; get the name of the hash table
    add esi, 4
    mov eax, [esi] ; get the size of the hash table

    mov ebx, 2
    mul ebx ; multiply the current table size by 2 to double it

    INVOKE HT_CREATE, eax, edx
    ; eax = doubled table size
    ; edx = table name

    ; after HT_CREATE is called
    ; eax = pointer to newly doubled hash table
    ; ebx = pointer to heap handle
    push eax
    push ebx

    add esi, 4 ; move esi pointer to the beginning of the original hash table

    L1:
        mov ebx, [esi] ; get the value at the given bucket and store it in ebx

        ;; if the value is 0, then that position in the hash table is empty
        cmp ebx, 0
        jne NotEmpty

        ;; if ebx == 0, then jump to the end of the loop and proceed to the next hash table bucket
        jmp loopEnd

        ;; code here for when bucket isn't empty
        NotEmpty:
        FindAgain:
        ; ebx stores the address of the given key:value pair in the linked-list (which points to the first element, namely, the key string)

        ;; get the key
        mov edx, [ebx] ; move the address of the key string in the key:value pair into edx

        ;; get the value
        add ebx, 4 ; move to the second bucket, which stores the address of the value string
        mov edi, [ebx] ; move the address of the value string in the key:value pair into edi

        INVOKE HT_INSERT, eax, edx, edi
        ; eax = pointer to new hash table
        ; edx = address of key
        ; edi = address of value
        ; we are inserting our node from old hash table into new one
        
        ;; check the link
        add ebx, 4 ; move to the third bucket, which stores the next link reference
        mov edx, ebx ; move third bucket's address into edx
        mov ebx, [edx] ; dereference the memory address to get the value at the third bucket (which is the next link)
        ; ebx now stores the link reference address (address of the next key:value pair in the linked-list)

        ;; if the next link value == 0, then we can end here, as there is only one element at this hash table index
        ;; if the next link is set, then we have to repeat the process and find the next key:value pair in the linked-list
        cmp ebx, 0
        je loopEnd ; if ebx == 0, jump to bottom and move to the next bucket in the hash table
        
        ;; code for if ebx != 0:
        jmp FindAgain ; jump back up to continue the process

        loopEnd:
        add esi, 4 ; move to next bucket in hash table
    loop L1

    pop ebx ; heap handle of new hash table
    pop eax ; pointer to new hash table

    ;; now we need to update our old pointer to the new pointer
    mov edi, eax
    mov edi, [edi] ; get the hash table's name

    INVOKE Str_compare, edi, ADDR avengersName
    jne checkNext
    ; if they are equal, then delete the old avengers hash table, and update avengers pointer and handle
    INVOKE HT_DESTROY, ptrAvengersTable, avengersHandle
    mov ptrAvengersTable, eax
    mov avengersHandle, ebx
    jmp finished

    checkNext:
    INVOKE Str_compare, edi, ADDR badGuysName
    jne checkNext2
    ; if they are equal, then delete the old bad guys hash table, and update bad guys pointer and handle
    INVOKE HT_DESTROY, ptrBadGuysTable, badGuysHandle
    mov ptrBadGuysTable, eax
    mov badGuysHandle, ebx
    jmp finished

    checkNext2:
    ;; in this case, the hash table we updated is stored in arrayOfHashTables (not Avengers or Bad Guys, but one of the user created tables)
    ;; we need to update this pointer
    mov currentTable, eax
    mov currentHandle, ebx
    INVOKE HT_DESTROY, currentTable, currentHandle

    mov esi, offset arrayOfHashTables
    mov ebx, offset arrayOfHandles
    mov ecx, 5

    L2:
        mov edx, [esi] ; get the hash table ptr
        mov edx, [edx] ; get the hash table name
        INVOKE Str_compare, edx, edi
        ;; if the hash table name == new hash table name,
        ;; we need to replace this old pointer with the new pointer
        jne endLoop ;; if they aren't equal, jump to the end and check the next array position

        ;; code for when they are equal
        mov edx, esi ; get the hash table position
        mov [esi], edi ; update the pointer to the new hash table pointer
        mov edx, currentHandle
        mov [ebx], edx ; update the old handle to the handle of the new hash table

        endLoop:
        add esi, 4
        add ebx, 4
    loop L2

    finished:
    ret

RehashTable ENDP


;------------------------------------------------------------------
;
; Removes a key:value pair from the hash table
; Receives: a pointer to the hash table, a pointer to a key string
; Returns: nothing
; Requires: nothing
;
;------------------------------------------------------------------

HT_REMOVE PROC,
    ptrTable: PTR DWORD,
    ptrKey: PTR BYTE

    ; move the pointer to the hash table into esi
    mov esi, ptrTable
    ; move the pointer to the remove key into eax
    mov eax, ptrKey

    add esi, 4 ; add size of DWORD to esi to move to the second bucket (which contains the table size)
    mov ecx, [esi] ; move the table size into ecx register
    add esi, 4 ; now move to the third bucket, which is the actual start of the hash table
    push esi ; esi = beginning of hash table (excluding meta data)
    push ecx ; ecx = hash table size

    ;; get the remove key's hash value to determine which index of the hash table to search through
    INVOKE ComputeHash, eax, ecx
    ; ebx = hash index
    pop ecx
    pop esi

    ;; calculate the numbers of bytes needed to move to the correct index position
    mov eax, ebx ; store the hash index in eax
    mov ebx, SIZEOF DWORD
    mul ebx ; (hash index) * (4 bytes) = position in hash table to search for
    add esi, eax ; esi now points to the correct index in the hash table to search

    mov ebx, [esi] ; ebx stores the address of the first node in the linked list
    ;mov prev, ebx

    ;; if ebx == 0 here, this means that the bucket that our removal key has hashed to is empty
    ;; therefore, the removal key doesn't exist in the hash table
    cmp ebx, 0
    je NotFound

    mov edi, [ebx] ; edi = address of key in first node
    mov eax, ptrKey

    ;; compare the key of first node with the removal key
    INVOKE Str_compare, edi, eax
    ; edi = address of key in node
    ; eax = address of remove key

    jne notHeadDeletion ;; if they aren't equal, then not a head node deletion

    ;; if they are equal, then this means we are deleting the head
    ;; we will use a helper function to do this.
    ;; - if the linked list has one node, we will simply free the memory for the one node,
    ;;   and change the memory address at the hash table bucket to 0 (as it is now empty)
    ;; - if the linked list has multiple nodes, will will have to free the memory for the one node,
    ;;   but also update the memory address at the hash table bucket to the second node in the linked-list

    INVOKE RemoveAtHead, esi, ebx
    ; esi = address of bucket in hash table
    ; ebx = address of first node in linked-list
    jmp completed

    notHeadDeletion:
    SearchAgain:
    mov prev, ebx ; move address of first node into prev
    add ebx, 8 ; move to the third bucket of the 4-bucket array
    mov ebx, [ebx] ; get the next reference of the current node
    mov current, ebx ; current now stores the second node in the linked-list

    ; if ebx == 0, then we are at the end of the linked-list
    ; therefore, we should stop searching
    cmp ebx, 0
    je NotFound

    mov ebx, [ebx] ; get the key string at the second node in the linked-list
    mov eax, ptrKey

    INVOKE Str_compare, ebx, eax
    ; ebx = key of second node
    ; eax = key to remove
    jne notEqual

    ;; if the strings are equal, remove the node
    INVOKE RemoveBetween, prev, current
    jmp completed


    ;; if the strings aren't equal, we want to move to the next node and search again
    notEqual:
    mov ebx, current
    jmp SearchAgain


    NotFound:
    mov edx, offset itemNotFound
    call WriteString
    call crlf

    completed:
    ret

HT_REMOVE ENDP


;----------------------------------------------------------------------
;
; Helper function to remove a node at the head of the linked-list
; Receives: address of a hash table index, address of a node to delete
; Returns: nothing
; Requires: nothing
;
;----------------------------------------------------------------------

RemoveAtHead PROC,
    bucketAddress: PTR DWORD,
    nodeAddress: PTR DWORD

    mov esi, bucketAddress
    mov ebx, nodeAddress

    mov edx, ebx ; store the address of the node in edx
    add edx, 8 ; go to the third-bucket in the node, which is the address of the node's "next" reference
    mov edx, [edx] ; get the node's next reference address
    push edx ; push the "next" reference for later use

    cmp edx, 0
    jne multipleNodes

    ;; if edx == 0, then there is only one node in the linked-list
    ;; - we can simply free this node, and update the hash table index to be empty

    ; get the handle for removal
    mov eax, nodeAddress
    add eax, 12
    mov eax, [eax]

    INVOKE HeapFree, eax, 0, ebx
    ; eax = heap process handle
    ; ebx = address of node

    ; finally, update the memory location at the hash table index to 0,
    ; since the bucket is now empty
    mov ecx, 0
    mov [esi], ecx
    jmp Done

    
    ;; if the linked-list is not empty, then we have to do the following
    ;; - remove the node that we want to delete
    ;; - update the hash table index to store the address of the second node (the first node's "next" link)
    multipleNodes:

    ; get the handle for removal
    mov eax, nodeAddress
    add eax, 12
    mov eax, [eax]

    INVOKE HeapFree, eax, 0, ebx
    pop edx ; pop the node's "next" reference
    mov [esi], edx ; update the memory location at the hash table index to the address of the second node (the new first node in the linked-list)

    Done:
    ret

RemoveAtHead ENDP


;--------------------------------------------------------------------------
;
; Helper function to remove a node in between other nodes of a linked-list
; Receives: address of prev node, node to delete, and after node
; Returns: nothing
; Requires: nothing
;
;--------------------------------------------------------------------------

RemoveBetween PROC,
    prevAddress: PTR DWORD,
    nodeAddress: PTR DWORD

    mov esi, prevAddress
    mov edi, nodeAddress

    ;; get the heap process of nodeAddress
    add edi, 12 ; move to fourth bucket in node
    mov eax, [edi] ; get the value at that bucket (the heap process)

    ;; get the address of the next node
    sub edi, 4 ; move back to the third bucket in node (which contains the next reference)
    mov edi, [edi] ; get the value at that bucket (the next reference)
    push edi

    ;; free the node from memory
    mov edi, nodeAddress
    INVOKE HeapFree, eax, 0, edi
    ; eax = heap process
    ; edi = node address

    ;; link the prev node to it's new next node
    pop edi ; pop the next reference
    add esi, 8 ; move to the third bucket of the prev node (which is it's next reference)
    ; update the next reference
    mov [esi], edi

    ret

RemoveBetween ENDP


;----------------------------------------------------------------------
;
; Searches for a key in the hash table and if found, returns the value
; Receives: a pointer to the hash table and a pointer to a key string
; Returns: returns the value in edx, and 1 in eax
;          if not found, returns 0 in eax
; Requires: nothing
;
;----------------------------------------------------------------------

HT_SEARCH PROC,
    ptrTable: PTR DWORD,
    ptrSearch: PTR BYTE

    ; move the pointer to the hash table into esi
    mov esi, ptrTable
    ; move the pointer to the search key into eax
    mov eax, ptrSearch

    add esi, 4 ; add size of DWORD to esi to move to the second bucket (which contains the table size)
    mov ecx, [esi] ; move the table size into ecx register
    add esi, 4 ; now move to the third bucket, which is the actual start of the hash table
    push esi ; esi = beginning of hash table (excluding meta data)
    push ecx ; ecx = hash table size

    ;; get the search key's hash value to determine which index of the hash table to search
    INVOKE ComputeHash, eax, ecx
    pop ecx
    pop esi
    
    ;; calculate the numbers of bytes needed to move to the correct index position
    mov eax, ebx ; store the hash index in eax
    mov ebx, SIZEOF DWORD
    mul ebx ; (hash index) * (4 bytes) = position in hash table to search for
    add esi, eax ; esi now points to the correct index in the hash table to search

    
    mov ebx, [esi] ; get the value at the given bucket and store it in esi
    ;; if the value is 0, then that position in the hash table is empty
    cmp ebx, 0
    je notFound ;; if ebx == 0, then jump to notFound, since there is nothing else to search


    ;; code here for when bucket isn't empty
    SearchAgain:
    ;; get the key at the given node
    ; ebx stores the address of the given key:value pair in the linked-list
    mov edx, [ebx] ; move the address of the key string in the key:value pair into edx
    ; edx = address of key
    mov eax, ptrSearch
    ; eax = address of search string

    INVOKE Str_compare, edx, eax ; compare's the key string with the search value
    jne continue

    ;; if they are equal, return the value in edx register
    add ebx, 4 ; move to the second bucket, which stores the address of the value string
    mov edx, [ebx]
    mov eax, 1 ;; return 1 if the key is found
    jmp keyFound ;; end the function as they key has been found

    ;; if they aren't equal, then we have to continue searching through the linked list
    continue:
    ;; check the link
    add ebx, 8 ; move to the third bucket, which stores the next link reference
    mov edx, ebx ; move third bucket's address into edx
    mov ebx, [edx] ; dereference the memory address to get the value at the third bucket (which is the next link)
    ; ebx now stores the link reference address (address of the next key:value pair in the linked-list)

    ;; if the next link value == 0, then we can end here, as there is only one element in this hash table index
    ;; if the next link is set, then we have to repeat the process and search the next key:value pair in the linked-list
    cmp ebx, 0
    je notFound ; if ebx == 0, jump to bottom as we are done searching the linked-list
        
    ;; code for if ebx != 0:
    ; ebx = address of next key:value pair in linked-list
    jmp SearchAgain ; jump back up to continue the process


    notFound:
    mov eax, 0
    mov edx, offset keyNotFound

    keyFound:
    ret

HT_SEARCH ENDP


;------------------------------------------------------------------
;
; Prints the contents of the hash table, including:
; - the hash table's name
; - each hash value with its corresponding key:value pair
; - current hash table size
; - numbers of elements
; - load factor (# elements / table size)
; Receives: pointer to a hash table
; Returns: nothing
; Requires: nothing
;
;------------------------------------------------------------------

HT_PRINT PROC,
    ptrTable: PTR DWORD

    ; move the pointer to the hash table into esi
    mov esi, ptrTable

    mov edx, [esi] ; move the value in the first bucket into ebx (this value is the address of the hash table's name)
    call WriteString

    mov edx, offset heading
    call WriteString
    call crlf

    add esi, 4 ; add size of DWORD to esi to move to the second bucket (which contains the table size)
    mov ecx, [esi] ; move the table size into ecx register for loop
    add esi, 4 ; now move to the third bucket, which is the actual start of the hash table

    mov eax, 0 ; used to keep track of hash index
    mov edi, 0 ; used to keep track of the number of elements in the hash table

    mov edx, offset hashIndexLabel
    call WriteString

    mov edx, offset emptySpace
    call WriteString

    mov edx, offset pairLabel
    call WriteString
    call crlf

    L1:
        mov ebx, [esi] ; get the value at the given bucket and store it in esi

        ;; if the value is 0, then that position in the hash table is empty
        cmp ebx, 0
        jne NotEmpty

        ;; code for empty
        call WriteInt ; eax stores the index, so print that value to the screen

        mov edx, offset moreEmptySpace
        call WriteString

        mov edx, offset emptyPair
        call WriteString
        jmp loopEnd

        
        ;; code here for when bucket isn't empty
        NotEmpty:
        call WriteInt ; eax stores the index, so print that value to the screen
        mov edx, offset moreEmptySpace
        call WriteString

        PrintPairAgain:
        inc edi ; add 1 to edi to keep track of the number of elements in the table

        ;; print the key
        ; ebx stores the address of the given key:value pair in the linked-list (which points to the first element, namely, the key string)
        mov edx, [ebx] ; move the address of the key string in the key:value pair into ebx
        call WriteString

        mov edx, offset colonString
        call WriteString

        ;; print the value
        add ebx, 4 ; move to the second bucket, which stores the address of the value string
        mov edx, [ebx]
        call WriteString

        ;; check the link
        add ebx, 4 ; move to the third bucket, which stores the next link reference
        mov edx, ebx ; move third bucket's address into edx
        mov ebx, [edx] ; dereference the memory address to get the value at the third bucket (which is the next link)
        ; ebx now stores the link reference address (address of the next key:value pair in the linked-list)

        ;; if the next link value == 0, then we can end here, as there is only one element in this hash table index
        ;; if the next link is set, then we have to repeat the process and print the next key:value pair in the linked-list
        cmp ebx, 0
        je loopEnd ; if ebx == 0, jump to bottom and move to the next bucket in the hash table
        
        ;; code for if ebx != 0:
        mov edx, offset arrow
        call WriteString
        ; ebx = address of next key:value pair in linked-list
        jmp PrintPairAgain ; jump back up to continue the process


        loopEnd:
        inc eax ; increase the hash index for display
        add esi, 4 ; move to next bucket in hash table
        call crlf
    loop L1

    ; move the number of elements in eax to display
    mov edx, offset numOfElementsString
    mov eax, edi
    call WriteString
    call WriteInt
    call crlf

    ; get the table size
    mov esi, ptrTable
    add esi, 4
    mov eax, [esi] ; eax now stores the table size, which will be used to compute the load factor
    mov edx, offset tableSizeString
    call WriteString
    call WriteInt
    call crlf

    mov hashTableSize, eax
    mov numberOfElements, edi

    fild numberOfElements ; stores the number of elements into ST(0)
    fild hashtableSize ; stores the table size into ST(0), number of elements moved to ST(1)
    fdiv ; performs ST(1) / ST(0) --> result (load factor) stored into ST(0)

    mov edx, offset loadFactorString
    call WriteString
    call WriteFloat ; print the computed load factor that is stored in ST(0)
    call crlf

    ffreep st(0)  ; Clear ST(0) register
    ffreep st(1)  ; Clear ST(1) register
    ffreep st(2)  ; Clear ST(2) register

    ret

HT_PRINT ENDP


;-------------------------------------------------------------------------
;
; Destroys a hash table and frees up its memory from the heap
; Receives: a pointer to the hash table and its corresponding heap handle
; Returns: nothing
; Requires: nothing
;
;-------------------------------------------------------------------------

HT_DESTROY PROC,
    ptrTable: PTR DWORD,
    HeapHandle: HANDLE

    mov eax, ptrTable
    mov ebx, HeapHandle

    ; free the hash table given its heap process and table pointer
    INVOKE HeapFree, ebx, 0, eax

    mov esi, ptrTable
    add esi, 4; move to the second bucket of the hash table, which contains the table size
    mov ecx, [esi]
    add esi, 4 ; move to the third bucket of the hash table, which is the actual start (excluding name and size)

    L1:

        mov ebx, [esi] ; get the value at the given bucket

        ;; if the value is 0, then that position in the hash table is empty
        cmp ebx, 0
        je Empty ; if its empty, then we can skip to the end and proceed to the next bucket

        ;; if the bucket isn't empty
        ;; here, we want to deallocate this node, get its next reference, and its heap handle
        ; edx = pointer to node (key:value pair)
        ; we want [edx+8] = next reference
        ;     and [edx+12] = heap handle

        SearchForRemovalAgain:
            mov edx, ebx
            add edx, 8
            mov edx, [edx] ; get the value stored at the third bucket of the node (the next reference)
            push edx

            mov edi, ebx
            add edi, 12
            mov edi, [edi] ; get the value stored at the fourth bucket of the node (the heap handle)

            push ecx
            INVOKE HeapFree, edi, 0, ebx
            pop ecx
            ;; where edi = heap handle
            ;;   and ebx = pointer to node

            ;; now that this node has been freed from memory, check if its next reference is set
            ;; if it is, then we need to free this node as well
            ;; edx = next reference
            pop edx

            cmp edx, 0
            je Empty ; if ebx == 0, then the node we just freed isn't linked to another node
                     ; we can, therefore, move to the next bucket in the hash table

            ;; if ebx != 0, we need to free this node
            mov ebx, edx ; move the node into ebx and proceed with the same process
        jmp SearchForRemovalAgain


        Empty:
        add esi, 4
    loop L1

    mov esi, ptrTable
    INVOKE ClearTable, esi

    mov edx, offset destroySuccess
    call WriteString
    call crlf

    ret

HT_DESTROY ENDP


;-------------------------------------------------------------------------
;
; Loops through a hash table and clears all of its entries
; Receives: a pointer to the hash table
; Returns: nothing
; Requires: that the hash table has been destroyed first
;
;-------------------------------------------------------------------------

ClearTable PROC,
    ptrTable: PTR DWORD

    mov esi, ptrTable ; move the pointer to the hash table into esi
    mov edi, 0 ; will use edi value to clear all memory locations

    add esi, 4 ; move to the second bucket in the hash table, which stores the table size
    mov ecx, [esi] ; move the hash table's size into ecx
    add esi, 4 ; move to the first bucket in the hash table (excluding name and size)

    L1:
        push esi
        mov ebx, [esi]
        cmp ebx, 0 ;; if ebx == 0, then there are no nodes in this bucket
                   ;; we can jump to bottom and move to next bucket in the hash table
        je bottom

        ;; if ebx != 0
        mov edx, [esi] ; save the pointer to the node in edx
        mov [esi], edi ; clear the pointer
        mov esi, edx
        mov [esi], edi ; clear the key field
        add esi, 4 ; move to the second bucket (value field)
        mov [esi], edi ; clear the value field
        add esi, 8 ; move to the fourth bucket (heap handle field)
        mov [esi], edi ; clear the heap handle field

        sub esi, 4 ; move back to the third bucket (next reference)
        mov ebx, [esi] ; move the node's next reference into edx
        cmp ebx, 0
        je bottom ;; if ebx == 0, then there are no other nodes in the linked-list that need to be cleared
                  ;; we can just jump to the bottom and move to the next bucket in the hash table
        ;; otherwise we need to repeat the process for this next node and all subsequent nodes
        mov [esi], edi ; clear the next reference field
        
        ; mov edx, ebx ; save the next reference into edx
        SearchAgain:
        ;mov esi, ebx
        ;mov [esi], edi
        mov [ebx], edi ; clear the key field
        add ebx, 4
        mov [ebx], edi ; clear the value field
        add ebx, 8
        mov [ebx], edi ; clear the heap handle field
        sub ebx, 4
        mov edx, [ebx]
        cmp edx, 0
        je bottom
        jmp SearchAgain

        bottom:
        pop esi
        add esi, 4
    loop L1

    ret

ClearTable ENDP



;; / * UI Implementation * /

;-------------------------------------------------------------------------
;
; Runs the specified list of test cases on the Avengers Hash Table
; Receives: nothing
; Returns: nothing
; Requires: nothing
;
;-------------------------------------------------------------------------

AvengersTestCases PROC

    mov edx, offset creatingAvengers
    call WriteString
    call crlf
    INVOKE HT_CREATE, 5, ADDR avengersName
    mov ptrAvengersTable, eax
    mov avengersHandle, ebx
    INVOKE HT_PRINT, ptrAvengersTable
    call crlf
    call WaitMsg
    call clrscr

    mov edx, offset addingKey1
    call WriteString
    call crlf
    mov edx, offset addingKey2
    call WriteString
    call crlf
    mov edx, offset addingKey3
    call WriteString
    call crlf

    INVOKE HT_INSERT, ptrAvengersTable, ADDR keyThor, ADDR valueHemsworth
    INVOKE HT_INSERT, ptrAvengersTable, ADDR keyIronman, ADDR valueDowney
    INVOKE HT_INSERT, ptrAvengersTable, ADDR keyHulk, ADDR valueRuffalo
    call crlf

    mov edx, offset printingAvengers5
    call WriteString
    call crlf
    INVOKE HT_PRINT, ptrAvengersTable
    call crlf
    call WaitMsg
    call clrscr

    mov edx, offset searchingKey1
    call WriteString
    call crlf

    mov edx, offset valueFor
    call WriteString
    mov edx, offset quote
    call WriteString
    mov edx, offset searchIronman
    call WriteString
    mov edx, offset quote
    call WriteString
    mov edx, offset is
    call WriteString
    mov edx, offset quote
    call WriteString
    INVOKE HT_SEARCH, ptrAvengersTable, ADDR searchIronman
    call WriteString
    mov edx, offset quote
    call WriteString
    call crlf
    call crlf

    mov edx, offset searchingKey2
    call WriteString
    call crlf

    mov edx, offset valueFor
    call WriteString
    mov edx, offset quote
    call WriteString
    mov edx, offset searchThor
    call WriteString
    mov edx, offset quote
    call WriteString
    mov edx, offset is
    call WriteString
    mov edx, offset quote
    call WriteString
    INVOKE HT_SEARCH, ptrAvengersTable, ADDR searchThor
    call WriteString
    mov edx, offset quote
    call WriteString
    call crlf
    call crlf
    call WaitMsg
    call clrscr

    mov edx, offset removingThor
    call WriteString
    INVOKE HT_REMOVE, ptrAvengersTable, ADDR removeThor
    call crlf

    mov edx, offset removingOdin
    call WriteString
    INVOKE HT_REMOVE, ptrAvengersTable, ADDR removeOdin
    call crlf

    INVOKE HT_PRINT, ptrAvengersTable
    call crlf
    call WaitMsg
    call clrscr

    mov edx, offset searchingIronman
    call WriteString
    call crlf

    mov edx, offset valueFor
    call WriteString
    mov edx, offset quote
    call WriteString
    mov edx, offset searchIronman
    call WriteString
    mov edx, offset quote
    call WriteString
    mov edx, offset is
    call WriteString
    mov edx, offset quote
    call WriteString
    INVOKE HT_SEARCH, ptrAvengersTable, ADDR searchIronman
    call WriteString
    mov edx, offset quote
    call WriteString
    call crlf
    call crlf

    mov edx, offset searchingThor
    call WriteString
    call crlf

    mov edx, offset valueFor
    call WriteString
    mov edx, offset quote
    call WriteString
    mov edx, offset searchThor
    call WriteString
    mov edx, offset quote
    call WriteString
    mov edx, offset is
    call WriteString
    mov edx, offset quote
    call WriteString
    INVOKE HT_SEARCH, ptrAvengersTable, ADDR searchThor
    call WriteString
    mov edx, offset quote
    call WriteString
    call crlf
    call crlf
    call WaitMsg
    call clrscr

    mov edx, offset addingThor
    call WriteString
    call crlf
    mov edx, offset addingJarvis
    call WriteString
    call crlf
    mov edx, offset addingFury
    call WriteString
    call crlf

    INVOKE HT_INSERT, ptrAvengersTable, ADDR keyThor, ADDR valueHemsworth
    INVOKE HT_INSERT, ptrAvengersTable, ADDR keyJarvis, ADDR valueBettany
    INVOKE HT_INSERT, ptrAvengersTable, ADDR keyFury, ADDR valueJackson
    call crlf

    mov edx, offset printingAvengers15
    call WriteString
    call crlf
    INVOKE HT_PRINT, ptrAvengersTable
    call crlf
    call WaitMsg
    call clrscr

    ret

AvengersTestCases ENDP


;-------------------------------------------------------------------------
;
; Runs the specified list of test cases on the Bad Guys Hash Table
; Receives: nothing
; Returns: nothing
; Requires: nothing
;
;-------------------------------------------------------------------------

BadGuysTestCases PROC

    mov edx, offset creatingBadGuys
    call WriteString
    call crlf
    INVOKE HT_CREATE, 6, ADDR badGuysName
    mov ptrBadGuysTable, eax
    mov badGuysHandle, ebx
    INVOKE HT_PRINT, ptrBadGuysTable
    call crlf
    call WaitMsg
    call clrscr

    mov edx, offset addingLoki
    call WriteString
    call crlf
    INVOKE HT_INSERT, ptrBadGuysTable, ADDR keyLoki, ADDR valueHiddleston
    
    mov edx, offset addingUltron
    call WriteString
    call crlf
    call crlf
    INVOKE HT_INSERT, ptrBadGuysTable, ADDR keyUltron, ADDR valueSpader

    INVOKE HT_PRINT, ptrBadGuysTable
    call crlf
    call WaitMsg
    call clrscr

    ret

BadGuysTestCases ENDP


;-------------------------------------------------------------------------
;
; Tests the last couple of HT_PRINT and HT_DESTROY cases
; Receives: nothing
; Returns: nothing
; Requires: nothing
;
;-------------------------------------------------------------------------

PrintAndDestroyCases PROC

    mov edx, offset printingBadGuys19
    call WriteString
    call crlf
    call crlf
    INVOKE HT_PRINT, ptrBadGuysTable
    call crlf
    call WaitMsg
    call clrscr

    mov edx, offset printingAvengers20
    call WriteString
    call crlf
    call crlf
    INVOKE HT_PRINT, ptrAvengersTable
    call crlf
    call WaitMsg
    call clrscr

    mov edx, offset destroyingAvengers
    call WriteString
    call crlf
    INVOKE HT_DESTROY, ptrAvengersTable, avengersHandle
    call crlf
    mov edx, offset printingAvengers22
    call WriteString
    call crlf
    INVOKE HT_PRINT, ptrAvengersTable
    call crlf
    call WaitMsg
    call clrscr

    mov edx, offset destroyingBadGuys
    call WriteString
    call crlf
    INVOKE HT_DESTROY, ptrBadGuysTable, badGuysHandle
    call crlf
    mov edx, offset printingBadGuys24
    call WriteString
    call crlf
    INVOKE HT_PRINT, ptrBadGuysTable
    call crlf

    ret

PrintAndDestroyCases ENDP


;-------------------------------------------------------------------------
;
; Prompts the user to enter a name/key/value, and allocates memory for it
; Receives: pointer to a prompt string
; Returns: memory address of name/key/value string in edx
; Requires: nothing
;
;-------------------------------------------------------------------------

PromptString PROC,
    ptrString: PTR BYTE

    INVOKE GetProcessHeap
    mov ebx, eax ; move ptr to the heap into ebx register
    push ebx ; save the heap handle to return later

    ; allocate memory for the key string
    INVOKE HeapAlloc, ebx, HEAP_ZERO_MEMORY, inputSize
    ; ebx = pointer to the heap
    ; eax = pointer to the allocated memory

    ; Print prompt message
    mov edx, ptrString
    call WriteString

    ; Read the string into the allocated memory
    mov edx, eax
    mov ecx, inputSize
    call ReadString

    ret

PromptString ENDP


;-------------------------------------------------------------------------
;
; Displays the UI for the start screen
; Receives: nothing
; Returns: memory address of key/value string in edx
; Requires: nothing
;
;-------------------------------------------------------------------------

StartScreen PROC

    mov edx, offset welcome
    call WriteString
    call crlf

    mov edx, offset option1
    call WriteString
    call crlf

    mov edx, offset option2
    call WriteString
    call crlf
    call crlf

    mov edx, offset choice
    call WriteString

    ret

StartScreen ENDP


;-------------------------------------------------------------------------
;
; Prompts the user to enter an integer (either 1 or 2)
; Receives: nothing
; Returns: the user inputed number in eax register
; Requires: nothing
;
;-------------------------------------------------------------------------

ReadNumber PROC

    read:  
    call ReadInt
    
    cmp eax, 1
    je goodInput

    cmp eax, 2
    je goodInput

    mov edx, OFFSET promptBad
    call WriteString
    jmp  read        ; go input again

    goodInput:
    ret

ReadNumber ENDP


;-------------------------------------------------------------------------
;
; Prompts the user to enter a hash table size (>=1)
; Receives: nothing
; Returns: the user inputed number in eax register
; Requires: nothing
;
;-------------------------------------------------------------------------

GetSize PROC

read:  
    call ReadInt
    cmp eax, 1
    jge goodInput

    mov edx, OFFSET promptBadSize
    call WriteString
    jmp  read        ; go input again

    goodInput:
    ret

GetSize ENDP


;---------------------------------------------------------------------------
;
; Stores the pointer of a user created hash table into arrayOfHashTables
; and its corresponding heap handle into arrayOfHandles
; Receives: nothing
; Returns: nothing
; Requires: nothing
;
;---------------------------------------------------------------------------

AddToArrays PROC,
    ptrTable: PTR DWORD,
    ptrHandle: PTR DWORD

    mov esi, offset arrayOfHashTables
    mov edi, offset arrayOfHandles
    mov ecx, 5

    L1:
        mov eax, [esi]
        cmp eax, 0
        jne bottomOfLoop

        mov eax, [edi]
        cmp eax, 0
        jne bottomOfLoop

        mov eax, ptrTable
        mov ebx, ptrHandle

        mov [esi], eax
        mov [edi], ebx
        jmp Finished

        bottomOfLoop:
        add esi, 4
        add edi, 4
    loop L1

    mov edx, offset arrayFull
    call WriteString

    Finished:
    ret

AddToArrays ENDP


;---------------------------------------------------------------------------
;
; Creates a hash table based on user inputed values
; Receives: nothing
; Returns: nothing
; Requires: nothing
;
;---------------------------------------------------------------------------

CreateHashTable PROC

    INVOKE PromptString, ADDR promptName
    ; edx = user entered name
    push edx

    mov edx, offset promptSize
    call WriteString
    call GetSize
    ; eax = user entered size
    pop edx

    call crlf
    INVOKE HT_CREATE, eax, edx
    ; eax = pointer to hash table
    ; ebx = pointer to heap handle

    mov currentTable, eax
    mov currentHandle, ebx

    INVOKE AddToArrays, currentTable, currentHandle
    ; add the hash table's pointer and handle to their corresponding arrays

    ret

CreateHashTable ENDP


;---------------------------------------------------------------------------
;
; Display the user's operation options, and prompts them to make a selection
; Receives: nothing
; Returns: nothing
; Requires: nothing
;
;---------------------------------------------------------------------------

OperationSelection PROC

    mov edx, offset currentHashTableSelection
    call WriteString

    mov esi, currentTable
    mov edx, [esi]
    call WriteString
    call crlf
    call crlf

    mov edx, offset operations
    call WriteString
    call crlf

    mov edx, offset operation1
    call WriteString
    call crlf

    mov edx, offset operation2
    call WriteString
    call crlf

    mov edx, offset operation3
    call WriteString
    call crlf

    mov edx, offset operation4
    call WriteString
    call crlf

    mov edx, offset operation5
    call WriteString
    call crlf

    mov edx, offset operation6
    call WriteString
    call crlf

    mov edx, offset operation7
    call WriteString
    call crlf
    call crlf

    mov edx, offset operationChoice
    call WriteString
    call GetSelection
    call crlf

    ret

OperationSelection ENDP


;---------------------------------------------------------------------------
;
; Prompts the user to enter a value between 1 and 7 for operation selection
; Receives: nothing
; Returns: the user's selection in the eax register
; Requires: nothing
;
;---------------------------------------------------------------------------

GetSelection PROC

    read:  
    call ReadInt
    jo badInput
    
    cmp eax, 1
    jl badInput

    cmp eax, 7
    jg badInput

    jmp goodInput

    badInput:
    mov edx, OFFSET promptBad2
    call WriteString
    jmp  read        ; go input again

    goodInput:
    ret
    
GetSelection ENDP


;---------------------------------------------------------------------------
;
; Performs a hash table operation corresponding to the selection in eax
; Receives: nothing
; Returns: nothing
; Requires: user's selection to be set in the eax register
;
;---------------------------------------------------------------------------

CallOperation PROC

    cmp eax, 1
    jne op2

    ;; if operation 1 is selected
    INVOKE PromptString, ADDR promptKey
    ; edx = address of key

    mov ebx, edx ; move the key address into ebx
    ; ebx = address of key
    push ebx

    INVOKE PromptString, ADDR promptValue
    ; edx = address of value

    pop ebx
    INVOKE HT_INSERT, currentTable, ebx, edx
    call crlf
    jmp completed
    

    op2:
    cmp eax, 2
    jne op3

    ;; if operation 2 is selected
    INVOKE PromptString, ADDR promptRemove
    ; edx = address of key
    INVOKE HT_REMOVE, currentTable, edx
    call crlf
    jmp completed

    
    op3:
    cmp eax, 3
    jne op4

    ;; if operation 3 is selected
    INVOKE PromptString, ADDR promptSearch
    ; edx = address of key

    INVOKE HT_SEARCH, currentTable, edx
    ; result is stored in edx, so have to print it
    call WriteString
    call crlf
    call crlf
    jmp completed


    op4:
    cmp eax, 4
    jne op5

    ;; if operation4 is selected
    INVOKE HT_PRINT, currentTable
    call crlf
    jmp completed


    op5:
    cmp eax, 5
    jne op6

    ;; if operation5 is selected
    INVOKE HT_DESTROY, currentTable, currentHandle
    call crlf
    jmp completed

    op6:
    cmp eax, 6
    jne op7

    ;; if operation6 is selected
    call DisplayTableArray

    jmp completed


    op7:
    
    ;; if operation7 is selected
    call CreateHashTable

    completed:
    ret

CallOperation ENDP


;---------------------------------------------------------------------------
;
; Displays the list of possible hash tables to switch between and prompts
; the user to select which table they would like to switch to
; Receives: nothing
; Returns: nothing
; Requires: nothing
;
;---------------------------------------------------------------------------

DisplayTableArray PROC

    mov esi, offset arrayOfHashTables
    mov edi, offset arrayOfHandles
    mov eax, 1
    mov ecx, 5

    mov edx, offset displayTableString
    call WriteString
    call crlf

    L1:
        mov ebx, [esi] ; move the hash table pointer into ebx
        cmp ebx, 0 ; if ebx == 0, then a table ptr doesn't exist at this position in the array
        je loopEnd ; therefore, jump to the end and search the next index

        ;; if a pointer exists here in the array, display its name
        call WriteInt ; display the selection option
        mov edx, offset dot
        call WriteString

        mov ebx, [ebx] ; get the ptrTable's name
        mov edx, ebx
        call WriteString
        call crlf
        inc eax

        loopEnd:
        add esi, 4
        add edi, 4
    loop L1

    ; prompt the user to make a selection
    call crlf
    mov edx, offset hashTableChoice
    call WriteString

    ; save max eax value in ebx
    sub eax, 1 ; subtract one from eax because of the additional value added at the end of the loop
    mov ebx, eax

    read:  
    call ReadInt
    jo badInput
    
    cmp eax, 1
    jl badInput

    cmp eax, ebx
    jg badInput

    jmp goodInput

    badInput:
    mov edx, OFFSET promptBad3
    call WriteString
    jmp  read        ; go input again

    goodInput:
    ; switch to the correct table
    mov esi, offset arrayOfHashTables
    mov edi, offset arrayOfHandles

    sub eax, 1 ; switch to 0 based indexing for array
    mov ebx, SIZEOF DWORD
    mul ebx
    add esi, eax
    add edi, eax

    ; update the current hash table and its corresponding heap handle
    mov ebx, [esi]
    mov currentTable, ebx
    mov ebx, [edi]
    mov currentHandle, ebx

    ret

DisplayTableArray ENDP



main PROC
; write your code here

    Start:
    call StartScreen
    call ReadNumber

    cmp eax, 1
    jne choiceTwo

    ;; choice one code here...
    call clrscr
    call CreateHashTable
    call clrscr

    selectAgain:
        call clrscr
        call OperationSelection
        call CallOperation
        call WaitMsg
    jmp SelectAgain

    jmp displayOver

    choiceTwo:
    call clrscr
    call AvengersTestCases
    call BadGuysTestCases
    call PrintAndDestroyCases
    call WaitMsg
    call clrscr
    jmp Start
   
    displayOver:
    NOP
    INVOKE ExitProcess,1
main ENDP
END main