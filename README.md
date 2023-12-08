# CMPE670-Demo

Verilog tutorial: https://www.asic-world.com/verilog/veritut.html

## Working in Vivado
* Do not have your project folder be in the git repo folder
* Put it in a seperate folder on your local disk and point to the source files in the git repo when you make the project
* **Make sure to also uncheck "Copy sources into project" when adding the files to your project**
* Set target language to Verilog, simulator language to mixed
* When you add the Xilinx IP AXIS FIFOs, give them maximum depth and enable almost empty, but do not enable almoxt full. (our FIFOs will be max size)
* Disable incremental compilation

## Frame Specifications (as of 11/14/23)
* ODU Frame size: **4 rows, 1041 byte columns**
* The first 16 byte colums of each row will be overhead
* The next 1024 will be for image data
* The last byte column will be for an 8-bit CRC, which will only be inserted on the last row, the first three rows will have zeros in this column
* The first six bytes of ever frame must be 0xF6F6F6282828 (in overhead)
* These sizes allow for the perfect fit of a 64 by 46 image (4096 bytes in payload)

## Mapper Specifications
Some modules that will be in the mapper (in general datapath order)
* **UART RX Module with AXI Stream Wrapper**
* **Xilinx AXI Stream FIFO** for RX direction
In most cases, a gearbox would be used at this point (to increase the data bus width from 8 bits to 512, 1024, etc. But if we keep our bus at 8 bits we willnot need one.  This will require more cycles to map a frame but will make the logic significantly easier.
* **Frame Position Counter (FPC)** this module will take in the incoming data from the FIFO (along with valid) and map it into the ODU frame.  It will take in the current frame position (row and column) and based on this, either map the incoming data and output it or output overhead.  It will also output the additional 1 byte column at the end of each row, but will **NOT** calculate the CRC
* **CRC Calculator**
*  After mapped data leaves the frame controller, it must be sent directly to the CRC calculator
*  Like the frame controller, the CRC calculator will also take in the current frame row and column counts, but with an extra clock cycle delay
*  The CRC is **ONLY** calculated on the payload of the frame, not overhead
*  Use the input row and col data to know when to calculate
*  For calculation, we will be using an LFSR (linear feedback shift register)
* **Data Request** based on the current row and frame data from the FPC, the data request module will basically control our "AXI Stream Ready" that communicates with the FIFO.  It will know when to request more data based on if the FIFO is empty or not, if the current frame position is overhead, etc.
* **ARQ Interface** more details below
The overall structure of the mapper takes on sort of a "piplined" approach where our data "flows" through it.  The demapper will be EXTREMELY similar and probably more simple.

**Insert high level diagram here**
