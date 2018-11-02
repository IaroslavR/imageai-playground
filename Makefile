PROJ_ROOT = $(shell pwd)
RAW_DATA_ROOT ?= ${HOME}/raw_data_storage
RAW_DATA_LOCAL = ${PROJ_ROOT}/data/raw
EXTERNAL_MODELS_ROOT ?= ${HOME}/external_models_storage
EXTERNAL_MODELS_LOCAL ?= ${PROJ_ROOT}/data/external
INTERMEDIATE_RESULTS = ${PROJ_ROOT}/data/interim
PROCESSED_RESULTS = ${PROJ_ROOT}/data/processed
REPORTS = ${PROJ_ROOT}/reports
MODELS = ${PROJ_ROOT}/models
# video sample length
SAMPLE_LENGTH = 00:00:30
# screenshout at
SCREENSHOUT_TIME = 19
STREAM_SOURCE = ${RAW_DATA_ROOT}/0-2018-10-23-08-29-18-592.mov


# CAVEAT: all mannualy added to RAW_DATA_LOCAL, INTERMEDIATE_RESULTS and
# EXTERNAL_MODELS_LOCAL dirs will be deleted. Modify download targers,
# save it to RAW_DATA_ROOT and EXTERNAL_MODELS_ROOT create links to RAW_DATA_LOCAL
# EXTERNAL_MODELS_LOCAL for reuseble data and modify preprocess targets
# according to your needs if you want to awoid it
clean:
	find ${RAW_DATA_LOCAL} ! -type d ! -name .gitkeep -exec rm -f {} +
	find ${EXTERNAL_MODELS_LOCAL} ! -type d ! -name .gitkeep -exec rm -f {} +
	find ${INTERMEDIATE_RESULTS} ! -type d ! -name .gitkeep -exec rm -f {} +
	find ${PROCESSED_RESULTS} ! -type d ! -name .gitkeep -exec rm -f {} +
	find ${REPORTS} ! -type d ! -name .gitkeep -exec rm -f {} +
	find ${MODELS} ! -type d ! -name .gitkeep -exec rm -f {} +

test: all
	pytest src

.PHONY: all clean test opencv venv prebuild download preprocess

all: prebuild clean download install preprocess

prebuild:
	mkdir -p ${RAW_DATA_ROOT}
	mkdir -p ${EXTERNAL_MODELS_ROOT}

install: ${EXTERNAL_MODELS_LOCAL}/yolo.h5 \
	${EXTERNAL_MODELS_LOCAL}/squeezenet_weights_tf_dim_ordering_tf_kernels.h5 \
	${EXTERNAL_MODELS_LOCAL}/resnet50_weights_tf_dim_ordering_tf_kernels.h5 \
	${EXTERNAL_MODELS_LOCAL}/inception_v3_weights_tf_dim_ordering_tf_kernels.h5 \
	${EXTERNAL_MODELS_LOCAL}/DenseNet-BC-121-32.h5 \
	${EXTERNAL_MODELS_LOCAL}/yolo-tiny.h5 \
	${EXTERNAL_MODELS_LOCAL}/resnet50_coco_best_v2.0.1.h5

${EXTERNAL_MODELS_LOCAL}/yolo.h5:
	ln -s ${EXTERNAL_MODELS_ROOT}/yolo.h5 $@

${EXTERNAL_MODELS_LOCAL}/squeezenet_weights_tf_dim_ordering_tf_kernels.h5:
	ln -s ${EXTERNAL_MODELS_ROOT}/squeezenet_weights_tf_dim_ordering_tf_kernels.h5 $@

${EXTERNAL_MODELS_LOCAL}/resnet50_weights_tf_dim_ordering_tf_kernels.h5:
	ln -s ${EXTERNAL_MODELS_ROOT}/resnet50_weights_tf_dim_ordering_tf_kernels.h5 $@

${EXTERNAL_MODELS_LOCAL}/inception_v3_weights_tf_dim_ordering_tf_kernels.h5:
	ln -s ${EXTERNAL_MODELS_ROOT}/inception_v3_weights_tf_dim_ordering_tf_kernels.h5 $@

${EXTERNAL_MODELS_LOCAL}/DenseNet-BC-121-32.h5:
	ln -s ${EXTERNAL_MODELS_ROOT}/DenseNet-BC-121-32.h5 $@

${EXTERNAL_MODELS_LOCAL}/yolo-tiny.h5:
	ln -s ${EXTERNAL_MODELS_ROOT}/yolo-tiny.h5 $@

