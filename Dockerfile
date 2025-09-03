ARG VTK82=8.2.0
ARG VTK90=9.0.3
ARG VTK91=9.1.0
ARG VTK92=9.2.6
ARG VTK93=9.3.1
ARG VTK94=9.4.2
ARG VTK95=9.5.1
ARG TRI_13_0=13-0-1
ARG TRI_13_2=13-2-0
ARG TRI_13_4=13-4-1
ARG TRI_14_0=14-0-0
ARG TRI_14_2=14-2-0
ARG TRI_14_4=14-4-0
ARG TRI_15_1=15-1-1
ARG TRI_16_1=16-1-0
ARG PV_5_12=5.12.0
ARG PV_5_13=5.13.2
ARG PV_6_0=6.0.0
ARG LAMMPS_22Jul2025=stable_22Jul2025_update1
ARG NINJA_ARG="-l 18"
ARG PYTHON=311
ARG PYTHONEXEC=/usr/bin/python3.11
ARG MIRROR=http://ftp.riken.jp/Linux/opensuse
ARG OPENMPI=openmpi4 # or openmpi5
ARG USE_OMPI="source /usr/lib64/mpi/gcc/${OPENMPI}/bin/mpivars.sh"

ARG VTKHOST=https://www.vtk.org/files/release
ARG TRIHOST=https://github.com/trilinos/Trilinos/archive/refs/tags

FROM opensuse/tumbleweed:latest AS ref
ARG MIRROR
RUN sed -i~ -e "s|http://download.opensuse.org|${MIRROR}|" \
    /etc/zypp/repos.d/repo-oss.repo \
    /etc/zypp/repos.d/repo-non-oss.repo
RUN zypper ref
RUN zypper dup -y

FROM ref AS base
ARG PYTHON
ARG OPENMPI
RUN zypper in -y tar gzip curl cmake ninja clang boost-devel                 \
                 libtiff-devel patch Mesa-devel                              \
                 libqt5-qtbase-devel libqt5-linguist-devel                   \
                 libqt5-qt3d-devel libqt5-qtbase-common-devel                \
                 libqt5-qtbase-devel libqt5-qtconnectivity-devel             \
                 libqt5-qtdeclarative-devel libqt5-qtdoc-devel               \
                 libqt5-qtgamepad-devel libqt5-qtimageformats-devel          \
                 libqt5-qtlocation-devel libqt5-qtmultimedia-devel           \
                 libqt5-qtnetworkauth-devel libqt5-qtpdf-devel               \
                 libqt5-qtquick3d-devel libqt5-qtremoteobjects-devel         \
                 libqt5-qtscript-devel libqt5-qtscxml-devel                  \
                 libqt5-qtsensors-devel libqt5-qtserialbus-devel             \
                 libqt5-qtserialport-devel libqt5-qtspeech-devel             \
                 libqt5-qtstyleplugins-devel libqt5-qtsvg-devel              \
                 libqt5-qttools-devel libqt5-qtvirtualkeyboard-devel         \
                 libqt5-qtwayland-devel libqt5-qtwebchannel-devel            \
                 libqt5-qtwebengine-devel libqt5-qtwebsockets-devel          \
                 libqt5-qtwebview-devel libqt5-qtx11extras-devel             \
                 libqt5-qtxmlpatterns-devel git libXt-devel libXcursor-devel \
                 libXmu-devel proj-devel gcc gcc-c++ gcc-fortran gcc7        \
                 gcc7-c++ gcc7-fortran gcc13 gcc13-c++ gcc13-fortran \
                 python${PYTHON}-devel \
                 ${OPENMPI}-devel blas-devel cblas-devel netcdf-devel        \
                 openblas-common-devel lapack-devel lapacke-devel            \
                 hdf5-${OPENMPI}-devel

FROM ref AS git
RUN zypper in -y git

FROM git AS vtksrc
RUN mkdir /opt/src && cd /opt/src && \
    git clone --recursive https://gitlab.kitware.com/vtk/vtk.git

FROM git AS pvsrc
RUN mkdir /opt/src && cd /opt/src && \
    git clone --recursive https://gitlab.kitware.com/paraview/paraview.git

FROM git AS trilinossrc
RUN mkdir /opt/src && cd /opt/src && \
    git clone --recursive https://github.com/trilinos/Trilinos.git

FROM git AS lammpssrc
RUN mkdir /opt/src && cd /opt/src && \
    git clone --recursive https://github.com/lammps/lammps.git

FROM vtksrc AS vtksrc82
ARG VTK82
RUN cd /opt/src/vtk && git checkout v${VTK82} && \
    git submodule update --init --recursive

