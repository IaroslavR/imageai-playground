import os
import time
from typing import List

import attr
from imageai.Detection import ObjectDetection

PROJECT_ROOT = f"{os.path.dirname(os.path.abspath(__file__))}/../../"


@attr.s(auto_attribs=True)
class ImageDetector(object):
    type: str  # possible values are: resnet50 yolo yolo-tiny
    models_path: str = os.path.join(PROJECT_ROOT, "data", "external")
    results_path: str = os.path.join(PROJECT_ROOT, "data", "processed")
    detector: ObjectDetection = None
    probability: int = 30
    last_result: dict = None
    last_saved: str = None
    processing_time: float = None
    custom_objects: List[str] = attr.Factory(list)
    detector_model_map: dict = {
        "resnet50": {
            "model": "resnet50_coco_best_v2.0.1.h5",
            "type": "setModelTypeAsRetinaNet",
        },
        "yolo": {"model": "yolo.h5", "type": "setModelTypeAsYOLOv3"},
        "yolo-tiny": {"model": "yolo-tiny.h5", "type": "setModelTypeAsTinyYOLOv3"},
    }

    def __attrs_post_init__(self):
        self.detector = ObjectDetection()
        getattr(self.detector, self.detector_model_map[self.type]["type"])()
        self.detector.setModelPath(
            os.path.join(
                self.models_path, self.detector_model_map[self.type]["model"]
            )
        )
        self.detector.loadModel()

    def run(self, img_fname):
        processed_fname = os.path.join(
            self.results_path, f"{self.type}_{os.path.basename(img_fname)}"
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


if __name__ == "__main__":
    img_fname = f"{PROJECT_ROOT}/data/interim/road_camera_640x480_0-17.jpeg"
    detectors = [
        ImageDetector("resnet50"),
        ImageDetector("yolo"),
        ImageDetector("yolo-tiny"),
    ]
    for detector in detectors:
        detector.run(img_fname)
        print(detector.type, detector.processing_time)
