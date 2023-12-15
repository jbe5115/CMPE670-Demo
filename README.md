# CMPE670-Demo

Verilog tutorial: https://www.asic-world.com/verilog/veritut.html

## Working in Vivado
* Download Vivado 2019.1 and create a project, do not have your project folder be in the git repo folder
* Put it in a seperate folder on your local disk and point to the source files in the git repo when you make the project
* Add in all .v, .vhd, and .xdc files found under src to the project
* **Make sure to also uncheck "Copy sources into project" when adding the files to your project**
* Set target language to Verilog, simulator language to VHDL
* To add IP, click "IP Catalog" on flow naviagtor and search for "AXI-4 Stream Data FIFO"
* When you add the Xilinx IP AXIS FIFOs, give them maximum depth and enable almost empty, but do not enable almost full. (our FIFOs will be max size for convenience)
* Disable incremental compilation
* Disable/enable testbenches as desired when running simulations. Make sure testbenches are not marked for synthesis
* To run on hardware, synthesize and implement the design then generate a bitstream. Use top.xdc for constraints.
* Program the FPGA and use the singleBoard.m script to send UART data into the system.
* top.xdc provides more details on what switches, LEDs, and GPIO ports are used on the board. Connect the listed PMOD ports together with simple wires as mentioned.
* One wire is used for the datapath, another is used for ACK.

## Frame Specifications (as of 11/14/23)
* ODU Frame size: **4 rows, 1041 byte columns**
* The first 16 byte colums of each row will be overhead
* The next 1024 will be for image data
* The last byte column will be for an 8-bit CRC, which will only be inserted on the last row, the first three rows will have zeros in this column
* The first six bytes of every frame must be 0xF6F6F6282828 (in overhead)
* These sizes allow for the perfect fit of a 64 by 64 image (4096 bytes in payload)

## Sender Specifications
Some modules that will be in the sender (in general datapath order)
* **UART RX Module with AXI Stream Wrapper**
* **Xilinx AXI Stream FIFO** for RX direction

In most cases, a gearbox would be used at this point (to increase the data bus width from 8 bits to 512, 1024, etc. But if we keep our bus at 8 bits we will not need one.  This will require more cycles to map a frame but will make the logic significantly easier.
* **Frame Position Counter (FPC)**
  * This module will take in the incoming data from the FIFO (along with valid) and map it into the ODU frame.
  * It will take in the current frame position (row and column) and based on this, either map the incoming data and output it or output overhead.
  * It will also output the additional 1 byte column at the end of each row, but will **NOT** calculate the CRC
* **CRC Calculator**
  * CRC polynomial coefficients: x^8 + x^2 + x + 1
  * After mapped data leaves the frame controller, it must be sent directly to the CRC calculator
  * Like the frame controller, the CRC calculator will also take in the current frame row and column counts, but with an extra clock cycle delay
  * The CRC is **ONLY** calculated on the payload of the frame, not overhead
  * Use the input row and col data to know when to calculate
  * For calculation, we will be using an LFSR (linear feedback shift register)
* **Data Request**
  * Based on the current row and frame data from the FPC, the data request module will basically control our "AXI Stream Ready" that communicates with the FIFO.
  *   It will know when to request more data based on if the FIFO is empty or not, if the current frame position is overhead, etc.

The overall structure of the sender takes on sort of a "pipelined" approach where our data "flows" through it.

**Insert high level diagram here**

## Receiver Specifications
* **Frame Position Counter (FPC)**
  * Same as in mapper, except it is used for demapping now
* **CRC Calculator and Checker**
  * Same module as in the mapper but extra logic will be needed to **check the CRC** after it has been fully calculated at the end of a frame
  * Compare the calculated CRC with the one located inside of the demapped frame and assert a signal indicating a mismatch
  * Will need the FPC data
* **Demap Frame Controller/Data Write Enable**
  * After passing through the CRC Calculator/Checker, this module will undo exactly what is done in the mapper's frame controller
  * It will extract the payload from the incoming frame data and output it
  * Will need the (delayed) FPC data
* **Xilinx AXI Stream FIFO** for the TX direction
* **UART TX Module with AXI Stream Wrapper**

## ARQ Handshake Specifications
* The sender (mapper FPGA) must save the data in some sort of memory as it transmits to the receiver (demapper FPGA)
* If the sender must retransmit, it will transmit out of the memory, rather than the data coming out of the mapper
  * The mapper will be idle during this time and will **NOT** request data from the RX FIFO
* For our implementation, some sort of ACK must be sent from the receiver to the sender, indicating that the frame transmission was successful
  * This could be a two-bit ACK (one value indicating success, another failure) **OR** just a single bit ACK to indicate success
  * If single bit ACK is implemented (which follows the stop-and-wait ARQ procedure) then no ACK would indicate failure.  This would require "timeout" logic on the sender interface 

## Hardware Specifications
* Each FPGA (mapper or demapper) will display the current calculated CRC in the module on the FPGA itself
  * If the CRC stays at 8 bits, we won't have to use the 7-segment display, instead we can use LEDs on the board
* For demonstration purposes a switch on the demapper FPGA will enable/disable "data corruption" as data comes into the demapper
* Another switch will enable the ARQ handshaking process
* Two wires will connect the FPGAs
  * One will be the main "optical fiber cable" that will send frame data to the demapper
  * Anoter will be the "ACK" cable which will send acknowledgements to the mapper FPGA indicating successful/unsuccessful frame transmission
* The Nexsys4 DDR Pmod ports will be used to transmit data between the FPGAs

## Verification Specifications
* Basic testbench for mapper, maybe include self-checking using assertions
* Testbench for mapper and demapper, include self-checking
* Try to keep test data uinque but also readable.  For example, for every payload byte sent into the mapper, increase the value by 1. Ex: Send in 0x01, then 0x02, etc.
* **Implemented in VHDL**

## Cases to be Tested
* **Sender Testbench**
  * Normal operation with no corruption and no ARQ enabled
  * Normal operation with corruption and no ARQ enabled
  * Normal operation with corruption and ARQ enabled
  * *There is a procedure for each of these situations*
* **Top Level Sender & Receiver Testbench**
  * Same as above
  * Should receive the UART data from the receiver and write to a text file
  * Original and received text files can be compared
