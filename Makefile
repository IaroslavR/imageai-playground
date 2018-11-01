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

.PHONY: all clean test

all: reports/figures/exploratory.png models/random_forest.model

clean:
	rm -f data/raw/*.csv
	rm -f data/processed/*.pickle
	rm -f data/processed/*.csv
	rm -f reports/figures/*.png
	rm -f models/*.model

data/raw/iris.csv:
	python src/data/download.py $(IRIS_URL) $@

data/processed/processed.pickle: data/raw/iris.csv
		python src/data/preprocess.py $< $@ data/processed/processed.csv

reports/figures/exploratory.png: data/processed/processed.pickle
	python src/visualization/exploratory.py $< $@

test: all
	pytest src

models/random_forest.model: data/processed/processed.pickle
	python src/models/train_model.py $< $@
