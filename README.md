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

## BƯỚC 2 – Xác định tên thư mục outputs thực tế

> ⚠️ **Quan trọng:** Tên thư mục `outputs_` có timestamp thực tế sẽ khác nhau tùy máy/thời điểm chạy Synthesis. **Luôn xác định tên thư mục trước** khi dùng trong lệnh `ln -sf`.

```bash
# Xem tên thư mục outputs thực tế
ls -td ~/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB1/outputs_*/
```

Lệnh trên sẽ in ra ví dụ như:
```
/home/l04group8/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB1/outputs_Apr10-14:23:01/
```

> Ghi nhớ tên thư mục đó (ví dụ `outputs_Apr10-14:23:01`) để dùng trong bước tiếp theo. Nếu có **nhiều thư mục** `outputs_*`, chọn cái mới nhất (in đầu tiên).

---

## BƯỚC 3 – Tạo symbolic link từ synthesis_env

Thay `outputs_Apr10-XX:XX:XX` bằng tên thư mục **thực tế** tìm được ở Bước 2:

```bash
ln -sf ../synthesis_env/Genus_BoundFlasher/RTL/bound_flasher.v
ln -sf ../synthesis_env/Genus_BoundFlasher/LAB1/outputs_Apr10-XX:XX:XX/bound_flasher_m.v
ln -sf ../synthesis_env/Genus_BoundFlasher/LIB/slow.lib
```

> 📌 Lệnh `ln -sf` tạo **symbolic link** (không copy file thật). **Không dùng wildcard `*`** trong đường dẫn khi tạo symlink — nếu có nhiều thư mục `outputs_*`, wildcard sẽ chọn sai hoặc báo lỗi.

---

## BƯỚC 4 – Kiểm tra link thành công

```bash
ll
```

✅ Phải thấy 3 file được link (có mũi tên `->` chỉ đến đường dẫn gốc):
```
bound_flasher.v   -> ../synthesis_env/Genus_BoundFlasher/RTL/bound_flasher.v
bound_flasher_m.v -> ../synthesis_env/Genus_BoundFlasher/LAB1/outputs_Apr10-XX:XX:XX/bound_flasher_m.v
slow.lib          -> ../synthesis_env/Genus_BoundFlasher/LIB/slow.lib
```

❌ Nếu thấy link màu đỏ (broken link) → kiểm tra lại đường dẫn trong Bước 3 (sai tên thư mục `outputs_`).

---

## BƯỚC 5 – Tạo script cấu hình `lec.tcl`

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

## BƯỚC 6 – Tạo script thực thi `go_lec`

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

## BƯỚC 7 – Chạy LEC

```bash
./go_lec
```

> Conformal sẽ tự động mở GUI và thực thi các lệnh trong `lec.tcl`.

---

## BƯỚC 8 – Kiểm tra kết quả trên GUI

Khi quá trình hoàn tất, quan sát cửa sổ GUI:

- ✅ **Không có Non-equivalent points** → Netlist tương đương RTL → LEC PASS
- ❌ **Có Non-equivalent points** → sang Phần 2 để debug

Sau khi xem xong, gõ `exit` vào terminal của GUI để thoát.

---

## BƯỚC 9 – Xác nhận kết quả qua file log

Sau khi thoát GUI, kiểm tra file log để xác nhận kết quả:

```bash
cat ~/vlsi/2313946/work/lec_env/lec.log
```

Tìm dòng xác nhận kết quả — nếu LEC PASS sẽ có dòng tương tự:
```
Compared points:  EQUIVALENT
```

Hoặc tìm nhanh bằng grep:
```bash
grep -i "equivalent\|non-equivalent\|abort\|error" lec.log
```

- ✅ Chỉ thấy dòng `EQUIVALENT` → LEC Pass, không có lỗi
- ❌ Thấy `NON-EQUIVALENT` → có điểm không khớp → sang Phần 2
- ❌ Thấy `ERROR` hoặc `ABORT` → lỗi cấu hình, xem phần Xử lý lỗi cuối tài liệu

---

# 🐛 PHẦN 2: DEBUG NON-EQUIVALENT POINT

> Phần này cố tình tạo bug trong Netlist để thực hành quy trình debug.

## BƯỚC 10 – Xóa link cũ, copy thật Netlist vào

```bash
rm -rf bound_flasher_m.v
```

Xác định tên thư mục outputs (như Bước 2), rồi copy với tên thư mục cụ thể:
```bash
cp -rf ../synthesis_env/Genus_BoundFlasher/LAB1/outputs_Apr10-XX:XX:XX/bound_flasher_m.v ./
```

