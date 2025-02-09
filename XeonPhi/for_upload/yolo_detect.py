import cv2
import numpy as np

# YOLO モデルの読み込み
net = cv2.dnn.readNet("/home/mic/yolo/yolov3.weights", "/home/mic/yolo/yolov3.cfg")
layer_names = net.getLayerNames()
output_layers = [layer_names[i - 1] for i in net.getUnconnectedOutLayers()]
classes = open("/home/mic/yolo/coco.names").read().strip().split("\n")

# 動画の読み込み
cap = cv2.VideoCapture("/home/mic/downloaded_video.mp4")
fourcc = cv2.VideoWriter_fourcc(*"mp4v")
out = cv2.VideoWriter("/home/mic/output.mp4", fourcc, 30, (int(cap.get(3)), int(cap.get(4))))

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break

    height, width = frame.shape[:2]

    # 画像を YOLO に入力
    blob = cv2.dnn.blobFromImage(frame, 1/255.0, (416, 416), swapRB=True, crop=False)
    net.setInput(blob)
    detections = net.forward(output_layers)

    for detection in detections:
        for obj in detection:
            scores = obj[5:]
            class_id = np.argmax(scores)
            confidence = scores[class_id]
            if confidence > 0.5:
                box = obj[:4] * np.array([width, height, width, height])
                (centerX, centerY, w, h) = box.astype("int")
                x, y = int(centerX - w / 2), int(centerY - h / 2)

                # 検出されたオブジェクトを枠で囲む
                color = (0, 255, 0)
                cv2.rectangle(frame, (x, y), (x + w, y + h), color, 2)
                label = f"{classes[class_id]}: {confidence:.2f}"
                cv2.putText(frame, label, (x, y - 5), cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)

    out.write(frame)

cap.release()
out.release()
print("=== YOLO 物体検出完了！ ===")
