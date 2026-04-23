# HƯỚNG DẪN CHI TIẾT LAB 3 – LOGIC EQUIVALENCE CHECK VỚI CADENCE CONFORMAL

> **Thông tin sinh viên:**
> - Group: `l04group8`
> - Student ID: `2313946`
> - Netlist đã có tại: `~/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB1/outputs_Apr10-XX:XX:XX/bound_flasher_m.v`
> - RTL đã có tại: `~/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/RTL/bound_flasher.v`
> - Thư mục làm việc LAB3: `~/vlsi/2313946/work/lec_env/`

## TỔNG QUAN

LAB 3 gồm 2 phần chính:

| Phần | Nội dung |
|------|----------|
| **Phần 1** | Thực hiện LEC bình thường → xác nhận Netlist tương đương RTL |
| **Phần 2** | Debug Non-equivalent point bằng GUI (Mapping Manager + Schematics Viewer) |

> ✅ Điều kiện tiên quyết: đã hoàn thành LAB2 (Synthesis), có file `bound_flasher_m.v` trong `outputs_Apr10-XX:XX:XX/`.

## 🗂️ Cấu trúc thư mục

```
~/vlsi/2313946/work/
├── synthesis_env/
│   └── Genus_BoundFlasher/
│       ├── RTL/
│       │   └── bound_flasher.v       ← RTL (Golden)
│       ├── LIB/
│       │   └── slow.lib              ← Library
│       └── LAB1/
│           └── outputs_Apr10-XX:XX:XX/
│               └── bound_flasher_m.v ← Netlist (Revised)
└── lec_env/                          ← Thư mục làm việc LAB3
    ├── bound_flasher.v               ← symlink → RTL
    ├── bound_flasher_m.v             ← symlink hoặc copy → Netlist
    ├── slow.lib                      ← symlink → Library
    ├── lec.tcl                       ← Script cấu hình Conformal
    ├── go_lec                        ← Script thực thi
    └── lec.log                       ← Log sinh ra sau khi chạy
```

---

# 🔬 PHẦN 1: THỰC HIỆN LEC CƠ BẢN

## BƯỚC 1 – Di chuyển vào thư mục làm việc

```bash
cd ~/vlsi/2313946/work/lec_env
```

---

## BƯỚC 2 – Tạo symbolic link từ synthesis_env

Link file RTL, Netlist và Library vào thư mục `lec_env`:

```bash
ln -sf ../synthesis_env/Genus_BoundFlasher/RTL/bound_flasher.v
ln -sf ../synthesis_env/Genus_BoundFlasher/LAB1/outputs_Apr10-XX:XX:XX/bound_flasher_m.v
ln -sf ../synthesis_env/Genus_BoundFlasher/LIB/slow.lib
```

> 📌 Lệnh `ln -sf` tạo **symbolic link** (không copy file). Xem tên thư mục `outputs_` thực tế bằng lệnh:
> ```bash
> ls -td ~/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB1/outputs_*/ | head -1
> ```
> Thay `outputs_Apr10-XX:XX:XX` bằng tên thư mục in ra.

---

## BƯỚC 3 – Kiểm tra link thành công

```bash
ll
```

✅ Phải thấy 3 file được link (có mũi tên `->` chỉ đến đường dẫn gốc):
```
bound_flasher.v   -> ../synthesis_env/Genus_BoundFlasher/RTL/bound_flasher.v
bound_flasher_m.v -> ../synthesis_env/Genus_BoundFlasher/LAB1/outputs_Apr10-XX:XX:XX/bound_flasher_m.v
slow.lib          -> ../synthesis_env/Genus_BoundFlasher/LIB/slow.lib
```

❌ Nếu thấy link màu đỏ (broken link) → kiểm tra lại đường dẫn trong Bước 2.

---

## BƯỚC 4 – Tạo script cấu hình `lec.tcl`

```bash
vi ./lec.tcl
```

Nhấn `i`, nhập toàn bộ nội dung sau, nhấn `Esc` rồi `:wq`:

```tcl
set_log_file lec.log -replace
read_library slow.lib -lib -revised
read_design bound_flasher.v -verilog -golden
read_design bound_flasher_m.v -verilog -revised
set_mapping_method -name only
set_system_mode lec
map_key_points
add_compared_points -all
compare
```

