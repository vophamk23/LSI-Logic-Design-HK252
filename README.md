
# LAB1: SIMULATION VỚI CADENCE XCELIUM

> **Thông tin sinh viên**
>
> | Mục | Giá trị |
> |-----|---------|
> | Group | `group08` |
> | Student ID | `2313946` |
> | Tool | Cadence Xcelium + SimVision |

---

## 🗂️ Cấu trúc thư mục cần tạo

```
/group08/vlsi/2313946/
├── output/
│   ├── design/          ← Lưu output design
│   └── doc/             ← Lưu output document
└── work/
    ├── simulation_env/  ← Thư mục làm việc LAB1
    ├── synthesis_env/   ← (Dùng cho LAB2)
    └── lec_env/         ← (Dùng cho LAB3)
```

---

## 🚀 BƯỚC 1 – Tạo Cây Thư Mục

Chạy lần lượt các lệnh sau:

```bash
cd /group08/vlsi

mkdir 2313946
cd 2313946

mkdir output
mkdir output/design
mkdir output/doc

mkdir work
mkdir work/simulation_env
mkdir work/synthesis_env
mkdir work/lec_env
```

Kiểm tra kết quả:

```bash
ls /group08/vlsi/2313946/
ls /group08/vlsi/2313946/work/
ls /group08/vlsi/2313946/output/
```

✅ Phải thấy đúng cấu trúc như trên.

---

## 🚀 BƯỚC 2 – Copy File Design và Testbench

Chuyển vào thư mục làm việc của LAB1:

```bash
cd /group08/vlsi/2313946/work/simulation_env
```

### Mô tả Bound Flasher

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
Kiểm tra:

```bash
ls /group08/vlsi/2313946/work/simulation_env/
```

✅ Phải thấy: `bound_flasher.v` và `bound_flasher_tb.v`

---

## 🚀 BƯỚC 3 – Chạy Simulation (thủ công)

Thực hiện **từng lệnh theo thứ tự**:

```bash
# 3.1 - Vào thư mục simulation
cd /group08/vlsi/2313946/work/simulation_env

# 3.2 - Vào thư mục cadence để lấy license
cd /home/share_file/cadence/

# 3.3 - Load đường dẫn tool
source add_path

# 3.4 - Load license
source add_license

# 3.5 - Trở về thư mục simulation
cd -

# 3.6 - Chạy simulation
xrun -access rw -licqueue -64BIT -l run.log bound_flasher_tb.v bound_flasher.v
```

> ⏳ Thời gian simulation thường **< 5 phút**.  
> Nếu quá **5 phút** mà chưa xong → nhấn `Ctrl + C` để dừng, kiểm tra lại file.

---

## 🚀 BƯỚC 4 – Kiểm tra Kết quả Simulation

```bash
vi /group08/vlsi/2313946/work/simulation_env/run.log
```

Dùng `/Error` trong vi để tìm nhanh lỗi:

| Kết quả | Hành động |
|---------|-----------|
| ✅ Không có `Error` | Simulation thành công → tiếp tục |
| ❌ Có `Error` | Đọc nội dung lỗi → sửa file `.v` → chạy lại từ Bước 3 |

---

## 🚀 BƯỚC 5 – Tạo File `go_sim` (chạy nhanh)

Thay vì gõ nhiều lệnh mỗi lần, tạo 1 file script để chạy nhanh:

```bash
vi /group08/vlsi/2313946/work/simulation_env/go_sim
```

Nhập nội dung sau, lưu lại (`:wq`):

```bash
#!/bin/bash -f
cd /home/share_file/cadence/
source add_path
source add_license
cd -
xrun -access rw -licqueue -64BIT -l run.log bound_flasher_tb.v bound_flasher.v
```

Cấp quyền thực thi:

```bash
chmod +x /group08/vlsi/2313946/work/simulation_env/go_sim
```

Từ đây, mỗi lần simulation chỉ cần chạy:

```bash
cd /group08/vlsi/2313946/work/simulation_env
source go_sim
```

---

## 🚀 BƯỚC 6 – Thêm Code Dump Waveform vào Testbench

Mở file testbench:

```bash
vi /group08/vlsi/2313946/work/simulation_env/bound_flasher_tb.v
```

Thêm đoạn code sau vào **bên trong module testbench** (sau khai báo biến):

