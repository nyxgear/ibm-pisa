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



## Automated build

This image is automatically built on Docker Hub at [nyxgear/ibm-pisa].


### Automated build chain

The compilation and installation process of the IBM-PISA tool takes long time.
Due to the free-quota time limits of builds on Docker Hub, an automated chain
of sequential build stages has been created.

A build stage is actually a single separated Docker image which is FROM the stage
before and which constitutes the base for the succeeding stage.

It correspond to each single stage:

- one single separated git branch of this repository
- one single separated Dockerfile
- one single separated Docker image version of the main ibm-pisa image

The `stage-0` is the first stage. The `latest` version of the image is actually the 
main complete ibm-pisa Docker image that is intended for use.


## Project context

This project has been developed for the [Advanced Computer Architecture course] 
(A.Y. 2017/2018) at Politecnico di Milano.


[IBM Platform-Independent Software Analysis]: https://github.com/exabounds/ibm-pisa
[official repository]: https://github.com/exabounds/ibm-pisa
[LLVM compiler infrastructure]: http://llvm.org/
[IBM-PISA-related projects]: http://researcher.watson.ibm.com/researcher/view_group_pubs.php?grp=6395
[IBM-PISA IJPP Paper]: https://doi.org/10.1007/s10766-016-0410-0
[nyxgear/ibm-pisa]: https://hub.docker.com/r/nyxgear/nyxgear/ibm-pisa/
[Advanced Computer Architecture course]: https://www4.ceda.polimi.it/manifesti/manifesti/controller/ManifestoPublic.do?EVN_DETTAGLIO_RIGA_MANIFESTO=evento&aa=2017&k_cf=225&k_corso_la=481&k_indir=T2A&codDescr=088949&lang=IT&semestre=2&anno_corso=1&idItemOfferta=131292&idRiga=216832

