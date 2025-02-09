import cv2

# 動画の読み込み
cap = cv2.VideoCapture("/home/mic/downloaded_video.mp4")
if not cap.isOpened():
    print("動画を開けません！")
    exit()

# 出力ファイルの設定
fourcc = cv2.VideoWriter_fourcc(*"mp4v")
out = cv2.VideoWriter("/home/mic/output.mp4", fourcc, 30, (int(cap.get(3)), int(cap.get(4))))

# Haarcascades を使用した顔認識
face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + "haarcascade_frontalface_default.xml")

while True:
    ret, frame = cap.read()
    if not ret:
        break

    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    faces = face_cascade.detectMultiScale(gray, 1.3, 5)

    for (x, y, w, h) in faces:
        cv2.rectangle(frame, (x, y), (x+w, y+h), (255, 0, 0), 2)  # 顔を矩形で囲む

    out.write(frame)

cap.release()
out.release()
print("=== 動画処理完了 ===")
