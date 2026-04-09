# LAB 1 - Simulation với Xcelium (Cadence)

> **Mục tiêu:** Làm quen với công cụ mô phỏng Xcelium của Cadence, chạy simulation cho mạch **Bound Flasher** và xem waveform bằng GUI SimVision.

---

## Mục lục

1. [Tổng quan bài lab](#1-tổng-quan-bài-lab)
2. [Bài tập: Bound Flasher](#2-bài-tập-bound-flasher)
3. [Tạo cấu trúc thư mục](#3-tạo-cấu-trúc-thư-mục)
4. [Chạy Simulation](#4-chạy-simulation)
5. [Tạo Waveform file](#5-tạo-waveform-file)
6. [Xem Waveform bằng GUI (SimVision)](#6-xem-waveform-bằng-gui-simvision)
7. [Các nút hữu ích trong GUI](#7-các-nút-hữu-ích-trong-gui)
8. [Script tiện lợi](#8-script-tiện-lợi)
9. [Lưu ý quan trọng](#9-lưu-ý-quan-trọng)

---

## 1. Tổng quan bài lab

Bài lab này sử dụng **Xcelium** — công cụ simulation của Cadence — để:
- Thực thi simulation từ command line
- Sinh waveform file từ kết quả simulation
- Debug bằng giao diện đồ hoạ **SimVision**

> Các lệnh command-line trong tài liệu này được hiển thị với ký hiệu `%>` ở đầu.

---

## 2. Bài tập: Bound Flasher

### Mô tả

Thiết kế RTL cho mạch **Bound Flasher** gồm **16 đèn** (`lamp[0]` đến `lamp[15]`).

### Hoạt động

| Bước | Mô tả |
|------|-------|
| Khởi tạo | Tất cả đèn đều **TẮT** |
| Kích hoạt | Khi `flick = 1`, flasher bắt đầu hoạt động |
| Giai đoạn 1 | Đèn BẬT dần từ `lamp[0]` → `lamp[5]` |
| Giai đoạn 2 | Đèn TẮT dần từ `lamp[5]` → `lamp[0]` |
| Giai đoạn 3 | Đèn BẬT dần từ `lamp[0]` → `lamp[10]` |
| Giai đoạn 4 | Đèn TẮT dần từ `lamp[10]` → `lamp[5]` |
| Giai đoạn 5 | Đèn BẬT dần từ `lamp[5]` → `lamp[15]` |
| Giai đoạn 6 | Đèn TẮT dần từ `lamp[15]` → `lamp[0]` (về trạng thái ban đầu) |

### Điều kiện kickback (bổ sung)

- Tại các điểm kickback (`lamp[5]` và `lamp[10]`), nếu `flick = ACTIVE` thì đèn sẽ **TẮT dần về min** của trạng thái trước đó, rồi tiếp tục.
- Kickback chỉ xét khi đèn đang **BẬT dần**, ngoại trừ giai đoạn đầu tiên.

### File cần có

```
bound_flasher.v       ← File RTL thiết kế (bạn tự viết)
bound_flasher_tb.v    ← File Testbench (bạn tự viết / được cung cấp)
```

---

## 3. Tạo cấu trúc thư mục

Trước khi bắt đầu, tạo cây thư mục chuẩn theo cấu trúc sau:

```
{Student_ID}/
├── output/
│   ├── design/       ← Lưu output thiết kế
│   └── doc/          ← Lưu tài liệu
└── work/
    ├── simulation_env/     ← Nơi làm việc chính của Lab 1
    ├── synthesis_env/
    └── lec_env/
```

### Lệnh tạo thư mục

```bash
%> cd vlsi
%> mkdir {Student_ID}
%> cd {Student_ID}
%> mkdir output
%> mkdir output/design
%> mkdir output/doc
%> mkdir work
%> mkdir work/simulation_env
%> mkdir work/synthesis_env
%> mkdir work/lec_env
```

> ⚠️ Thay `{Student_ID}` bằng mã số sinh viên thực tế của bạn.

---

## 4. Chạy Simulation

### Bước 1 — Di chuyển vào thư mục làm việc

```bash
%> cd work/simulation_env
```

### Bước 2 — Copy file design và testbench vào thư mục này

```bash
%> cp /đường/dẫn/đến/bound_flasher.v .
%> cp /đường/dẫn/đến/bound_flasher_tb.v .
```

> Sau bước này, thư mục `simulation_env` phải chứa cả 2 file: `bound_flasher.v` và `bound_flasher_tb.v`

### Bước 3 — Cấp quyền sử dụng Xcelium (license)

```bash
%> cd /home/share_file/cadence/
%> source add_path
%> source add_license
%> cd -
```

> Lệnh `cd -` sẽ đưa bạn trở lại thư mục `simulation_env` trước đó.

### Bước 4 — Chạy simulation

```bash
%> xrun -access rw -licqueue -64BIT -l run.log bound_flasher_tb.v bound_flasher.v
```

**Giải thích các tham số:**

| Tham số | Ý nghĩa |
|---------|---------|
| `-access rw` | Cho phép đọc/ghi tín hiệu trong simulation |
| `-licqueue` | Tự động xếp hàng chờ license nếu đang bận |
| `-64BIT` | Chạy ở chế độ 64-bit |
| `-l run.log` | Ghi log ra file `run.log` |
| `bound_flasher_tb.v` | File testbench (viết trước) |
| `bound_flasher.v` | File design |

### Bước 5 — Kiểm tra kết quả

```bash
%> vi run.log
```

Mở file `run.log` để xem kết quả simulation. Kiểm tra xem có lỗi nào không.

---

## 5. Tạo Waveform file

Để xem waveform sau này, bạn cần thêm code vào **testbench file** trước khi chạy lại simulation.

### Bước 1 — Thêm code vào testbench

Mở file `bound_flasher_tb.v` và thêm đoạn code sau vào trong `initial begin`:

```verilog
initial begin
  $recordfile ("waves");
  $recordvars ("depth=0", testbench);
end
```

> ⚠️ Tên module trong `$recordvars` phải **khớp đúng** với tên module testbench của bạn.

### Bước 2 — Đảm bảo testbench có lệnh kết thúc

Testbench **bắt buộc phải có** lệnh `$finish` để kết thúc simulation:

```verilog
initial begin
  // ... các test case ...
  #some_time;
  $finish;
end
```

> ⚠️ Nếu không có `$finish`, simulation sẽ chạy mãi và **không sinh được waveform file**.

### Bước 3 — Chạy lại simulation

Lặp lại các bước ở mục 4 (từ Bước 3 đến Bước 4).

### Bước 4 — Kiểm tra waveform file đã được tạo

```bash
%> ls waves.*
```

Bạn sẽ thấy 2 file:
- `waves.dsn`
- `waves.trn`

Nếu 2 file này xuất hiện, waveform đã được dump thành công ✅

---

## 6. Xem Waveform bằng GUI (SimVision)

### Bước 1 — Cấp quyền license (tương tự phần simulation)

```bash
%> cd /home/share_file/cadence/
%> source add_path
%> source add_license
%> cd -
```

### Bước 2 — Mở SimVision

```bash
%> simvision -64 &
```

> Dấu `&` giúp chạy SimVision ở background, để terminal vẫn dùng được.

### Bước 3 — Giao diện SimVision

Sau khi mở, bạn sẽ thấy giao diện gồm các vùng chính:

```
┌─────────────────────────────────────────┐
│              Tool bar                   │
├────────────────┬────────────────────────┤
│  Signal name   │   Waveform display     │
│     area       │       area             │
└────────────────┴────────────────────────┘
```

### Bước 4 — Mở waveform file

1. Click **File** trên menu bar
2. Chọn **Open Database**
3. Tìm và chọn file `waves.dsn` (hoặc `waves.trn`) trong thư mục `simulation_env`
4. Click **Open & Dismiss**

### Bước 5 — Hiển thị tín hiệu

1. Ở cửa sổ bên trái, **chọn Design** (tên module)
2. **Chọn các tín hiệu** muốn xem trong danh sách
3. Waveform của các tín hiệu đó sẽ hiển thị ở vùng bên phải

---

## 7. Các nút hữu ích trong GUI

### Zoom

| Nút | Phím tắt | Chức năng |
|-----|----------|-----------|
| `+` | — | Zoom In (phóng to) |
| `-` | — | Zoom Out (thu nhỏ) |
| `=` | — | Zoom Full (xem toàn bộ) |

### Auto Add to Wave-view

- Khi nút này **active (đèn đỏ)**: click vào bất kỳ tín hiệu nào sẽ tự động thêm vào Wave-view.
- Khi nút **inactive**: nhấn `Ctrl + W` để thêm tín hiệu đang chọn vào Wave-view.

### Open Source Code Browser

- Chọn tín hiệu → Click nút **Source Code Browser**
- Xem trực tiếp đoạn code RTL tương ứng với tín hiệu đó

### Open Schematic Tracer

- Chọn tín hiệu → Click nút **Schematic Tracer**
- Xem sơ đồ schematic liên quan đến tín hiệu đó

---

## 8. Script tiện lợi

Để không phải gõ nhiều lệnh lặp đi lặp lại, bạn có thể dùng 2 script sau (đã được cung cấp sẵn):

### `go_sim` — Chạy simulation

```bash
#!/bin/bash -f
cd /home/share_file/cadence/
source add_path
source add_license
cd -
xrun -access rw -licqueue -64BIT -l run.log bound_flasher_tb.v bound_flasher.v
```

**Cách dùng:**
```bash
%> source go_sim
```

### `go_gui` — Mở SimVision GUI

```bash
#!/bin/bash -f
cd /home/share_file/cadence/
source add_path
source add_license
cd -
simvision -64 &
```

**Cách dùng:**
```bash
%> source go_gui
```

> 💡 Đảm bảo cả 2 file script này nằm trong thư mục `simulation_env` trước khi dùng.

---

## 9. Lưu ý quan trọng

| ⚠️ Cảnh báo | Chi tiết |
|------------|---------|
| **Thời gian simulation** | Nếu simulation chạy **quá 5 phút**, có thể bị treo (hang-up). Nhấn `Ctrl + C` để dừng. |
| **Thiếu `$finish`** | Testbench **bắt buộc phải có** `$finish` trước khi dump waveform, nếu không simulation sẽ không kết thúc. |
| **Mỗi lần chạy lại** | Phải thực hiện lại bước `source add_path` và `source add_license` (hoặc dùng script `go_sim`). |
| **Tên module trong `$recordvars`** | Phải trùng khớp chính xác với tên module testbench. |

---

*BKU / Rvc / Cadence Collaboration — Lab 1 Simulation*
