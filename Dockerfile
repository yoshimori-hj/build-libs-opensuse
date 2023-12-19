ARG VTK82=8.2.0
ARG VTK90=9.0.3
ARG VTK91=9.1.0
ARG VTK92=9.2.6
ARG VTK93=9.3.0
ARG TRI_13_0=13-0-1
ARG TRI_13_2=13-2-0
ARG TRI_13_4=13-4-1
ARG TRI_14_0=14-0-0
ARG TRI_14_2=14-2-0
ARG TRI_14_4=14-4-0
ARG NINJA_ARG="-l 18"
ARG PYTHON=311

ARG VTKHOST=https://www.vtk.org/files/release
ARG TRIHOST=https://github.com/trilinos/Trilinos/archive/refs/tags

ARG USE_MPICH=". /etc/profile.d/lmod.sh && module load gnu && module load mpich"
ARG USE_OMPI=". /etc/profile.d/lmod.sh && module load gnu && module load openmpi"

FROM opensuse/tumbleweed:latest AS base
ARG PYTHON
RUN zypper in -y tar gzip curl cmake ninja clang boost-devel libtiff-devel \
                 patch libOSMesa-devel Mesa-devel libqt5-qtbase-devel \
                 libXt-devel libXmu-devel proj-devel \
                 gcc gcc-c++ gcc-fortran \
                 gcc7 gcc7-c++ gcc7-fortran python${PYTHON}-devel \
                 lua-lmod openmpi4-gnu-hpc-devel mpich-gnu-hpc-devel \
                 blas-devel cblas-devel libopenblas-gnu-hpc-devel \
                 lapack-devel lapacke-devel \
                 hdf5-gnu-mpich-hpc-devel hdf5-gnu-openmpi4-hpc-devel

FROM opensuse/tumbleweed:latest AS vtksrc82
ARG VTK82
ARG VTKHOST
RUN cd /opt && curl -LO ${VTKHOST}/8.2/VTK-${VTK82}.tar.gz

FROM opensuse/tumbleweed:latest AS vtksrc90
ARG VTK90
ARG VTKHOST
RUN cd /opt && curl -LO ${VTKHOST}/9.0/VTK-${VTK90}.tar.gz

FROM opensuse/tumbleweed:latest AS vtksrc91
ARG VTK91
ARG VTKHOST
RUN cd /opt && curl -LO ${VTKHOST}/9.1/VTK-${VTK91}.tar.gz

FROM opensuse/tumbleweed:latest AS vtksrc92
ARG VTK92
ARG VTKHOST
RUN cd /opt && curl -LO ${VTKHOST}/9.2/VTK-${VTK92}.tar.gz

FROM opensuse/tumbleweed:latest AS vtksrc93
ARG VTK93
ARG VTKHOST
RUN cd /opt && curl -LO ${VTKHOST}/9.3/VTK-${VTK93}.tar.gz

FROM opensuse/tumbleweed:latest AS trilinossrc-13-0
ARG TRI_13_0
ARG TRIHOST
RUN cd /opt && curl -LO ${TRIHOST}/trilinos-release-${TRI_13_0}.tar.gz

FROM opensuse/tumbleweed:latest AS trilinossrc-13-2
ARG TRI_13_2
ARG TRIHOST
RUN cd /opt && curl -LO ${TRIHOST}/trilinos-release-${TRI_13_2}.tar.gz

FROM opensuse/tumbleweed:latest AS trilinossrc-13-4
ARG TRI_13_4
ARG TRIHOST
RUN cd /opt && curl -LO ${TRIHOST}/trilinos-release-${TRI_13_4}.tar.gz

FROM opensuse/tumbleweed:latest AS trilinossrc-14-0
ARG TRI_14_0
ARG TRIHOST
RUN cd /opt && curl -LO ${TRIHOST}/trilinos-release-${TRI_14_0}.tar.gz

FROM opensuse/tumbleweed:latest AS trilinossrc-14-2
ARG TRI_14_2
ARG TRIHOST
RUN cd /opt && curl -LO ${TRIHOST}/trilinos-release-${TRI_14_2}.tar.gz

FROM opensuse/tumbleweed:latest AS trilinossrc-14-4
ARG TRI_14_4
ARG TRIHOST
RUN cd /opt && curl -LO ${TRIHOST}/trilinos-release-${TRI_14_4}.tar.gz

