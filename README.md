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


# 🔬 PHẦN 1: THỰC HIỆN LEC CƠ BẢN
 
## BƯỚC 1 – Di chuyển vào thư mục làm việc
 
```bash
cd ~/vlsi/2313946/work/lec_env
```
 
 
## BƯỚC 2 – Xác định tên thư mục outputs thực tế
 
> ⚠️ **Quan trọng:** Tên thư mục `outputs_` có timestamp thực tế sẽ khác nhau tùy máy/thời điểm chạy Synthesis. **Luôn xác định tên thư mục trước** khi dùng trong lệnh `ln -sf`.
 
```bash
ls -td ~/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB1/outputs_*/
```
 
Lệnh trên sẽ in ra ví dụ:
```
/home/l04group8/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB1/outputs_Apr10-16:47:59/
```
 
> Nếu có **nhiều thư mục** `outputs_*`, chọn cái in đầu tiên (mới nhất).
 
 
## BƯỚC 3 – Tạo symbolic link từ synthesis_env
 
Thay `outputs_Apr10-16:47:59` bằng tên thư mục **thực tế** tìm được ở Bước 2:
 
```bash
ln -sf ../synthesis_env/Genus_BoundFlasher/RTL/bound_flasher.v
ln -sf ../synthesis_env/Genus_BoundFlasher/LAB1/outputs_Apr10-16:47:59/bound_flasher_m.v
ln -sf ../synthesis_env/Genus_BoundFlasher/LIB/slow.lib
```
 
> ⚠️ **Không dùng wildcard `*`** trong đường dẫn khi tạo symlink — nếu có nhiều thư mục `outputs_*`, wildcard sẽ chọn sai hoặc báo lỗi. Luôn dùng tên thư mục đầy đủ cụ thể.
 
 
## BƯỚC 4 – Kiểm tra link thành công
 
```bash
ll
```
 
✅ Phải thấy 3 file được link (có mũi tên `->` chỉ đến đường dẫn gốc):
```
bound_flasher.v   -> ../synthesis_env/Genus_BoundFlasher/RTL/bound_flasher.v
bound_flasher_m.v -> ../synthesis_env/Genus_BoundFlasher/LAB1/outputs_Apr10-16:47:59/bound_flasher_m.v
slow.lib          -> ../synthesis_env/Genus_BoundFlasher/LIB/slow.lib
```
 
❌ Nếu thấy link màu đỏ (broken link) → kiểm tra lại tên thư mục `outputs_` trong Bước 3.
 
 
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
| `read_library slow.lib -lib -revised` | Load thư viện cell để giải nghĩa các gate trong Netlist |
| `read_design ... -golden` | Đọc RTL làm **chuẩn** (Golden) |
| `read_design ... -revised` | Đọc Netlist cần kiểm tra (Revised) |
| `set_mapping_method -name only` | Mapping key points theo tên signal |
| `set_system_mode lec` | Chuyển sang chế độ kiểm tra tương đương |
| `map_key_points` | Tạo bản đồ mapping giữa Golden và Revised |
| `add_compared_points -all` | Thêm tất cả điểm vào danh sách so sánh |
| `compare` | Thực hiện so sánh và xuất kết quả |
 

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
 
---
 
## BƯỚC 7 – Chạy LEC
 
```bash
./go_lec
```
 
> Conformal sẽ tự động mở GUI và thực thi các lệnh trong `lec.tcl`.
 
 
## BƯỚC 8 – Kiểm tra kết quả trên GUI
 
Khi quá trình hoàn tất, quan sát cửa sổ GUI:
 
- ✅ **Không có Non-equivalent points** → Netlist tương đương RTL → LEC PASS
- ❌ **Có Non-equivalent points** → sang Phần 2 để debug
Sau khi xem xong, gõ `exit` vào terminal của GUI để thoát.
 

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


## BƯỚC 11 – Tìm cell INV để sửa

Trước khi vào vi, tìm dòng có INV cell trong Netlist:

```bash
grep -n "INV" bound_flasher_m.v | head -10
```

