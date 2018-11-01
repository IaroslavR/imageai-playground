import os
import time

import attr
from imageai.Detection import ObjectDetection

PROJECT_ROOT = "/home/mirror/PycharmProjects/ImageAI-opencv"


@attr.s
class RetinaDetector(object):
    models_path = attr.ib(default=os.path.join(PROJECT_ROOT, "data", "external"))
    results_path = attr.ib(default=os.path.join(PROJECT_ROOT, "data", "processed"))
    detector = attr.ib(default=None)
    probability = attr.ib(default=30)
    last_result = attr.ib(default=None)
    last_saved = attr.ib(default=None)
    model_name = attr.ib(default="resnet50_coco_best_v2.0.1.h5")
    img_prefix = attr.ib(default="resnet50")
    processing_time = attr.ib(default=None)

    def __attrs_post_init__(self):
        self.detector = ObjectDetection()
        self._set_type()
        self.detector.setModelPath(os.path.join(self.models_path, self.model_name))
        self.detector.loadModel()

    def _set_type(self):
        self.detector.setModelTypeAsRetinaNet()

    def run(self, img_fname):
        processed_fname = os.path.join(
            self.results_path, f"{self.img_prefix}_{os.path.basename(img_fname)}"
        )
        ts = time.time()
        self.last_result = self.detector.detectObjectsFromImage(
            input_image=img_fname,
            output_image_path=processed_fname,
            minimum_percentage_probability=self.probability,
        )
        self.processing_time = time.time() - ts
        self.last_saved = processed_fname
        return self.last_result


@attr.s
class YOLODetector(RetinaDetector):
    model_name = attr.ib(default="yolo.h5")
    img_prefix = attr.ib(default="yolo")

    def _set_type(self):
        self.detector.setModelTypeAsYOLOv3()


@attr.s
class TinyYOLODetector(RetinaDetector):
    model_name = attr.ib(default="yolo-tiny.h5")
    img_prefix = attr.ib(default="yolo-tiny")

    def _set_type(self):
        self.detector.setModelTypeAsTinyYOLOv3()


if __name__ == "__main__":
    img_fname = "/home/mirror/PycharmProjects/ImageAI-opencv/data/interim/vlcsnap-2018-11-01-09h09m11s039.png"
    detectors = [RetinaDetector(), YOLODetector(), TinyYOLODetector()]
    for detector in detectors:
        detector.run(img_fname)
        print(detector.model_name, detector.processing_time)