| Lệnh | Ý nghĩa |
|------|---------|
| `set_log_file lec.log -replace` | Ghi log ra file `lec.log`, ghi đè nếu đã tồn tại |
| `read_library slow.lib -lib -revised` | Load thư viện cell |
| `read_design ... -golden` | Đọc RTL làm **chuẩn** (Golden) |
| `read_design ... -revised` | Đọc Netlist cần kiểm tra (Revised) |
| `set_mapping_method -name only` | Mapping key points theo tên |
| `set_system_mode lec` | Chuyển sang chế độ LEC |
| `map_key_points` | Tạo bản đồ mapping giữa Golden và Revised |
| `add_compared_points -all` | Thêm tất cả điểm vào danh sách so sánh |
| `compare` | Thực hiện so sánh |

---

## BƯỚC 5 – Tạo script thực thi `go_lec`

```bash
vi ./go_lec
```

Nhấn `i`, nhập nội dung sau, nhấn `Esc` rồi `:wq`:

```bash
#!/bin/bash -f
cd /home/share_file/cadence
source add_path
source add_license
cd -
lec -64 -dofile ./lec.tcl &
```

Cấp quyền thực thi:

```bash
chmod +x ./go_lec
```

> 📌 Phần `source add_path` và `source add_license` cấu hình môi trường và license để chạy Conformal. Phần `lec -64 -dofile ./lec.tcl &` khởi động Conformal với script đã tạo.

---

## BƯỚC 6 – Chạy LEC

```bash
./go_lec
```

> Conformal sẽ tự động mở GUI và thực thi các lệnh trong `lec.tcl`.

---

## BƯỚC 7 – Kiểm tra kết quả trên GUI

Khi quá trình hoàn tất, quan sát cửa sổ GUI:

- ✅ **Không có Non-equivalent points** → Netlist tương đương RTL → LEC PASS
- ❌ **Có Non-equivalent points** → sang Phần 2 để debug

Sau khi xem xong, gõ `exit` vào terminal của GUI để thoát.

---

# 🐛 PHẦN 2: DEBUG NON-EQUIVALENT POINT

> Phần này cố tình tạo bug trong Netlist để thực hành quy trình debug.

## BƯỚC 8 – Xóa link cũ, copy thật Netlist vào

```bash
rm -rf bound_flasher_m.v
cp -rf ../synthesis_env/Genus_BoundFlasher/LAB1/outputs_*/bound_flasher_m.v ./
```

> ⚠️ Phải **copy thật** (không dùng `ln`), vì bước tiếp theo cần chỉnh sửa file. Sửa symlink sẽ ảnh hưởng đến file gốc trong `synthesis_env`.

Kiểm tra:

```bash
ll
```

✅ `bound_flasher_m.v` phải hiển thị là file thường (không có mũi tên `->`)

---

## BƯỚC 9 – Tạo bug trong Netlist

```bash
vi ./bound_flasher_m.v
```

Trong file, **tìm 1 cell INV bất kỳ** và đổi thành **BUF**. Ví dụ:

```verilog
// Trước khi sửa:
INVX1 U_inv_1 (.A(net_0001), .ZN(net_0002));

// Sau khi sửa (đổi INVX1 → BUFX1, đổi .ZN → .Z):
BUFX1 U_inv_1 (.A(net_0001), .Z(net_0002));
```

> 📌 Tên cell thực tế phụ thuộc vào thư viện. Tìm dòng có `INV` bằng lệnh:
> ```bash
> grep -n "INV" bound_flasher_m.v | head -5
> ```
> Chọn 1 dòng bất kỳ rồi sửa. Lưu file bằng `Esc` → `:wq`.

---

## BƯỚC 10 – Chạy lại LEC với Netlist đã bị sửa

```bash
./go_lec
```

---

## BƯỚC 11 – Quan sát Non-equivalent points trên GUI

Khi GUI mở, sẽ xuất hiện danh sách **Non-equivalent points** trong cửa sổ chính.

---

## BƯỚC 12 – Debug bằng Mapping Manager và Schematics Viewer

Thực hiện theo thứ tự sau:

**① Mở Mapping Manager**
- Click vào biểu tượng hoặc menu để mở **Mapping Manager**

**② Filter chỉ hiện Non-Equivalent**
- Trong cửa sổ Mapping Manager → click **Class**
- Chọn **Disable All** → sau đó chọn **Non-Equivalent**
- Danh sách lúc này chỉ còn hiển thị các điểm không tương đương

**③ Mở Diagnosis Manager**
- Right-click vào điểm non-equivalent đầu tiên trong danh sách
- Chọn **Diagnose** → cửa sổ **Diagnosis Manager** mở ra

**④ Mở Schematics Viewer**
- Trong Diagnosis Manager → chọn tab hoặc nút **Schematics**
- Cửa sổ **Schematics Viewer** hiển thị hai schematic song song

