import logging
import os
import time
from typing import List

import attr
import click
import numpy as np
import structlog
from imageai.Detection import ObjectDetection
from structlog_boilerplate import strict, colored, print_json

from src import PROJECT_ROOT

logger = structlog.get_logger("image_detection")

DETECTORS = ["resnet50", "yolo", "yolo-tiny"]


@attr.s(auto_attribs=True)
class ImageDetector:
    name: str = attr.ib()
    models_path: str = os.path.join(PROJECT_ROOT, "data", "external")
    results_path: str = os.path.join(PROJECT_ROOT, "data", "processed")
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
    detector: ObjectDetection = attr.ib()
    serialized_fields: List[str] = [
        "name",
        "last_result",
        "last_saved",
        "processing_time",
    ]

    @detector.default
    def init_detector(self):
        logger.debug("Detector initialization started", type=self.name)
        detector = ObjectDetection()
        getattr(detector, self.detector_model_map[self.name]["type"])()
        detector.setModelPath(
            os.path.join(self.models_path, self.detector_model_map[self.name]["model"])
        )
        detector.loadModel()
        logger.debug("Detector initialized")
        return detector

    @property
    def serialized(self) -> dict:
        """here we create serializable representation of processing results"""

        def mutate(v):
            if isinstance(v, np.integer):
                return int(v)
            elif isinstance(v, np.floating):
                return float(v)
            elif isinstance(v, np.ndarray):
                return v.tolist()
            return v

        def convert(data: dict) -> dict:
            converted = {}
            for k, v in data.items():
                if isinstance(v, dict):
                    v = convert(v)
                elif isinstance(v, list):
                    v = [convert(i) if isinstance(i, dict) else mutate(i) for i in v]
                else:
                    v = mutate(v)
                converted[k] = v
            return converted

        return convert(
            attr.asdict(
                self, filter=lambda attr, _: attr.name in self.serialized_fields
            )
        )

    def run(self, img_fname: str) -> dict:
        processed_fname = os.path.join(
            self.results_path, f"{self.name}_{os.path.basename(img_fname)}"
        )
        ts = time.time()
        self.last_result = self.detector.detectObjectsFromImage(
            input_image=img_fname,
            output_image_path=processed_fname,
            minimum_percentage_probability=self.probability,
        )
        self.processing_time = time.time() - ts
        self.last_saved = processed_fname
        r = self.serialized
        return r


@click.command()
@click.argument("detector_type", type=click.Choice(DETECTORS))
@click.argument(
    "image",
    default=f"{PROJECT_ROOT}/data/interim/road_camera_640x480_0-17.jpeg",
    type=click.Path(exists=True),
)
@click.option("-v", "--verbose", count=True)
def cli(detector_type, image, verbose):
    level = {0: logging.ERROR, 1: logging.INFO, 2: logging.DEBUG}
    verbose = min(verbose, 2)
    if verbose:
        colored(level[verbose])
    else:
        strict(level[verbose])
    try:
        detector = ImageDetector(detector_type)
        logger.debug("Object detection started", path=image)
        print_json(detector.run(image))
    except Exception:
        logger.exception("Unhandled processing error")
    else:
        logger.debug("Object detection complete")


if __name__ == "__main__":
    cli()