FROM vtksrc AS vtksrc90
ARG VTK82
RUN cd /opt/src/vtk && git checkout v${VTK90} && \
    git submodule update --init --recursive

FROM vtksrc AS vtksrc91
ARG VTK91
RUN cd /opt/src/vtk && git checkout v${VTK91} && \
    git submodule update --init --recursive

FROM vtksrc AS vtksrc92
ARG VTK92
RUN cd /opt/src/vtk && git checkout v${VTK92} && \
    git submodule update --init --recursive

FROM vtksrc AS vtksrc93
ARG VTK93
RUN cd /opt/src/vtk && git checkout v${VTK93} && \
    git submodule update --init --recursive

FROM vtksrc AS vtksrc94
ARG VTK94
RUN cd /opt/src/vtk && git checkout v${VTK94} && \
    git submodule update --init --recursive

FROM vtksrc AS vtksrc95
ARG VTK95
RUN cd /opt/src/vtk && git checkout v${VTK95} && \
    git submodule update --init --recursive

FROM trilinossrc AS trilinossrc-13-0
ARG TRI_13_0
RUN cd /opt/src/Trilinos && git checkout trilinos-release-${TRI_13_0} && \
    git submodule update --init --recursive

FROM trilinossrc AS trilinossrc-13-2
ARG TRI_13_2
RUN cd /opt/src/Trilinos && git checkout trilinos-release-${TRI_13_2} && \
    git submodule update --init --recursive

FROM trilinossrc AS trilinossrc-13-4
ARG TRI_13_4
RUN cd /opt/src/Trilinos && git checkout trilinos-release-${TRI_13_4} && \
    git submodule update --init --recursive

FROM trilinossrc AS trilinossrc-14-0
ARG TRI_14_0
RUN cd /opt/src/Trilinos && git checkout trilinos-release-${TRI_14_0} && \
    git submodule update --init --recursive

FROM trilinossrc AS trilinossrc-14-2
ARG TRI_14_2
RUN cd /opt/src/Trilinos && git checkout trilinos-release-${TRI_14_2} && \
    git submodule update --init --recursive

FROM trilinossrc AS trilinossrc-14-4
ARG TRI_14_4
RUN cd /opt/src/Trilinos && git checkout trilinos-release-${TRI_14_4} && \
    git submodule update --init --recursive

FROM trilinossrc AS trilinossrc-15-1
ARG TRI_15_1
RUN cd /opt/src/Trilinos && git checkout trilinos-release-${TRI_15_1} && \
    git submodule update --init --recursive

FROM trilinossrc AS trilinossrc-16-1
ARG TRI_16_1
RUN cd /opt/src/Trilinos && git checkout trilinos-release-${TRI_16_1} && \
    git submodule update --init --recursive

FROM pvsrc AS pvsrc-5-12
ARG PV_5_12
RUN cd /opt/src/paraview && git checkout v${PV_5_12} && \
    git submodule update --init --recursive

FROM pvsrc AS pvsrc-5-13
ARG PV_5_13
RUN cd /opt/src/paraview && git checkout v${PV_5_13} && \
    git submodule update --init --recursive

FROM pvsrc AS pvsrc-6-0
ARG PV_6_0
RUN cd /opt/src/paraview && git checkout v${PV_6_0} && \
    git submodule update --init --recursive

FROM lammpssrc AS lammpssrc-22jul2025
ARG LAMMPS_22Jul2025
RUN cd /opt/src/lammps && git checkout ${LAMMPS_22Jul2025} && \
    git submodule update --init --recursive

FROM base AS vtk95
ARG VTK95
ARG USE_OMPI
ARG NINJA_ARG
ARG PYTHONEXEC
ARG VTK95ARGS="\
    -DCMAKE_C_COMPILER=gcc-13 \
    -DCMAKE_CXX_COMPILER=g++-13 \
    -DCMAKE_Fortran_COMPILER=gfortran-13 \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DPython3_EXECUTABLE=${PYTHONEXEC} \
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
COPY --from=vtksrc94 /opt/src/vtk /opt/src/vtk
RUN ${USE_OMPI} && mkdir build-ompi && cd build-ompi && \
    export MPI_HOME="$MPI_DIR" && \
    cmake -S ../src/vtk -B . \
    -DCMAKE_INSTALL_PREFIX=/opt/VTK/${VTK95}-ompi ${VTK95ARGS} -G Ninja && \
    ninja ${NINJA_ARG} && ninja install