${EXTERNAL_MODELS_LOCAL}/resnet50_coco_best_v2.0.1.h5:
	ln -s ${EXTERNAL_MODELS_ROOT}/resnet50_coco_best_v2.0.1.h5 $@

download: $(EXTERNAL_MODELS_ROOT)/yolo.h5 \
	$(EXTERNAL_MODELS_ROOT)/squeezenet_weights_tf_dim_ordering_tf_kernels.h5 \
	$(EXTERNAL_MODELS_ROOT)/resnet50_weights_tf_dim_ordering_tf_kernels.h5 \
	$(EXTERNAL_MODELS_ROOT)/inception_v3_weights_tf_dim_ordering_tf_kernels.h5 \
	$(EXTERNAL_MODELS_ROOT)/DenseNet-BC-121-32.h5 \
	$(EXTERNAL_MODELS_ROOT)/yolo-tiny.h5 \
	$(EXTERNAL_MODELS_ROOT)/resnet50_coco_best_v2.0.1.h5

$(EXTERNAL_MODELS_ROOT)/squeezenet_weights_tf_dim_ordering_tf_kernels.h5:
	wget https://github.com/OlafenwaMoses/ImageAI/releases/download/1.0/squeezenet_weights_tf_dim_ordering_tf_kernels.h5 \
	-O $@

$(EXTERNAL_MODELS_ROOT)/resnet50_weights_tf_dim_ordering_tf_kernels.h5:
	wget https://github.com/OlafenwaMoses/ImageAI/releases/download/1.0/resnet50_weights_tf_dim_ordering_tf_kernels.h5 \
	-O $@

$(EXTERNAL_MODELS_ROOT)/inception_v3_weights_tf_dim_ordering_tf_kernels.h5:
	wget https://github.com/OlafenwaMoses/ImageAI/releases/download/1.0/inception_v3_weights_tf_dim_ordering_tf_kernels.h5 \
	-O $@

$(EXTERNAL_MODELS_ROOT)/DenseNet-BC-121-32.h5:
	wget https://github.com/OlafenwaMoses/ImageAI/releases/download/1.0/DenseNet-BC-121-32.h5 \
	-O $@

$(EXTERNAL_MODELS_ROOT)/yolo.h5:
	wget https://github.com/OlafenwaMoses/ImageAI/releases/download/1.0/yolo.h5 \
	-O $@

$(EXTERNAL_MODELS_ROOT)/yolo-tiny.h5:
	wget https://github.com/OlafenwaMoses/ImageAI/releases/download/1.0/yolo-tiny.h5 \
	-O $@

$(EXTERNAL_MODELS_ROOT)/resnet50_coco_best_v2.0.1.h5:
	wget https://github.com/OlafenwaMoses/ImageAI/releases/download/1.0/resnet50_coco_best_v2.0.1.h5 \
	-O $@

# only 5 minutes minutes of raw video converted in some
# size .mp4, 640x480.mp4, and screenshot from 17 sec of 640x480.mp4
# saved in INTERMEDIATE_RESULTS folder
preprocess: ${INTERMEDIATE_RESULTS}/road_camera_640x480_0-17.jpeg

${INTERMEDIATE_RESULTS}/road_camera_640x480_0-17.jpeg: ${INTERMEDIATE_RESULTS}/road_camera_640x480_24fps.mp4
	ffmpeg -y -ss ${SCREENSHOUT_TIME} -i $< -vframes 1 -q:v 2 $@

${INTERMEDIATE_RESULTS}/road_camera_640x480_24fps.mp4: ${INTERMEDIATE_RESULTS}/road_camera_1920x1080_24fps.mp4
	ffmpeg -i $< \
	-y -vf scale=-2:480 -crf 18 -c:v libx264 -t ${SAMPLE_LENGTH} -r 24 $@

${INTERMEDIATE_RESULTS}/road_camera_1920x1080_24fps.mp4: ${STREAM_SOURCE}
	ffmpeg -i $< \
	-y -c:v libx264 -t ${SAMPLE_LENGTH} -r 24 $@

$(STREAM_SOURCE):
    ifeq ($(shell test -e $(STREAM_SOURCE) && echo -n yes),yes)
		ln -s $@ ${RAW_DATA_LOCAL}/road_camera_1920x1080_60fps.mov
    else
		$(error "ERROR: no $@ found")
    endif