> ⚠️ **Phải copy thật** (không dùng `ln`), vì bước tiếp theo cần chỉnh sửa file. Sửa symlink sẽ ảnh hưởng đến file gốc trong `synthesis_env`.
>
> ⚠️ **Không dùng wildcard** `outputs_*` trong lệnh `cp` nếu có nhiều thư mục — có thể copy nhầm file. Dùng tên thư mục đầy đủ cụ thể.

Kiểm tra:

```bash
ll
```

✅ `bound_flasher_m.v` phải hiển thị là file thường (không có mũi tên `->`)

---

## BƯỚC 11 – Tìm cell INV để sửa

Trước khi vào vi, tìm dòng có INV cell trong Netlist:

```bash
grep -n "INV" bound_flasher_m.v | head -10
```

Kết quả ví dụ:
```
47: INVX1 U15 (.A(n_12), .ZN(n_13));
63: INVX2 U23 (.A(n_20), .ZN(n_21));
```

Ghi nhớ số dòng của **1 cell bất kỳ** (ví dụ dòng 47) để dùng trong bước tiếp theo.

---

## BƯỚC 12 – Tạo bug trong Netlist

### Cách 1: Dùng `vi` (mở trực tiếp đến dòng cần sửa)

```bash
vi +47 ./bound_flasher_m.v
```

Trong vi: nhấn `i` → đổi `INV` thành `BUF` → sửa tên port output:

```verilog
# Trước khi sửa:
INVX1 U15 (.A(n_12), .ZN(n_13));

# Sau khi sửa:
BUFX1 U15 (.A(n_12), .Z(n_13));
```

Nhấn `Esc` → `:wq` để lưu.

---

### Cách 2: Dùng `sed` (nhanh hơn, không cần vào vi)

Thay `47` bằng số dòng thực tế tìm được ở Bước 11, và thay tên cell phù hợp:

```bash
# Ví dụ: đổi INVX1 → BUFX1 tại dòng 47
sed -i '47s/INVX1/BUFX1/' bound_flasher_m.v

# Và đổi port .ZN → .Z tại cùng dòng đó
sed -i '47s/\.ZN(/\.Z(/' bound_flasher_m.v
```

Xác nhận đã sửa đúng:
```bash
sed -n '45,49p' bound_flasher_m.v
```

---

> ### ⚠️ Lưu ý quan trọng về tên port BUF
>
> Tên port của BUF cell **phụ thuộc vào thư viện `slow.lib`**. Không phải thư viện nào cũng giống nhau:
>
> | Thư viện | INV output port | BUF output port |
> |----------|----------------|----------------|
> | Thông thường | `.ZN` | `.Z` |
> | Một số thư viện khác | `.Y` | `.Y` |
> | Một số thư viện khác | `.ZN` | `.ZN` |
>
> Nếu Conformal báo lỗi dạng `port Z not found` hoặc `unresolved pin`, hãy kiểm tra tên port BUF thực tế trong thư viện:
> ```bash
> grep -A 10 "cell (BUF" slow.lib | grep "pin ("
> ```
> Dùng đúng tên port in ra từ lệnh trên.

---

## BƯỚC 13 – Chạy lại LEC với Netlist đã bị sửa

```bash
./go_lec
```

---

## BƯỚC 14 – Quan sát Non-equivalent points trên GUI

Khi GUI mở, sẽ xuất hiện danh sách **Non-equivalent points** trong cửa sổ chính.

---

## BƯỚC 15 – Debug bằng Mapping Manager và Schematics Viewer

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
- Schematic bên **trái**: Revised (Netlist)
- Schematic bên **phải**: Golden (RTL)
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

BƯỚC 2  → ls -td .../LAB1/outputs_*/  (xác định tên thư mục thực tế)

BƯỚC 3  → ln -sf .../RTL/bound_flasher.v
           ln -sf .../LAB1/outputs_Apr10-XX:XX:XX/bound_flasher_m.v   ← tên cụ thể!
           ln -sf .../LIB/slow.lib

BƯỚC 4  → ll  (kiểm tra 3 link, không có broken link)

BƯỚC 5  → vi ./lec.tcl  (nhập nội dung script, lưu :wq)

BƯỚC 6  → vi ./go_lec   (nhập nội dung script, lưu :wq)
           chmod +x ./go_lec

BƯỚC 7  → ./go_lec

BƯỚC 8  → GUI mở → không có Non-equivalent → gõ exit ✅

BƯỚC 9  → grep -i "equivalent" lec.log  (xác nhận EQUIVALENT trong log) ✅
────────────────────────────────────────────────────────────────
PHẦN 2: DEBUG NON-EQUIVALENT POINT
────────────────────────────────────────────────────────────────
BƯỚC 10 → rm -rf bound_flasher_m.v
           cp -rf .../outputs_Apr10-XX:XX:XX/bound_flasher_m.v ./  ← tên cụ thể!