**⑤ Đọc kết quả simulation**
- Schematic bên **phải**: Golden (RTL)
- Schematic bên **trái**: Revised (Netlist)
- Quan sát endpoint được đánh dấu (vòng tròn hồng): giá trị Revised ≠ Golden

**⑥ Mở rộng logic cone**
- Right-click vào pin muốn trace ngược → chọn **Fan-in Cone → Open**
- Logic cone của pin đó sẽ được mở rộng để dễ trace

**⑦ Dùng gate màu tím làm mốc**
- Gate màu **tím (purple)** là gate có counterpart tương đương ở schematic bên kia
- Dùng các gate tím làm điểm neo để định hướng debug

**⑧ Xác định root cause**
- Trace ngược từ endpoint, bỏ qua các gate tím
- Gate màu **hồng (pink)** không có counterpart = nguyên nhân gây lỗi
- Trong ví dụ lab này, root cause là **BUF-gate** thay vì INV-gate

**⑨ Xem số dòng trong source code**
- Hover chuột lên gate lỗi → tooltip hiển thị số dòng trong file Netlist

**⑩ Mở source code tương ứng**
- Double-click vào gate lỗi → file Netlist mở ra, trỏ đến đúng dòng chứa gate đó

**⑪ Đề xuất giải pháp**
- Xác nhận đây là cell BUF sai vị trí (đáng lẽ phải là INV)
- Giải pháp: sửa lại Netlist, hoặc **re-synthesize** từ RTL, hoặc thực hiện **ECO (Engineering Change Order)**

---

# 📌 TÓM TẮT TOÀN BỘ QUY TRÌNH

```
PHẦN 1: LEC CƠ BẢN
────────────────────────────────────────────────────────────────
BƯỚC 1  → cd ~/vlsi/2313946/work/lec_env

BƯỚC 2  → ln -sf ../synthesis_env/Genus_BoundFlasher/RTL/bound_flasher.v
           ln -sf ../synthesis_env/Genus_BoundFlasher/LAB1/outputs_*/bound_flasher_m.v
           ln -sf ../synthesis_env/Genus_BoundFlasher/LIB/slow.lib

BƯỚC 3  → ll  (kiểm tra 3 link, không có broken link)

BƯỚC 4  → vi ./lec.tcl  (nhập nội dung script, lưu :wq)

BƯỚC 5  → vi ./go_lec   (nhập nội dung script, lưu :wq)
           chmod +x ./go_lec

BƯỚC 6  → ./go_lec

BƯỚC 7  → GUI mở → không có Non-equivalent → gõ exit ✅
────────────────────────────────────────────────────────────────
PHẦN 2: DEBUG NON-EQUIVALENT POINT
────────────────────────────────────────────────────────────────
BƯỚC 8  → rm -rf bound_flasher_m.v
           cp -rf ../synthesis_env/Genus_BoundFlasher/LAB1/outputs_*/bound_flasher_m.v ./

BƯỚC 9  → vi ./bound_flasher_m.v  (đổi 1 INV cell → BUF cell, lưu :wq)

BƯỚC 10 → ./go_lec

BƯỚC 11 → GUI hiện Non-equivalent points

BƯỚC 12 → Debug theo thứ tự:
           ① Mở Mapping Manager
           ② Filter: Class → Disable All → Non-Equivalent
           ③ Right-click điểm lỗi → Diagnose
           ④ Trong Diagnosis Manager → chọn Schematics
           ⑤ Đọc endpoint: Revised ≠ Golden
           ⑥ Right-click pin → Fan-in Cone → Open
           ⑦ Dùng gate tím làm mốc định hướng
           ⑧ Tìm gate hồng = root cause (BUF thay vì INV)
           ⑨ Hover chuột → xem số dòng source code
           ⑩ Double-click gate → mở source code
           ⑪ Xác nhận lỗi → đề xuất re-synthesize / ECO ✅
```

---

## ❓ XỬ LÝ LỖI THƯỜNG GẶP

| Vấn đề | Nguyên nhân | Cách xử lý |
|--------|-------------|------------|
| Link màu đỏ (broken) sau `ll` | Đường dẫn trong `ln -sf` sai hoặc chưa có file Netlist | Kiểm tra `ls synthesis_env/Genus_BoundFlasher/LAB1/outputs_*/` |
| `lec.log` báo lỗi `cannot find design` | Tên design trong `lec.tcl` không khớp với tên module trong file `.v` | Kiểm tra `grep "^module" bound_flasher.v` |
| GUI không mở | License chưa được source | Đảm bảo đã chạy `source add_path` và `source add_license` |
| Non-equivalent vẫn xuất hiện sau khi fix | Chỉnh sửa symlink thay vì file thật | Xóa symlink, copy file thật, sửa lại |