FROM base AS vtk94
ARG VTK94
ARG USE_OMPI
ARG NINJA_ARG
ARG PYTHONEXEC
ARG VTK94ARGS="\
    -DCMAKE_C_COMPILER=gcc-13 \
    -DCMAKE_CXX_COMPILER=g++-13 \
    -DCMAKE_Fortran_COMPILER=gfortran-13 \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DPython3_EXECUTABLE=${PYTHONEXEC} \
    -DBUILD_SHARED_LIBS=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_libproj=ON \
    -DVTK_WRAP_PYTHON=ON \
    -DVTK_USE_MPI=ON \
    -DVTK_GROUP_ENABLE_MPI=DEFAULT \
    -DVTK_MODULE_ENABLE_VTK_IOParallelXML=YES \
    -DVTK_MODULE_ENABLE_VTK_IOParallelXdmf3=YES \
    -DVTK_MODULE_ENABLE_VTK_IOXdmf3=YES \
    -DVTK_MODULE_ENABLE_VTK_InfovisCore=YES"
WORKDIR /opt
COPY --from=vtksrc94 /opt/src/vtk /opt/src/vtk
RUN ${USE_OMPI} && mkdir build-ompi && cd build-ompi && \
    export MPI_HOME="$MPI_DIR" && \
    cmake -S ../src/vtk -B . \
    -DCMAKE_INSTALL_PREFIX=/opt/VTK/${VTK94}-ompi ${VTK94ARGS} -G Ninja && \
    ninja ${NINJA_ARG} && ninja install

FROM base AS vtk93
ARG VTK93
ARG USE_OMPI
ARG NINJA_ARG
ARG PYTHONEXEC
ARG VTK93ARGS="\
    -DCMAKE_C_COMPILER=gcc-13 \
    -DCMAKE_CXX_COMPILER=g++-13 \
    -DCMAKE_Fortran_COMPILER=gfortran-13 \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DBUILD_SHARED_LIBS=ON \
    -DPython3_EXECUTABLE=${PYTHONEXEC} \
    -DVTK_MODULE_USE_EXTERNAL_VTK_libproj=ON \
    -DVTK_WRAP_PYTHON=ON \
    -DVTK_USE_MPI=ON \
    -DVTK_GROUP_ENABLE_MPI=DEFAULT \
    -DVTK_MODULE_ENABLE_VTK_IOParallelXML=YES \
    -DVTK_MODULE_ENABLE_VTK_IOParallelXdmf3=YES \
    -DVTK_MODULE_ENABLE_VTK_IOXdmf3=YES \
    -DVTK_MODULE_ENABLE_VTK_InfovisCore=YES"
WORKDIR /opt
COPY --from=vtksrc93 /opt/src/vtk /opt/src/vtk
RUN ${USE_OMPI} && mkdir build-ompi && cd build-ompi && \
    export MPI_HOME="$MPI_DIR" && \
    cmake -S ../src/vtk -B . \
    -DCMAKE_INSTALL_PREFIX=/opt/VTK/${VTK93}-ompi ${VTK93ARGS} -G Ninja && \
    ninja ${NINJA_ARG} && ninja install

FROM base AS vtk92
ARG VTK92
ARG USE_OMPI
ARG NINJA_ARG
ARG PYTHONEXEC
ARG P1=VTK-9857-rebased.patch
ARG VTK92ARGS="\
    -DCMAKE_C_COMPILER=gcc-7 \
    -DCMAKE_CXX_COMPILER=g++-7 \
    -DCMAKE_Fortran_COMPILER=gfortran-7 \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DPython3_EXECUTABLE=${PYTHONEXEC} \
    -DBUILD_SHARED_LIBS=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_libproj=ON \
    -DVTK_WRAP_PYTHON=ON \
    -DVTK_USE_MPI=ON \
    -DVTK_GROUP_ENABLE_MPI=DEFAULT \
    -DVTK_MODULE_ENABLE_VTK_IOParallelXML=YES \
    -DVTK_MODULE_ENABLE_VTK_IOParallelXdmf3=YES \
    -DVTK_MODULE_ENABLE_VTK_IOXdmf3=YES \
    -DVTK_MODULE_ENABLE_VTK_InfovisCore=YES"
WORKDIR /opt
COPY --from=vtksrc92 /opt/src/vtk /opt/src/vtk
COPY ${P1} /opt/
RUN cd src/vtk && patch --fuzz=0 -p1 < /opt/${P1}
RUN ${USE_OMPI} && mkdir build-ompi && cd build-ompi && \
    export MPI_HOME="$MPI_DIR" && \
    cmake -S ../src/vtk -B . \
    -DCMAKE_INSTALL_PREFIX=/opt/VTK/${VTK92}-ompi ${VTK92ARGS} -G Ninja && \
    ninja ${NINJA_ARG} && ninja install

