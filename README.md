# Docker image of the IBM Platform-Independent Software Analysis

This Docker image aims to provide the installed and equipped [IBM Platform-Independent Software Analysis]
tool ready to be used.

Please, visit the [official repository] for further details.


#### IBM Platform-Independent Software Analysis

> IBM Platform-Independent Software Analysis is a framework based on the
> [LLVM compiler infrastructure] that analyzes C/C++ and Fortran code at
> instruction, basic block and function level at application run-time.
> Its objective is to generate a software model for sequential and parallel
> (OpenMP and MPI) applications in a hardware-independent manner. Two examples of
> use cases for this framework are:
>
>   - Hardware-agnostic software characterization to support design decision to
>    match hardware designs to applications.
>   - Hardware design-space exploration studies by combining the software model
>    with hardware performance models.
>
> IBM Platform-Independent Software Analysis characterizes applications per thread
> and process and measures software properties such as: instruction-level
> parallelism, flow-control behavior, memory access pattern, and inter-process
> communication behavior.
>
> A detailed description of the IBM Platform-Independent Software Analysis tool
> can be found here: [IBM-PISA IJPP Paper].
>
> More related publications are listed here: [IBM-PISA-related projects].

## Prerequisites

- latest Docker version

To install Docker please refer to the [official Docker installation page].


## Usage

**It is not required nor to clone the current repository nor to build the image 
before to use it.**

```bash
cd /folder-of-your-source-code
# being inside your source code folder

# get the run script
wget https://raw.githubusercontent.com/nyxgear/ibm-pisa/master/run-ibm-pisa.sh

# make it executable
chmod u+x ./run-ibm-pisa.sh

# run it
./run-ibm-pisa.sh
```
The `run-ibm-pisa.sh` script will take care automatically on the first execution
to download the image from the Docker Hub repository.

Then, **each time you want to enter into the container** and *use all the 
IBM-PISA functionalities*, just execute:
```bash
./run-ibm-pisa.sh
```

Once inside the the running container, the directory you'll be into will be the 
mounted version of the the directory you triggered the `./run-ibm-pisa.sh` 
script from. This means that all the files that were in the directory from which
you run the script are now available in the current directory (inside the 
container).

***TIP** Move the `run-ibm-pisa.sh` script in the directory you more prefer and 
execute it to mount that directory inside the container and use IBM-PISA 
functionalities.*


#### Startup hook

In addition to the `./run-ibm-pisa.sh` script you can exploit an additional hook
script that is executed **at first, each time** the container is run.

Requirements for the hook script:
- file name: `docker-startup-hook.sh`
- file placed exactly in the same same directory of the  `run-ibm-pisa.sh` script

To start from an example:
```bash
cd /folder-of-your-source-code
# being inside your source code folder

# get the docker-startup-hook.sh example
wget https://raw.githubusercontent.com/nyxgear/ibm-pisa/master/docker-startup-hook.sh
```


## Build the image

If you want to build the image by yourself without exploiting the pre-built one 
available on Docker Hub
```bash
# clone the repository
git clone git@github.com:nyxgear/ibm-pisa.git

cd ibm-pisa

# build and squash
docker build --squash --tag nyxgear/ibm-pisa:latest -f Dockerfile .
```
***WARNING:** Usually, it takes long time to build the entire image.*


## Docker Hub repository

A build of this image can be found at [nyxgear/ibm-pisa] on Docker Hub.


## Project context

This project has been developed for the [Advanced Computer Architecture course]
(A.Y. 2017/2018) at Politecnico di Milano.

[IBM-PISA Docker Image - Project presentation slides]


[IBM Platform-Independent Software Analysis]: https://github.com/exabounds/ibm-pisa
[official repository]: https://github.com/exabounds/ibm-pisa
[LLVM compiler infrastructure]: http://llvm.org/
[IBM-PISA IJPP Paper]: https://doi.org/10.1007/s10766-016-0410-0
[IBM-PISA-related projects]: http://researcher.watson.ibm.com/researcher/view_group_pubs.php?grp=6395
[official Docker installation page]: https://docs.docker.com/install
[nyxgear/ibm-pisa]: https://hub.docker.com/r/nyxgear/ibm-pisa
[Advanced Computer Architecture course]: https://www4.ceda.polimi.it/manifesti/manifesti/controller/ManifestoPublic.do?EVN_DETTAGLIO_RIGA_MANIFESTO=evento&aa=2017&k_cf=225&k_corso_la=481&k_indir=T2A&codDescr=088949&lang=IT&semestre=2&anno_corso=1&idItemOfferta=131292&idRiga=216832
[IBM-PISA Docker Image - Project presentation slides]: https://docs.google.com/presentation/d/1i6IzoTgxiVove5Bx0kXW_QS9FhbaG_RBzOjswrP3nwE