FROM base AS vtk93
ARG VTK93
ARG USE_MPICH
ARG USE_OMPI
ARG NINJA_ARG
ARG VTK93ARGS="\
    -DCMAKE_C_COMPILER=gcc \
    -DCMAKE_CXX_COMPILER=g++ \
    -DCMAKE_Fortran_COMPILER=gfortran \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DBUILD_SHARED_LIBS=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_libproj=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_hdf5=ON \
    -DVTK_WRAP_PYTHON=ON \
    -DVTK_USE_MPI=ON \
    -DVTK_GROUP_ENABLE_MPI=DEFAULT \
    -DVTK_MODULE_ENABLE_VTK_IOParallelXML=YES \
    -DVTK_MODULE_ENABLE_VTK_IOParallelXdmf3=YES \
    -DVTK_MODULE_ENABLE_VTK_IOXdmf3=YES \
    -DVTK_MODULE_ENABLE_VTK_InfovisCore=YES"
WORKDIR /opt
COPY --from=vtksrc93 /opt/VTK-${VTK93}.tar.gz /opt
RUN tar xf VTK-${VTK93}.tar.gz
RUN eval "${USE_MPICH}" && module load phdf5 && \
    mkdir build-mpich && cd build-mpich && \
    export MPI_HOME="$MPI_DIR" && \
    cmake -S ../VTK-${VTK93} -B . \
    -DCMAKE_INSTALL_PREFIX=/opt/VTK/${VTK93}-mpich ${VTK93ARGS} -G Ninja || \
    cmake -S ../VTK-${VTK93} -B . -DMPI_C_COMPILE_OPTIONS= && \
    ninja ${NINJA_ARG} && ninja install
RUN eval "${USE_OMPI}" && module load phdf5 && \
    mkdir build-ompi && cd build-ompi && \
    export MPI_HOME="$MPI_DIR" && \
    cmake -S ../VTK-${VTK93} -B . \
    -DCMAKE_INSTALL_PREFIX=/opt/VTK/${VTK93}-ompi ${VTK93ARGS} -G Ninja && \
    ninja ${NINJA_ARG} && ninja install

FROM base AS vtk92
ARG VTK92
ARG USE_MPICH
ARG USE_OMPI
ARG NINJA_ARG
ARG P1=VTK-9857-rebased.patch
ARG VTK92ARGS="\
    -DCMAKE_C_COMPILER=gcc \
    -DCMAKE_CXX_COMPILER=g++ \
    -DCMAKE_Fortran_COMPILER=gfortran \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DBUILD_SHARED_LIBS=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_libproj=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_hdf5=ON \
    -DVTK_WRAP_PYTHON=ON \
    -DVTK_USE_MPI=ON \
    -DVTK_GROUP_ENABLE_MPI=DEFAULT \
    -DVTK_MODULE_ENABLE_VTK_IOParallelXML=YES \
    -DVTK_MODULE_ENABLE_VTK_IOParallelXdmf3=YES \
    -DVTK_MODULE_ENABLE_VTK_IOXdmf3=YES \
    -DVTK_MODULE_ENABLE_VTK_InfovisCore=YES"
WORKDIR /opt
COPY --from=vtksrc92 /opt/VTK-${VTK92}.tar.gz /opt
COPY ${P1} /opt/
RUN tar xf VTK-${VTK92}.tar.gz
RUN cd VTK-${VTK92} && patch --fuzz=0 -p1 < /opt/${P1}
RUN eval "${USE_MPICH}" && module load phdf5 && \
    mkdir build-mpich && cd build-mpich && \
    export MPI_HOME="$MPI_DIR" && \
    cmake -S ../VTK-${VTK92} -B . \
    -DCMAKE_INSTALL_PREFIX=/opt/VTK/${VTK92}-mpich ${VTK92ARGS} -G Ninja || \
    cmake -S ../VTK-${VTK92} -B . -DMPI_C_COMPILE_OPTIONS= && \
    ninja ${NINJA_ARG} && ninja install
RUN eval "${USE_OMPI}" && module load phdf5 && \
    mkdir build-ompi && cd build-ompi && \
    export MPI_HOME="$MPI_DIR" && \
    cmake -S ../VTK-${VTK92} -B . \
    -DCMAKE_INSTALL_PREFIX=/opt/VTK/${VTK92}-ompi ${VTK92ARGS} -G Ninja && \
    ninja ${NINJA_ARG} && ninja install

FROM base AS tri-13-4
ARG TRI_13_4
ARG USE_MPICH
ARG USE_OMPI
ARG NINJA_ARG
ARG TRI_13_4_ARGS="\
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_C_COMPILER=mpicc \
    -DCMAKE_CXX_COMPILER=mpic++ \
    -DCMAKE_Fortran_COMPILER=mpif90 \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DTPL_ENABLE_MPI=ON \
    -DMPI_BASE_DIR=${MPI_DIR} \
    -DMPI_USE_COMPILER_WRAPPERS=OFF \
    -DTrilinos_ENABLE_Zoltan2Core=ON"