Kết quả thực tế trên hệ thống này:
```
104:  INVX2 g4997(.A (n_130), .Y (n_146));
166:  INVX1 g5078(.A (n_63), .Y (n_64));
178:  INVX1 g5071(.A (n_69), .Y (n_78));
```

Ghi nhớ số dòng của **1 cell bất kỳ** (ví dụ dòng 47) để dùng trong bước tiếp theo.


## BƯỚC 12 – Tạo bug trong Netlist

> 📌 Thư viện `slow.lib` trên hệ thống này dùng cell **INVX1/INVX2** với port output **`.Y`** (không phải `.ZN`). Cell BUF tương ứng là **BUFX1/BUFX2** cũng dùng port **`.Y`**.
 
Sửa bằng `sed` (chỉ đổi tên cell, giữ nguyên port `.Y`):**
 
```bash
# Đổi INVX2 → BUFX2 tại dòng 104
sed -i '104s/INVX2/BUFX2/' bound_flasher_m.v
```
 
Xác nhận đã sửa đúng:
```bash
sed -n '104p' bound_flasher_m.v
```
 
✅ Phải thấy:
```
BUFX2 g4997(.A (n_130), .Y (n_146));
```


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


## ⚠️ CẢNH BÁO QUAN TRỌNG – Warning RTL14
 
Trong quá trình chạy Phần 1, Conformal phát sinh cảnh báo:
 
```
Warning: (RTL14) Signal has input but it has no output (occurrence:3)
```
 
### Warning này là gì?
 
Có **3 tín hiệu nội bộ** trong Netlist được kết nối vào pin input của một cell nhưng **không có cell nào drive** (tạo ra) tín hiệu đó — tức là wire có đầu nhận nhưng không có đầu phát.
 
### Vì sao xuất hiện?
 
Đây là hệ quả **bình thường của quá trình synthesis**, do 3 nguyên nhân chính:
 
**① Synthesis tối ưu hóa logic**
Genus loại bỏ (optimize away) một số gate trong quá trình tối ưu, khiến tín hiệu đầu ra biến mất nhưng wire kết nối vẫn còn trong Netlist.
 
**② Don't-care conditions trong RTL**
File `bound_flasher.v` có một số điều kiện `default case` với phép gán non-X (thể hiện qua `Note RTL5.5a` trong log). Sau synthesis, những nhánh này có thể tạo ra dangling wire không có driver.
 
**③ Tín hiệu tie-off ngầm**
Một số tín hiệu được gán giá trị cố định bên trong thư viện cell mà không có wire rõ ràng trong Netlist — Conformal thấy thiếu driver nên báo warning.
 
### Mức độ ảnh hưởng
 
**Không ảnh hưởng** đến kết quả LEC. Conformal chỉ phát sinh warning ở giai đoạn `read_design`, không dừng quá trình so sánh. Toàn bộ **36/36 điểm vẫn EQUIVALENT**.
 
### Cách khắc phục
 
| Phương pháp | Cách thực hiện | Khi nào dùng |
|-------------|---------------|--------------|
| **Bổ sung `default` trong RTL** | Thêm `default` đầy đủ trong tất cả `case` statement của `bound_flasher.v` | Giải pháp triệt để nhất |
| **Thêm constraint synthesis** | Thêm `set_db / .resolve_undriven_nets tie_low` vào `run.tcl` trước khi chạy Genus | Tự tie-off net không có driver |
| **Suppress trong Conformal** | Thêm `set_undefined_cell black_box -both` vào `lec.tcl` | Khi không muốn sửa RTL hoặc re-synthesize |
| **Chấp nhận warning** | Không can thiệp | Trong lab — LEC vẫn PASS, hoàn toàn hợp lý |
 

# 🐛 PHẦN 2: DEBUG NON-EQUIVALENT POINT
 
> Phần này cố tình tạo bug trong Netlist để thực hành quy trình debug.
 
## BƯỚC 10 – Xóa link cũ, copy thật Netlist vào
 
```bash
rm -rf bound_flasher_m.v
cp -rf ../synthesis_env/Genus_BoundFlasher/LAB1/outputs_Apr10-16:47:59/bound_flasher_m.v ./
```
 