BƯỚC 11 → grep -n "INV" bound_flasher_m.v | head -10
           (ghi nhớ số dòng của 1 INV cell bất kỳ)

BƯỚC 12 → vi +<line_number> ./bound_flasher_m.v
           (đổi INVX1 → BUFX1, đổi .ZN → .Z, lưu :wq)
           Hoặc dùng sed:
           sed -i '<line>s/INVX1/BUFX1/' bound_flasher_m.v
           sed -i '<line>s/\.ZN(/\.Z(/' bound_flasher_m.v

BƯỚC 13 → ./go_lec

BƯỚC 14 → GUI hiện Non-equivalent points

BƯỚC 15 → Debug theo thứ tự:
           ① Mở Mapping Manager
           ② Filter: Class → Disable All → Non-Equivalent
           ③ Right-click điểm lỗi → Diagnose
           ④ Trong Diagnosis Manager → chọn Schematics
           ⑤ Đọc endpoint: Revised (trái) ≠ Golden (phải)
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
| `lec.log` báo `cannot find design` | Tên design trong `lec.tcl` không khớp với tên module trong file `.v` | Kiểm tra `grep "^module" bound_flasher.v` |
| GUI không mở | License chưa được source | Đảm bảo đã chạy `source add_path` và `source add_license` |
| Non-equivalent vẫn xuất hiện sau khi fix | Chỉnh sửa symlink thay vì file thật | Xóa symlink, copy file thật, sửa lại |
| `port Z not found` khi chạy Conformal | Tên port BUF trong thư viện khác `.Z` | Chạy `grep -A 10 "cell (BUF" slow.lib \| grep "pin ("` để tìm tên port đúng |
| Nhiều thư mục `outputs_*`, không biết chọn cái nào | Nhiều lần chạy Synthesis | Dùng `ls -td .../outputs_*/ \| head -1` để lấy thư mục mới nhất |

*Nếu vẫn gặp lỗi, kiểm tra file `lec.log` trong thư mục `lec_env/` để xem chi tiết.*

---

# 🎬 DEMO – CHẠY SHOW KẾT QUẢ CUỐI

> Chạy theo thứ tự này khi demo nộp bài.

---

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

### 4. [PHẦN 1] Show log LEC Pass (đã chạy sẵn)

```bash
grep -i "equivalent\|non-equivalent" ~/vlsi/2313946/work/lec_env/lec.log
```
✅ Thấy dòng xác nhận `EQUIVALENT`, không có dòng `NON-EQUIVALENT`

---

### 5. [PHẦN 2] Show Netlist đã bị sửa bug

```bash
grep -n "BUF" ~/vlsi/2313946/work/lec_env/bound_flasher_m.v | head -5
```
✅ Thấy cell BUF xuất hiện trong Netlist (là cell đã đổi từ INV sang)

---

### 6. [PHẦN 2] Show kết quả Non-Equivalent từ log

```bash
grep -i "non-equivalent\|equivalent" ~/vlsi/2313946/work/lec_env/lec.log
```
✅ Thấy dòng `NON-EQUIVALENT` → xác nhận Conformal đã phát hiện lỗi

---

### 7. [PHẦN 2] Demo debug trên GUI – mở lại GUI từ kết quả đã chạy

> Nếu GUI còn mở → dùng luôn. Nếu đã thoát, có thể mở lại log bằng:
> ```bash
> lec -64 -load lec.log &
> ```
> hoặc chỉ cần show trực tiếp trên terminal mà không cần mở GUI lại.

Thực hiện thao tác tay trên GUI theo thứ tự:

| Bước | Thao tác | Kết quả cần thấy |
|------|----------|-----------------|
| ① | Click mở **Mapping Manager** | Cửa sổ Mapping Manager hiện ra |
| ② | Class → Disable All → **Non-Equivalent** | Danh sách lọc chỉ còn điểm lỗi |
| ③ | Right-click điểm lỗi → **Diagnose** | Cửa sổ Diagnosis Manager mở |
| ④ | Chọn **Schematics** | Schematics Viewer hiện 2 schematic song song |
| ⑤ | Quan sát endpoint (vòng tròn hồng) | Revised (trái) ≠ Golden (phải) |
| ⑥ | Right-click pin → **Fan-in Cone → Open** | Logic cone mở rộng |
| ⑦ | Quan sát gate màu tím | Gate tím = có counterpart tương đương bên kia |
| ⑧ | Tìm gate màu hồng | **BUF-gate** = root cause |
| ⑨ | Hover chuột lên BUF-gate | Tooltip hiện số dòng trong source code |
| ⑩ | Double-click BUF-gate | File `bound_flasher_m.v` mở, trỏ đúng dòng lỗi |
| ⑪ | Nêu miệng giải pháp | "Đổi lại BUF → INV, hoặc re-synthesize, hoặc ECO" |