FROM base AS vtk82
ARG VTK82
ARG USE_OMPI
ARG VTK82ARGS="\
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_C_COMPILER=gcc-7 \
    -DCMAKE_CXX_COMPILER=g++-7 \
    -DCMAKE_Fortran_COMPILER=gfortran-7 \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DVTK_Group_MPI=ON \
    -DModule_vtkIOXdmf3=ON \
    -DModule_vtkIOParallelXdmf3=ON"
WORKDIR /opt
COPY --from=vtksrc82 /opt/src/vtk /opt/src/vtk
RUN ${USE_OMPI} && mkdir build-ompi && cd build-ompi && \
    cmake -S ../src/vtk -B . \
    -DCMAKE_INSTALL_PREFIX=/opt/VTK/${VTK82}-ompi ${VTK82ARGS} -G Ninja && \
    ninja ${NINJA_ARG} && ninja install

FROM base AS pv-6-0
ARG PV_6_0
ARG USE_OMPI
ARG NINJA_ARGS
ARG PYTHONEXEC
ARG PV_6_0_ARGS="\
    -DCMAKE_C_COMPILER=gcc \
    -DCMAKE_CXX_COMPILER=g++ \
    -DCMAKE_Fortran_COMPILER=gfortran \
    -DCMAKE_BUILD_TYPE=Release \
    -DPython3_EXECUTABLE=${PYTHONEXEC} \
    -DPARAVIEW_BUILD_SHARED_LIBS=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_libproj=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_hdf5=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_netcdf=ON \
    -DPARAVIEW_USE_MPI=ON \
    -DPARAVIEW_USE_PYTHON=ON \
    -DPARAVIEW_BUILD_ALL_MODULES=ON"
WORKDIR /opt
COPY --from=pvsrc-6-0 /opt/src/paraview /opt/src/paraview
RUN ${USE_OMPI} && mkdir build-ompi && cd build-ompi && \
    export MPI_HOME="$MPI_DIR" && \
    cmake -S ../src/paraview -B . \
    -DCMAKE_INSTALL_PREFIX=/opt/paraview/${PV_6_0}-ompi ${PV_6_0_ARGS} -G Ninja && \
    ninja ${NINJA_ARGS} && ninja install

FROM base AS pv-5-13
ARG PV_5_13
ARG USE_OMPI
ARG NINJA_ARGS
ARG PYTHONEXEC
ARG PV_5_13_ARGS="\
    -DCMAKE_C_COMPILER=gcc-13 \
    -DCMAKE_CXX_COMPILER=g++-13 \
    -DCMAKE_Fortran_COMPILER=gfortran-13 \
    -DCMAKE_BUILD_TYPE=Release \
    -DPython3_EXECUTABLE=${PYTHONEXEC} \
    -DPARAVIEW_BUILD_SHARED_LIBS=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_libproj=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_hdf5=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_netcdf=ON \
    -DPARAVIEW_USE_MPI=ON \
    -DPARAVIEW_USE_PYTHON=ON \
    -DPARAVIEW_BUILD_ALL_MODULES=ON"
WORKDIR /opt
COPY --from=pvsrc-5-13 /opt/src/paraview /opt/src/paraview
RUN ${USE_OMPI} && mkdir build-ompi && cd build-ompi && \
    export MPI_HOME="$MPI_DIR" && \
    cmake -S ../src/paraview -B . \
    -DCMAKE_INSTALL_PREFIX=/opt/paraview/${PV_5_13}-ompi ${PV_5_13_ARGS} -G Ninja && \
    ninja ${NINJA_ARGS} && ninja install

FROM base AS pv-5-12
ARG PV_5_12
ARG USE_OMPI
ARG NINJA_ARGS
ARG PYTHONEXEC
ARG PV_5_12_ARGS="\
    -DCMAKE_C_COMPILER=gcc-13 \
    -DCMAKE_CXX_COMPILER=g++-13 \
    -DCMAKE_Fortran_COMPILER=gfortran-13 \
    -DCMAKE_BUILD_TYPE=Release \
    -DPython3_EXECUTABLE=${PYTHONEXEC} \
    -DPARAVIEW_BUILD_SHARED_LIBS=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_libproj=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_hdf5=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_netcdf=ON \
    -DPARAVIEW_USE_MPI=ON \
    -DPARAVIEW_USE_PYTHON=ON \
    -DPARAVIEW_BUILD_ALL_MODULES=ON"