> ⚠️ **Phải copy thật** (không dùng `ln`), vì bước tiếp theo cần chỉnh sửa file. Sửa symlink sẽ ảnh hưởng đến file gốc trong `synthesis_env`.
>
> ⚠️ **Không dùng wildcard** trong lệnh `cp`. Dùng tên thư mục đầy đủ cụ thể.
 
Kiểm tra đã copy thật (không có mũi tên `->` ):
 
```bash
ll
```
 
## BƯỚC 11 – Tìm cell INV để sửa
 
```bash
grep -n "INV" bound_flasher_m.v | head -10
```
 
Kết quả thực tế trên hệ thống này:
```
104:  INVX2 g4997(.A (n_130), .Y (n_146));
166:  INVX1 g5078(.A (n_63), .Y (n_64));
178:  INVX1 g5071(.A (n_69), .Y (n_78));
```
 
> 📌 Thư viện `slow.lib` trên hệ thống này dùng port output **`.Y`** cho cả INV và BUF — **không phải `.ZN` hay `.Z`**. Chỉ cần đổi tên cell, giữ nguyên port.
 
 
## BƯỚC 12 – Tạo bug trong Netlist
 
### Cách 1: Dùng `sed` (nhanh, khuyến nghị)
 
```bash
# Đổi INVX2 → BUFX2 tại dòng 104 (chỉ đổi tên cell, giữ nguyên port .Y)
sed -i '104s/INVX2/BUFX2/' bound_flasher_m.v
 
# Xác nhận đã sửa đúng
sed -n '103,105p' bound_flasher_m.v
```
 
✅ Phải thấy dòng 104:
```
BUFX2 g4997(.A (n_130), .Y (n_146));
```
 
### Cách 2: Dùng `vi`
 
```bash
vi +104 ./bound_flasher_m.v
# Nhấn i → đổi INVX2 → BUFX2 → Esc → :wq
```
 
> ### ⚠️ Lưu ý về tên port BUF
> Tên port output của BUF cell **phụ thuộc vào thư viện**:
>
> | Thư viện | INV port | BUF port |
> |----------|----------|----------|
> | slow.lib (hệ thống này) | `.Y` | `.Y` |
> | Một số thư viện khác | `.ZN` | `.Z` |
>
> Nếu Conformal báo lỗi `port not found` → kiểm tra tên port thực tế:
> ```bash
> grep -A 10 "cell (BUF" slow.lib | grep "pin ("
> ```
 
---
 
## BƯỚC 13 – Chạy lại LEC với Netlist đã bị sửa
 
```bash
./go_lec
```

 
## BƯỚC 14 – Quan sát Non-equivalent points trên GUI
 
Khi GUI mở, sẽ xuất hiện danh sách **Non-equivalent points** trong cửa sổ chính.
 
 
## BƯỚC 15 – Debug bằng Mapping Manager và Schematics Viewer
 
| Bước | Thao tác | Kết quả cần thấy |
|------|----------|-----------------|
| ① | Click mở **Mapping Manager** | Cửa sổ Mapping Manager hiện ra |
| ② | Class → Disable All → **Non-Equivalent** | Danh sách lọc chỉ còn 3 điểm lỗi: `state_reg[0]`, `state_reg[1]`, `state_reg[3]` |
| ③ | Right-click điểm lỗi → **Diagnose** | Cửa sổ Diagnosis Manager mở, hiện Error Candidate với confidence 1.00 |
| ④ | Chọn **Schematics** | Schematics Viewer hiện 2 schematic song song |
| ⑤ | Quan sát endpoint (vòng tròn hồng) | Revised (trái) = 1, Golden (phải) = 0 → khác nhau |
| ⑥ | Right-click pin → **Fan-in Cone → Open** | Logic cone mở rộng để trace ngược |
| ⑦ | Quan sát gate màu **tím** | Gate tím = có counterpart tương đương bên kia → dùng làm mốc định hướng |
| ⑧ | Tìm gate màu **hồng** | **BUFX2 g4997** = root cause (không có counterpart) |
| ⑨ | Hover chuột lên gate hồng | Tooltip hiện số dòng 104 trong source code |
| ⑩ | Double-click gate hồng | File `bound_flasher_m.v` mở, trỏ đúng dòng 104 |
| ⑪ | Nêu giải pháp | Đổi lại BUFX2 → INVX2, hoặc re-synthesize, hoặc ECO |
 
 
# 📌 TÓM TẮT TOÀN BỘ QUY TRÌNH
 
