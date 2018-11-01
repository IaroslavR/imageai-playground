LIB_PATH=/usr/local/lib/python3.6/site-packages/cv2.cpython-36m-x86_64-linux-gnu.so
VENV=$(shell ${HOME}/.local/bin/pipenv --venv)
VENV_LIB_PATH=${VENV}/lib/python3.6/cv2.so
IRIS_URL = "https://archive.ics.uci.edu/ml/machine-learning-databases/iris/iris.data"

opencv:
	# link manually builded cv2
	rm ${VENV_LIB_PATH} || true
	ln -s ${LIB_PATH} ${VENV_LIB_PATH}

venv: opencv
	${HOME}/.local/bin/pipenv install -r requirements.txt

.PHONY: all clean test opencv venv external

#all: reports/figures/exploratory.png models/random_forest.model

all: external

external: data/external/yolo.h5 \
	data/external/squeezenet_weights_tf_dim_ordering_tf_kernels.h5 \
	data/external/resnet50_weights_tf_dim_ordering_tf_kernels.h5 \
	data/external/inception_v3_weights_tf_dim_ordering_tf_kernels.h5 \
	data/external/DenseNet-BC-121-32.h5 \
	data/external/yolo-tiny.h5 \
	data/external/resnet50_coco_best_v2.0.1.h5

data/external/squeezenet_weights_tf_dim_ordering_tf_kernels.h5:
	wget https://github.com/OlafenwaMoses/ImageAI/releases/download/1.0/squeezenet_weights_tf_dim_ordering_tf_kernels.h5 \
	-O $@

data/external/resnet50_weights_tf_dim_ordering_tf_kernels.h5:
	wget https://github.com/OlafenwaMoses/ImageAI/releases/download/1.0/resnet50_weights_tf_dim_ordering_tf_kernels.h5 \
	-O $@

data/external/inception_v3_weights_tf_dim_ordering_tf_kernels.h5:
	wget https://github.com/OlafenwaMoses/ImageAI/releases/download/1.0/inception_v3_weights_tf_dim_ordering_tf_kernels.h5 \
	-O $@

data/external/DenseNet-BC-121-32.h5:
	wget https://github.com/OlafenwaMoses/ImageAI/releases/download/1.0/DenseNet-BC-121-32.h5 \
	-O $@

data/external/yolo.h5:
	wget https://github.com/OlafenwaMoses/ImageAI/releases/download/1.0/yolo.h5 \
	-O $@

data/external/yolo-tiny.h5:
	wget https://github.com/OlafenwaMoses/ImageAI/releases/download/1.0/yolo-tiny.h5 \
	-O $@

data/external/resnet50_coco_best_v2.0.1.h5:
	wget https://github.com/OlafenwaMoses/ImageAI/releases/download/1.0/resnet50_coco_best_v2.0.1.h5 \
	-O $@


clean:
	rm -f data/raw/*.csv
	rm -f data/processed/*.pickle
	rm -f data/processed/*.csv
	rm -f reports/figures/*.png
	rm -f models/*.model

test: all
	pytest src

#reports/figures/exploratory.png: data/processed/processed.pickle
#	python src/visualization/exploratory.py $< $@
#
#models/random_forest.model: data/processed/processed.pickle
#	python src/models/train_model.py $< $@
#
#data/processed/processed.pickle: data/raw/iris.csv
#	python src/data/preprocess.py $< $@ data/processed/processed.csv
#
#data/raw/iris.csv:
#	python src/data/download.py $(IRIS_URL) $@