```verilog
initial begin
  $recordfile ("waves");
  $recordvars ("depth=0", testbench);
end
```

> ⚠️ **Lưu ý quan trọng:**
> - Tên trong `$recordvars` phải **trùng với tên module** của testbench.
> - Testbench **phải có lệnh `$finish`** để kết thúc simulation, nếu không waveform sẽ không được dump đầy đủ.

Lưu lại (`:wq`), sau đó chạy lại simulation:

```bash
cd /group08/vlsi/2313946/work/simulation_env
source go_sim
```

Kiểm tra waveform đã được tạo:

```bash
ls /group08/vlsi/2313946/work/simulation_env/
```

✅ Phải thấy 2 file: `waves.dsn` và `waves.trn`

---

## 🚀 BƯỚC 7 – Tạo File `go_gui` (mở SimVision nhanh)

```bash
vi /group08/vlsi/2313946/work/simulation_env/go_gui
```

Nhập nội dung sau, lưu lại (`:wq`):

```bash
#!/bin/bash -f
cd /home/share_file/cadence/
source add_path
source add_license
cd -
simvision -64 &
```

Cấp quyền thực thi:

```bash
chmod +x /group08/vlsi/2313946/work/simulation_env/go_gui
```

Mở GUI SimVision:

```bash
cd /group08/vlsi/2313946/work/simulation_env
source go_gui
```

---

## 🚀 BƯỚC 8 – Xem Waveform trong SimVision GUI

Sau khi cửa sổ SimVision mở ra, thực hiện theo thứ tự:

**Step 1:** Click **`File`** → **`Open Database`**

**Step 2:** Chọn file waveform → Click **`Open & Dismiss`**

```
Đường dẫn file waveform:
/group08/vlsi/2313946/work/simulation_env/waves.dsn
```

**Step 3:** Trong cửa sổ bên trái:
- Chọn **Design** (tên module)
- Chọn **Signal** muốn xem
- Waveform sẽ hiển thị ở vùng bên phải

---

## 🛠️ Một Số Nút Hữu Ích trong SimVision

| Nút | Chức năng |
|-----|-----------|
| **`+`** | Zoom In |
| **`-`** | Zoom Out |
| **`=`** | Zoom Full (xem toàn bộ) |
| **Auto add to Wave-view** | Khi bật (đèn đỏ), click vào signal sẽ tự thêm vào waveform |
| **`Ctrl + W`** | Thêm signal đang chọn vào waveform (khi Auto add tắt) |
| **Source code Browser** | Xem source code Verilog tương ứng với signal |
| **Schematic Tracer** | Xem sơ đồ schematic tương ứng |

---

## 🔁 Tóm Tắt Quy Trình LAB1

```
BƯỚC 1  → Tạo cây thư mục tại /group08/vlsi/2313946/
BƯỚC 2  → Copy bound_flasher.v và bound_flasher_tb.v vào simulation_env/
BƯỚC 3  → Source license → chạy xrun để simulation
BƯỚC 4  → Kiểm tra run.log (không có Error là đạt)
BƯỚC 5  → Tạo file go_sim để chạy simulation nhanh
BƯỚC 6  → Thêm $recordfile/$recordvars vào testbench → chạy lại → có waves.dsn & waves.trn
BƯỚC 7  → Tạo file go_gui để mở SimVision nhanh
BƯỚC 8  → Mở SimVision → Load waveform → Xem tín hiệu
```

---

## 📁 Tổng Hợp Đường Dẫn Quan Trọng

| Mục | Đường dẫn |
|-----|-----------|
| Thư mục làm việc | `/group08/vlsi/2313946/work/simulation_env/` |
| File design | `/group08/vlsi/2313946/work/simulation_env/bound_flasher.v` |
| File testbench | `/group08/vlsi/2313946/work/simulation_env/bound_flasher_tb.v` |
| File script sim | `/group08/vlsi/2313946/work/simulation_env/go_sim` |
| File script GUI | `/group08/vlsi/2313946/work/simulation_env/go_gui` |
| Log simulation | `/group08/vlsi/2313946/work/simulation_env/run.log` |
| Waveform | `/group08/vlsi/2313946/work/simulation_env/waves.dsn` |
| Output design | `/group08/vlsi/2313946/output/design/` |

---

*Nếu gặp lỗi, đọc `run.log` và tìm từ khóa `Error` để xác định nguyên nhân.*

