# THIS FILE MUST BE EXECUTED INSIDE ACTIVATED VENV
SRC_PATH = ${HOME}/src
OPENCV ?= 3.4.3
OPENCV_PATH = ${SRC_PATH}/opencv-${OPENCV}
OPENCV_BUILD_PATH = ${SRC_PATH}/opencv-${OPENCV}/build
OPENCV_SRC = ${SRC_PATH}/opencv_contrib-${OPENCV}.zip
OPENCV_CONTRIB_PATH = ${SRC_PATH}/opencv_contrib-${OPENCV}
OPENCV_CONTRIB_SRC = ${SRC_PATH}/opencv_contrib-${OPENCV}.zip
CORES ?= 4
LIB_CV2_PATH ?= /usr/local/lib/python3.6/site-packages/cv2.cpython-36m-x86_64-linux-gnu.so
VENV ?= $(shell ${HOME}/.local/bin/pipenv --venv)
VENV_LIB_CV2_PATH ?= ${VENV}/lib/python3.6/cv2.so

# Ubuntu 16.04
libs16:
	sudo apt-get install build-essential cmake pkg-config libjpeg8-dev \
        libtiff5-dev libjasper-dev libpng12-dev libavcodec-dev libavformat-dev \
        libswscale-dev libv4l-dev libxvidcore-dev libx264-dev libgtk-3-dev \
        libatlas-base-dev gfortran -y

# Placeholder, for 18.04 packages look into
# https://www.pyimagesearch.com/2018/05/28/ubuntu-18-04-how-to-install-opencv
libs18:
	sudo apt-get install build-essential cmake pkg-config

clean:
	rm -rf ${OPENCV_PATH}
	rm -rf ${OPENCV_SRC}
	rm -rf ${OPENCV_CONTRIB_PATH}
	rm -rf ${OPENCV_CONTRIB_SRC}

clean_build: prebuild
	rm -rf ${OPENCV_BUILD_PATH}/*

prebuild:
	makedir -p ${OPENCV_BUILD_PATH}

build: clean_build ${OPENCV_SRC} ${OPENCV_CONTRIB_SRC}
	cd ${SRC_PATH}
	unzip ${OPENCV_SRC}
	unzip ${OPENCV_CONTRIB_SRC}
	cd ${OPENCV_PATH}
	cmake -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D INSTALL_PYTHON_EXAMPLES=ON \
        -D INSTALL_C_EXAMPLES=OFF \
        -D OPENCV_EXTRA_MODULES_PATH=${OPENCV_CONTRIB_PATH} \
        -D PYTHON_EXECUTABLE=${VENV}/bin/python \
        -D BUILD_EXAMPLES=ON ..
	make -j${CORES}
	sudo make install
	sudo ldconfig

# link already builded cv2 into VENV
install:
	rm ${VENV_LIB_CV2_PATH} || true
	ln -s ${LIB_CV2_PATH} ${VENV_LIB_CV2_PATH}

${OPENCV_SRC}:
	wget -O $@ https://github.com/opencv/opencv/archive/${OPENCV}.zip

${OPENCV_CONTRIB_SRC}:
	wget -O $@ https://github.com/opencv/opencv_contrib/archive/${OPENCV}.zip

install16: libs16 build install check

check:
	python -c "import cv2; print(cv2.__version__); print(cv2.__file__)"

.PONY: libs16 libs18 clean prebuild build install install16 clean_build
