# CMPE670-Demo

Verilog tutorial: https://www.asic-world.com/verilog/veritut.html

## Working in Vivado:
* Do not have your project folder be in the git repo folder
* Put it in a seperate folder on your local disk and point to the source files in the git repo when you make the project
* **Make sure to also uncheck "Copy sources into project" when adding the files to your project**
* Set target language to Verilog, simulator language to mixed
* When you add the Xilinx IP AXIS FIFOs, give them maximum depth and enable almost empty, but do not enable almoxt full. (our FIFOs will be max size)
* Disable incremental compilation
