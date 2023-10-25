# Assembly File Cesar Encryption and Decryption Application
This Assembly program provides basic encryption and decryption functionalities for file handling. The intent of this application is to provide a simple, direct interface to experiment with file encryption and decryption using a pre-determined encryption key.

## Key Features
### Encryption
The application reads an existing file, iterates through its bytes, and performs a simple encryption operation by adding a value (the encryption key) to each byte's ASCII value. This operation results in a new encrypted byte sequence. The new sequence is then written to a new file, effectively encrypting the original file's contents.

### Decryption
The decryption feature performs the reverse operation of encryption. It reads an encrypted file (generated using this application's encryption function), iterates through the encrypted bytes, and subtracts the encryption key's value from each byte's ASCII value. This results in the original byte sequence before encryption, which is written to a new file, effectively decrypting the encrypted file's contents.

### Additional Features
The application includes a menu-driven user interface, where the user can choose to encrypt or decrypt files. At the program's start, it clears the terminal screen, presents the user with a menu of options including encrypting, decrypting, or exit. The user is then able to choose from the given options, key in the necessary input, and obtain the desired output.

## Running
Indeed, to compile and run this Assembly application involves following steps, which are typical for compiling and executing Assembly programs:

1. First, make sure you have NASM (The Netwide Assembler) installed on your system. NASM is an assembler for the x86 CPU architecture, and it is widely used for teaching Assembly Language.

2. Next, to compile your Assembly program, navigate to the directory where your Assembly file is located and use the following command:

    ```bash  nasm -f elf32 filename.asm -o output.o```
   Replace filename.asm with the name of your Assembly file and output.o with the name you wish to give to the output file.
3. After that, you will need to link the object file output.o that you get from the previous step, in order to create an executable. You can use gcc or ld for linking purpose:
   
    ```bash gcc -m32 output.o -o output```
   Replace output.o with the name of your object file and output with the name you wish to give to the executable file.

4. Now, the executable file may not have the permission to execute. To change the permission:

    ```bash chmod +x output```
   Replace output with the name of your executable file.

5. Finally, you can run your Assembly program as follows:
    ```bash ./output```

You can easily run using the ```run.sh``` also
   
## Conclusion
This assembly application offers a rudimentary, yet effective way to securely encrypt and decrypt files using a basic algorithm. It is a helpful tool for those who wish to understand the basic concepts of file encryption and decryption mechanisms.

Please note, due to the simplicity of the encryption algorithm, it is recommended to not use this application for serious or sensitive encryption tasks requiring high security.