ARG P1="Trilinos-11676.patch"
WORKDIR /opt
COPY --from=trilinossrc-13-4 /opt/trilinos-release-${TRI_13_4}.tar.gz /opt
COPY ${P1} /opt
RUN tar xf trilinos-release-${TRI_13_4}.tar.gz
RUN cd Trilinos-trilinos-release-${TRI_13_4} && patch -p1 --fuzz=0 < /opt/${P1}
RUN eval "${USE_MPICH}" && \
    mkdir build-mpich && cd build-mpich && \
    export MPI_HOME="$MPI_DIR" && \
    cmake -S ../Trilinos-trilinos-release-${TRI_13_4} -B . \
    -DCMAKE_INSTALL_PREFIX=/opt/trilinos/${TRI_13_4}-mpich ${TRI_13_4_ARGS} \
    -DCMAKE_C_FLAGS=-Wno-error=return-type \
    -DCMAKE_CXX_FLAGS=-Wno-error=return-type \
    -G Ninja && \
    ninja ${NINJA_ARG} && ninja install
RUN eval "${USE_OMPI}" && \
    mkdir build-ompi && cd build-ompi && \
    export MPI_HOME="$MPI_DIR" && \
    cmake -S ../Trilinos-trilinos-release-${TRI_13_4} -B . \
    -DCMAKE_INSTALL_PREFIX=/opt/trilinos/${TRI_13_4}-ompi ${TRI_13_4_ARGS} \
    -G Ninja && \
    ninja ${NINJA_ARG} && ninja install

#FROM base AS vtk82
#ARG VTK82
#ARG USE_MPICH
#ARG USE_OMPI
#ARG VTK82ARGS="\
#    -DBUILD_SHARED_LIBS=ON \
#    -DCMAKE_C_COMPILER=clang \
#    -DCMAKE_CXX_COMPILER=clang++ \
#    -DCMAKE_Fortran_COMPILER=gfortran \
#    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
#    -DVTK_Group_MPI=ON \
#    -DModule_vtkIOXdmf3=ON \
#    -DModule_vtkIOParallelXdmf3=ON \
#    -DVTK_USE_SYSTEM_HDF5=ON"
#ARG P1=VTK-8.2.0-gcc10.patch
#WORKDIR /opt
#COPY --from=vtksrc /opt/VTK-${VTK82}.tar.gz /opt
#RUN tar xf VTK-${VTK82}.tar.gz
#COPY ${P1} /opt
#RUN cd VTK-${VTK82}/ThirdParty/exodusII/vtkexodusII && \
#    patch -p1 --fuzz=0 < /opt/${P1}
#RUN eval "${USE_MPICH}" && module load phdf5 && \
#    mkdir build-mpich && cd build-mpich && \
#    cmake -S ../VTK-${VTK82} -B . \
#    -DCMAKE_INSTALL_PREFIX=/opt/VTK/${VTK82}-mpich ${VTK82ARGS} -G Ninja && \
#    ninja && ninja install
#RUN eval "${USE_OMPI}" && module load phdf5 && \
#    mkdir build-ompi && cd build-ompi && \
#    cmake -S ../VTK-${VTK82} -B . \
#    -DCMAKE_INSTALL_PREFIX=/opt/VTK/${VTK82}-ompi ${VTK82ARGS} -G Ninja && \
#    ninja && ninja install

FROM base AS final
ARG VTK82
ARG VTK90
ARG VTK91
ARG VTK92
ARG VTK93
ARG TRI_13_0
ARG TRI_13_2
ARG TRI_13_4
#COPY --from=vtk82 /opt/VTK/${VTK82}* /opt/
RUN mkdir /opt/VTK /opt/trilinos
COPY --from=vtk92 /opt/VTK/${VTK92}-ompi /opt/VTK/${VTK92}-ompi
COPY --from=vtk92 /opt/VTK/${VTK92}-mpich /opt/VTK/${VTK92}-mpich
COPY --from=vtk93 /opt/VTK/${VTK93}-ompi /opt/VTK/${VTK93}-ompi
COPY --from=vtk93 /opt/VTK/${VTK93}-mpich /opt/VTK/${VTK93}-mpich
COPY --from=tri-13-4 /opt/trilinos/${TRI_13_4}-ompi /opt/trilinos/${TRI_13_4}-ompi
COPY --from=tri-13-4 /opt/trilinos/${TRI_13_4}-mpich /opt/trilinos/${TRI_13_4}-mpich