WORKDIR /opt
COPY --from=pvsrc-5-12 /opt/src/paraview /opt/src/paraview
RUN ${USE_OMPI} && mkdir build-ompi && cd build-ompi && \
    export MPI_HOME="$MPI_DIR" && \
    cmake -S ../src/paraview -B . \
    -DCMAKE_INSTALL_PREFIX=/opt/paraview/${PV_5_12}-ompi ${PV_5_12_ARGS} -G Ninja && \
    ninja ${NINJA_ARGS} && ninja install

FROM base AS tri-13-4
ARG TRI_13_4
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
COPY --from=trilinossrc-13-4 /opt/src/Trilinos /opt/src/Trilinos
COPY ${P1} /opt
RUN cd src/Trilinos && patch -p1 --fuzz=0 < /opt/${P1}
RUN ${USE_OMPI} && mkdir build-ompi && cd build-ompi && \
    export OMPI_CC=gcc-7 && \
    export OMPI_CXX=g++-7 && \
    export MPI_HOME="$MPI_DIR" && \
    cmake -S ../src/Trilinos -B . \
    -DCMAKE_INSTALL_PREFIX=/opt/trilinos/${TRI_13_4}-ompi ${TRI_13_4_ARGS} \
    -G Ninja && \
    ninja ${NINJA_ARG} && ninja install

FROM base AS lammps-22jul2025
ARG LAMMPS_22Jul2025
ARG USE_OMPI
ARG NINJA_ARG
ARG LAMMPS_22Jul2025_ARGS="\
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TESTING=ON \
    -DBUILD_TOOLS=ON \
    -DBUILD_MPI=ON \
    -DBUILD_OMP=ON \
    -DCMAKE_C_COMPILER=gcc-13 \
    -DCMAKE_CXX_COMPILER=g++-13 \
    -DCMKAE_BUILD_TYPE=RelWithDebInfo \
    -DLAMMPS_INSTALL_RPATH=ON \
    -DPKG_DOC=ON \
    -DPKG_GRANULAR=ON \
    -DPKG_TALLY=ON \
    -DPKG_VTK=ON"
WORKDIR /opt
COPY --from=lammpssrc-22jul2025 /opt/src/lammps /opt/src/lammps
COPY --from=vtk82 /opt/VTK/8.2.0-ompi /opt/VTK/8.2.0-ompi
RUN ${USE_OMPI} && mkdir build-ompi && cd build-ompi && \
    cmake -S ../src/lammps/cmake -B . \
    -DCMAKE_INSTALL_PREFIX=/opt/lammps/${LAMMPS_22Jul2025}-ompi \
    ${LAMMPS_22Jul2025_ARGS} -DVTK_DIR=/opt/VTK/8.2.0-ompi/lib64/cmake/vtk-8.2 \
    -G Ninja && \
    ninja ${NINJA_ARG} && ninja install

FROM base AS final
ARG VTK82
ARG VTK90
ARG VTK91
ARG VTK92
ARG VTK93
ARG VTK94
ARG VTK95
ARG TRI_13_0
ARG TRI_13_2
ARG TRI_13_4
ARG PV_5_12
ARG PV_5_13
ARG PV_6_0
ARG LAMMPS_22Jul2025
COPY --from=vtk82 /opt/VTK/${VTK82}-ompi /opt/VTK/${VTK82}-ompi
COPY --from=vtk92 /opt/VTK/${VTK92}-ompi /opt/VTK/${VTK92}-ompi
COPY --from=vtk93 /opt/VTK/${VTK93}-ompi /opt/VTK/${VTK93}-ompi
COPY --from=vtk94 /opt/VTK/${VTK94}-ompi /opt/VTK/${VTK94}-ompi
COPY --from=vtk95 /opt/VTK/${VTK95}-ompi /opt/VTK/${VTK95}-ompi
#COPY --from=tri-13-4 /opt/trilinos/${TRI_13_4}-ompi /opt/trilinos/${TRI_13_4}-ompi
#COPY --from=pv-5-13 /opt/paraview/${PV_5_13}-ompi /opt/paraview/${PV_5_13}-ompi
#COPY --from=pv-6-0 /opt/paraview/${PV_6_0}-ompi /opt/paraview/${PV_6_0}-ompi
COPY --from=lammps-22jul2025 /opt/lammps/${LAMMPS_22Jul2025}-ompi \
     /opt/lammps/${LAMMPS_22Jul2025}-ompi
