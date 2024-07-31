This is part of a bigger project to emulate an NES (Nintendo Entertainment System). 

NES uses R2A03 CPU designed by Ricoh, however this uses the circuit for 6502 CPU with just a few differences:
- No differences were found in the instruction decoder
- Flag D works as expected, it can be set or reset by CLD/SED instructions; it is used in the normal way during interrupt processing (saved on stack) and after execution of PHP/PLP, RTI instructions.
- Random logic, responsible for generating the two control lines DAA (decimal addition adjust) and DSA (decimal subtraction adjust) works normally.

https://forums.nesdev.org/viewtopic.php?t=9813

<h2>Start project in Vivado</h2>

1. Clone repository
```
git clone https://github.com/Danielvagyok/emulator_6502.git
cd emulator_6502
```
2. (Optional) Set alias for Vivado <br>
    - **Linux**:

    ```bash
    echo "alias vivado=\"path/to/Xilinx/Vivado/2024.1/bin/vivado\"" >> ~/.bashrc
    source ~/.bashrc
    ```

    - **Windows**:

    ```powershell
    echo "Set-Alias -Name vivado -Value path\to\Xilinx\Vivado\2024.1\bin\vivado" >> $profile
    . $profile
    ```

    &emsp; *Note 1*: If $profile file does not exist, create it
    ```powershell
    New-Item -Force -Path $profile
    ```

    &emsp; *Note 2*: If scripts cannot be executed on your system, then open PowerShell in Administrator mode and change Execution Policy
    ```powershell
    set-executionpolicy remotesigned
    ```

3. Build with Tcl script
```
vivado -source rebuild.tcl
```

<br><br>
Better description and Copyright for the project is soon to come.