```
PHẦN 1: LEC CƠ BẢN
────────────────────────────────────────────────────────────────
BƯỚC 1  → cd ~/vlsi/2313946/work/lec_env
 
BƯỚC 2  → ls -td .../LAB1/outputs_*/
           (xác định tên thư mục thực tế, không dùng wildcard)
 
BƯỚC 3  → ln -sf .../RTL/bound_flasher.v
           ln -sf .../LAB1/outputs_Apr10-16:47:59/bound_flasher_m.v
           ln -sf .../LIB/slow.lib
 
BƯỚC 4  → ll  (kiểm tra 3 link, không có broken link đỏ)
 
BƯỚC 5  → vi ./lec.tcl  (nhập nội dung script, lưu :wq)
 
BƯỚC 6  → vi ./go_lec   (nhập nội dung script, lưu :wq)
           chmod +x ./go_lec
 
BƯỚC 7  → ./go_lec
 
BƯỚC 8  → GUI mở → không có Non-equivalent → gõ exit ✅
 
BƯỚC 9  → grep -i "equivalent" lec.log
           → thấy EQUIVALENT, không có NON-EQUIVALENT ✅
 
           ⚠️ Warning RTL14 (occurrence:3) → bình thường, không ảnh hưởng
              Nguyên nhân: synthesis optimize + don't-care RTL
              Khắc phục: bổ sung default trong case statement RTL
────────────────────────────────────────────────────────────────
PHẦN 2: DEBUG NON-EQUIVALENT POINT
────────────────────────────────────────────────────────────────
BƯỚC 10 → rm -rf bound_flasher_m.v
           cp -rf .../outputs_Apr10-16:47:59/bound_flasher_m.v ./
 
BƯỚC 11 → grep -n "INV" bound_flasher_m.v | head -10
           → thấy dòng 104: INVX2 g4997(.A(n_130), .Y(n_146))
 
BƯỚC 12 → sed -i '104s/INVX2/BUFX2/' bound_flasher_m.v
           sed -n '103,105p' bound_flasher_m.v  (xác nhận)
           (chỉ đổi tên cell, giữ nguyên port .Y)
 
BƯỚC 13 → ./go_lec
 
BƯỚC 14 → GUI hiện Non-equivalent points (3 DFF bị lỗi)
 
BƯỚC 15 → Debug theo thứ tự:
           ① Mapping Manager
           ② Class → Disable All → Non-Equivalent
           ③ Right-click → Diagnose → Error Candidate BUF dòng 104
           ④ Schematics Viewer
           ⑤ Revised (trái)=1 ≠ Golden (phải)=0
           ⑥ Fan-in Cone → Open
           ⑦ Gate tím = mốc định hướng
           ⑧ Gate hồng = BUFX2 g4997 = root cause
           ⑨ Hover → dòng 104
           ⑩ Double-click → source code mở
           ⑪ Giải pháp: BUFX2→INVX2, re-synthesize, hoặc ECO ✅
```
 
 
## ❓ XỬ LÝ LỖI THƯỜNG GẶP
 