*Nếu vẫn gặp lỗi, kiểm tra file `lec.log` trong thư mục `lec_env/` để xem chi tiết.*

---

# 🎬 DEMO – CHẠY SHOW KẾT QUẢ CUỐI

> Chạy theo thứ tự này khi demo nộp bài.

### 1. Show cấu trúc thư mục lec_env
```bash
ll ~/vlsi/2313946/work/lec_env/
```
✅ Thấy 3 file link (`bound_flasher.v`, `bound_flasher_m.v`, `slow.lib`) + `lec.tcl` + `go_lec`

---

### 2. Show nội dung file lec.tcl
```bash
cat ~/vlsi/2313946/work/lec_env/lec.tcl
```
✅ Thấy đầy đủ các lệnh: `read_library`, `read_design -golden`, `read_design -revised`, `compare`

---

### 3. Show nội dung file go_lec
```bash
cat ~/vlsi/2313946/work/lec_env/go_lec
```
✅ Thấy lệnh `source add_license` và `lec -64 -dofile ./lec.tcl`

---

### 4. [PHẦN 1] Chạy LEC với Netlist gốc → kết quả Equivalent

> Đảm bảo `bound_flasher_m.v` đang là symlink (Netlist gốc chưa bị sửa).
> Nếu đã copy thật từ Phần 2, restore lại symlink:
> ```bash
> cd ~/vlsi/2313946/work/lec_env
> rm -f bound_flasher_m.v
> ln -sf ../synthesis_env/Genus_BoundFlasher/LAB1/outputs_*/bound_flasher_m.v
> ```

```bash
cd ~/vlsi/2313946/work/lec_env
./go_lec
```
✅ GUI mở → **không có Non-equivalent points** → Netlist equivalent với RTL

Gõ `exit` để thoát GUI, sau đó tiếp tục.

---

### 5. Show log LEC Pass
```bash
cat ~/vlsi/2313946/work/lec_env/lec.log
```
✅ Tìm dòng xác nhận kết quả, không có dòng `Non-Equivalent`

---

### 6. [PHẦN 2] Chuẩn bị Netlist có bug – copy thật + sửa INV → BUF

```bash
cd ~/vlsi/2313946/work/lec_env
rm -rf bound_flasher_m.v
cp -rf ../synthesis_env/Genus_BoundFlasher/LAB1/outputs_*/bound_flasher_m.v ./
```

Kiểm tra đã copy thật (không có `->` ):
```bash
ll
```

Tìm dòng INV để sửa:
```bash
grep -n "INV" bound_flasher_m.v | head -5
```

Sửa 1 INV → BUF (thay `<line_number>` bằng số dòng tìm được ở trên):
```bash
vi +<line_number> ./bound_flasher_m.v
```
> Trong vi: nhấn `i` → đổi `INV` → `BUF` (và đổi port `.ZN` → `.Z` nếu có) → `Esc` → `:wq`

---

### 7. [PHẦN 2] Chạy lại LEC → kết quả Non-Equivalent

```bash
./go_lec
```
✅ GUI mở → xuất hiện **Non-equivalent points**

---

### 8. [PHẦN 2] Demo debug trên GUI – thực hiện thao tác tay

Thực hiện theo thứ tự trên GUI:

| Bước | Thao tác | Kết quả cần thấy |
|------|----------|-----------------|
| ① | Click mở **Mapping Manager** | Cửa sổ Mapping Manager hiện ra |
| ② | Class → Disable All → **Non-Equivalent** | Danh sách lọc chỉ còn điểm lỗi |
| ③ | Right-click điểm lỗi → **Diagnose** | Cửa sổ Diagnosis Manager mở |
| ④ | Chọn **Schematics** | Schematics Viewer hiện 2 schematic song song |
| ⑤ | Quan sát endpoint (vòng tròn hồng) | Revised = 1, Golden = 0 (khác nhau) |
| ⑥ | Right-click pin → **Fan-in Cone → Open** | Logic cone mở rộng |
| ⑦ | Quan sát gate màu tím | Gate tím = có counterpart tương đương bên kia |
| ⑧ | Tìm gate màu hồng | **BUF-gate** = root cause |
| ⑨ | Hover chuột lên BUF-gate | Tooltip hiện số dòng trong source code |
| ⑩ | Double-click BUF-gate | File `bound_flasher_m.v` mở, trỏ đúng dòng lỗi |
| ⑪ | Nêu miệng giải pháp | "Đổi lại BUF → INV, hoặc re-synthesize, hoặc ECO" |