| Vấn đề | Nguyên nhân | Cách xử lý |
|--------|-------------|------------|
| Link màu đỏ (broken) sau `ll` | Đường dẫn `ln -sf` sai hoặc chưa có file Netlist | Kiểm tra `ls .../LAB1/outputs_*/` |
| `lec.log` báo `cannot find design` | Tên design trong `lec.tcl` không khớp với tên module trong file `.v` | Kiểm tra `grep "^module" bound_flasher.v` |
| GUI không mở | License chưa được source | Đảm bảo đã chạy `source add_path` và `source add_license` |
| Non-equivalent vẫn xuất hiện sau khi fix | Chỉnh sửa symlink thay vì file thật | Xóa symlink, copy file thật, sửa lại |
| `port not found` khi chạy Conformal | Tên port BUF trong thư viện khác `.Y` | Chạy `grep -A 10 "cell (BUF" slow.lib \| grep "pin ("` |
| Nhiều thư mục `outputs_*` | Nhiều lần chạy Synthesis | Dùng `ls -td .../outputs_*/ \| head -1` để lấy cái mới nhất |
| Warning RTL14 (occurrence:3) | Synthesis optimize + don't-care RTL | Bình thường, không ảnh hưởng LEC — xem mục Warning RTL14 |
 
 
# 🎬 DEMO – CHẠY SHOW KẾT QUẢ CUỐI
 
> Chạy theo thứ tự này khi demo nộp bài.
 
### 1. Show cấu trúc thư mục lec_env
 
```bash
ll ~/vlsi/2313946/work/lec_env/
```
✅ Thấy 3 symlink (`bound_flasher.v`, `slow.lib`) + 1 file thật (`bound_flasher_m.v`) + `lec.tcl` + `go_lec`

 
### 2. Show nội dung file lec.tcl
 
```bash
cat ~/vlsi/2313946/work/lec_env/lec.tcl
```
✅ Thấy đầy đủ: `read_library`, `read_design -golden`, `read_design -revised`, `compare`

 
### 3. Show nội dung file go_lec
 
```bash
cat ~/vlsi/2313946/work/lec_env/go_lec
```
✅ Thấy `source add_license` và `lec -64 -dofile ./lec.tcl`
 
---
 
### 4. [PHẦN 1] Show log LEC Pass
 
```bash
grep -i "equivalent\|non-equivalent" ~/vlsi/2313946/work/lec_env/lec.log
```
✅ Thấy `EQUIVALENT`, không có `NON-EQUIVALENT`
 

 
### 5. [PHẦN 2] Show Netlist đã bị sửa bug
 
```bash
sed -n '103,105p' ~/vlsi/2313946/work/lec_env/bound_flasher_m.v
```
✅ Thấy dòng 104 là `BUFX2` (đã đổi từ `INVX2`)
 

### 6. [PHẦN 2] Show kết quả Non-Equivalent từ log
 
```bash
grep -i "non-equivalent\|equivalent" ~/vlsi/2313946/work/lec_env/lec.log
```
✅ Thấy `NON-EQUIVALENT` → Conformal đã phát hiện lỗi
 
> 📌 **Lưu ý:** `lec.log` bị ghi đè mỗi lần chạy `./go_lec` (do `-replace` trong `set_log_file`).
> Khi demo: show log Phần 1 trước → chạy Phần 2 → show log Phần 2.
> Hoặc đổi tên log trong `lec.tcl`: `lec_pass.log` cho Phần 1, `lec_fail.log` cho Phần 2.
 

 
### 7. [PHẦN 2] Demo debug trên GUI
 
> Nếu GUI còn mở → dùng luôn. Nếu đã thoát → show trực tiếp từ log terminal.
 
| Bước | Thao tác | Kết quả cần thấy |
|------|----------|-----------------|
| ① | Click mở **Mapping Manager** | Cửa sổ Mapping Manager hiện ra |
| ② | Class → Disable All → **Non-Equivalent** | Còn 3 điểm lỗi: `state_reg[0/1/3]` |
| ③ | Right-click → **Diagnose** | Diagnosis Manager: BUF dòng 104, confidence 1.00 |
| ④ | Chọn **Schematics** | 2 schematic song song |
| ⑤ | Quan sát endpoint | Revised (trái) ≠ Golden (phải) |
| ⑥ | Right-click pin → **Fan-in Cone → Open** | Logic cone mở rộng |
| ⑦ | Gate tím | Mốc định hướng debug |
| ⑧ | Gate hồng | **BUFX2 g4997** = root cause |
| ⑨ | Hover chuột | Tooltip hiện dòng 104 |
| ⑩ | Double-click gate | Source code mở, trỏ dòng 104 |
| ⑪ | Nêu giải pháp | BUFX2→INVX2, re-synthesize, hoặc ECO |
