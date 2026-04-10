# HƯỚNG DẪN CHI TIẾT LAB2 – SYNTHESIS VỚI CADENCE GENUS

> **Thông tin sinh viên:**
> - Group: `l04group8`
> - Student ID: `2313946`
> - File RTL có sẵn tại: `~/vlsi/2313946/work/simulation_env/bound_flasher.v`
> - Thư mục làm việc LAB2: `~/vlsi/2313946/work/synthesis_env/`

## TỔNG QUAN

LAB2 gồm 3 phần chính:

| Phần | Nội dung |
|------|----------|
| **Phần 1 – LAB1** | Basic Genus Flow (Synthesis cơ bản) |
| **Phần 2 – LAB3** | Low-Power Synthesis (Synthesis tiết kiệm điện) |
| **Phần 3** | Tìm tần số tối đa & Nộp bài |

> ✅ Thư mục đã được tạo sẵn từ LAB1. File `bound_flasher.v` đã có sẵn tại `simulation_env/`.

## 🗂️ Cấu trúc thư mục

```
~/vlsi/2313946/work/
├── simulation_env/
│   ├── bound_flasher.v          ← File RTL nguồn (từ LAB1 trước)
│   └── bound_flasher_tb.v
└── synthesis_env/
    └── Genus_BoundFlasher/      ← Thư mục làm việc chính
        ├── RTL/
        │   └── bound_flasher.v  ← Copy RTL vào đây
        ├── LIB/                 ← Có sẵn trong kit
        ├── LEF/                 ← Có sẵn trong kit
        ├── constraints/
        │   └── bound_flasher_gate.sdc
        ├── LAB1/
        │   ├── run.tcl
        │   ├── gui.tcl
        │   ├── sync.log         ← Sinh ra sau khi chạy
        │   ├── outputs_{DATE}/
        │   │   └── bound_flasher_m.v
        │   └── reports_{DATE}/
        │       ├── final_area.rpt
        │       ├── final_qor.rpt
        │       └── final_time.rpt
        └── LAB3/
```

---

## BƯỚC 1 – Copy Sample Environment Kit

```bash
cd ~/vlsi/2313946/work/synthesis_env
```

```bash
cp -rf /home/share_file/cadence/installs/Genus_CUI_RAK/ ./Genus_BoundFlasher
```

Kiểm tra đã copy thành công:

```bash
ls Genus_BoundFlasher
```

✅ Phải thấy các thư mục: `RTL/` `LIB/` `LEF/` `constraints/` `LAB1/` `LAB2/` `LAB3/`

> 📌 File `run.tcl` bên trong các thư mục LAB1/LAB3 **đã có sẵn**, bạn chỉ cần **sửa** cho đúng tên design.

---

## BƯỚC 2 – Copy file RTL vào đúng chỗ

Vì bạn đang đứng tại `synthesis_env`, dùng đường dẫn tương đối cho gọn:

```bash
cp ../simulation_env/bound_flasher.v ./Genus_BoundFlasher/RTL/
```

Kiểm tra đã copy thành công:

```bash
ls ./Genus_BoundFlasher/RTL/
```

✅ Phải thấy file `bound_flasher.v` trong đó.

---

## BƯỚC 3 – Tạo file Constraint (SDC)

```bash
vi ./Genus_BoundFlasher/constraints/bound_flasher_gate.sdc
```

Nhập toàn bộ nội dung sau, lưu lại bằng `:wq`:

```tcl
# Set the current design
current_design bound_flasher

create_clock -name "clk" -add -period 5.0 -waveform {0.0 2.5} [get_ports clk]

set_input_delay  -clock [get_clocks clk] -add_delay 2.5 [get_ports flick]
set_input_delay  -clock [get_clocks clk] -add_delay 2.5 [get_ports rst_n]
set_output_delay -clock [get_clocks clk] -add_delay 2.5 [get_ports lamp ]

set_max_fanout 15.000 [current_design]
set_max_transition 1.2 [current_design]
```

> 📌 Period `5.0 ns` = tần số **200 MHz**. Waveform `{0.0 2.5}` và delay `2.5` luôn bằng **50% period**.

---

# 🔬 PHẦN 1: LAB1 – BASIC GENUS FLOW

## BƯỚC 4 – Sửa file run.tcl của LAB1

Dùng lệnh Python để sửa tự động, không cần vào vi:

```bash
python3 -c "
import re
with open('./Genus_BoundFlasher/LAB1/run.tcl', 'r') as f:
    content = f.read()

content = content.replace('set DESIGN dtmf_recvr_core', 'set DESIGN bound_flasher')
content = re.sub(r'read_hdl \".*?\"', 'read_hdl \"bound_flasher.v\"', content, flags=re.DOTALL)
content = content.replace('read_sdc ../constraints/dtmf_recvr_core_gate.sdc', 'read_sdc ../constraints/bound_flasher_gate.sdc')
content = content.replace('## write_hdl  > \${_OUTPUTS_PATH}/\${DESIGN}_m.v', 'write_hdl  > \${_OUTPUTS_PATH}/\${DESIGN}_m.v')

with open('./Genus_BoundFlasher/LAB1/run.tcl', 'w') as f:
    f.write(content)
print('Done')
"
```

Kiểm tra lại:

```bash
grep -n "set DESIGN\|read_hdl\|read_sdc\|write_hdl" ./Genus_BoundFlasher/LAB1/run.tcl
```

✅ Phải thấy:
```
set DESIGN bound_flasher
read_hdl "bound_flasher.v"
read_sdc ../constraints/bound_flasher_gate.sdc
write_hdl  > ${_OUTPUTS_PATH}/${DESIGN}_m.v
```

---

## BƯỚC 5 – Chạy Synthesis

```bash
cd /home/share_file/cadence
source add_path
source add_license
cd ~/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB1
genus -f run.tcl | tee -i sync.log
```

> Chờ đến khi terminal trở về dấu nhắc lệnh. Synthesis mất khoảng **1–3 phút**.
> Nếu quá **5 phút** mà chưa xong → nhấn `Ctrl + C` để dừng và kiểm tra lại.

---

## BƯỚC 6 – Kiểm tra Log (bắt buộc)

```bash
vi sync.log
```

Gõ `/Error` để tìm lỗi:
- **`Pattern not found`** → không có lỗi ✅ gõ `:q` thoát, tiếp tục Bước 7
- **Nhảy đến dòng Error** → đọc lỗi, sửa file rồi chạy lại từ Bước 5

---

## BƯỚC 7 – Kiểm tra Synthesis Report

> 📌 Report được lưu vào thư mục tên theo ngày giờ, ví dụ `reports_Apr10-08:29:43/`.
> Xem thư mục mới nhất bằng lệnh:

```bash
ls -td ~/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB1/reports_*/ | head -1
```

Xem 3 report (thay `reports_Apr10-XX:XX:XX` bằng tên thư mục mới nhất):

```bash
# Report 1: Diện tích chip
vi reports_Apr10-XX:XX:XX/final_area.rpt
```

```bash
# Report 2: Quality of Results
vi reports_Apr10-XX:XX:XX/final_qor.rpt
```

```bash
# Report 3: Timing – QUAN TRỌNG NHẤT
vi reports_Apr10-XX:XX:XX/final_time.rpt
```

Trong `final_time.rpt`, gõ `/Slack` để tìm **Critical Path Slack (CPS)**:
- CPS **`>= 0 ps`** → **PASS** ✅
- CPS **`< 0 ps`** → **FAIL** ❌ cần tăng period lại

---

## BƯỚC 8 – Tạo file gui.tcl và xem Schematic (tùy chọn)

```bash
cd ~/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB1
vi gui.tcl
```

Nhấn `i`, nhập nội dung sau, nhấn `Esc` rồi `:wq`:

```tcl
set DESIGN bound_flasher

read_libs "../LIB/slow.lib ../LIB/pll.lib ../LIB/CDK_S128x16.lib ../LIB/CDK_S256x16.lib ../LIB/CDK_R512x16.lib"

read_physical -lef "../LEF/gsclib045_tech.lef ../LEF/gsclib045_macro.lef ../LEF/pll.lef ../LEF/CDK_S128x16.lef ../LEF/CDK_S256x16.lef ../LEF/CDK_R512x16.lef"

read_hdl "./outputs_Apr10-XX:XX:XX/bound_flasher_m.v"

elaborate $DESIGN
```

> 📌 Thay `outputs_Apr10-XX:XX:XX` bằng tên thư mục output thực tế:
> ```bash
> ls -td ~/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB1/outputs_*/
> ```

Mở GUI:

```bash
genus -f gui.tcl -gui
```

Trong cửa sổ GUI: **Right Click** vào `bound_flasher` → chọn **Schematic** → chụp màn hình lưu lại cho report.

---

# ⚡ PHẦN 2: LAB3 – LOW-POWER SYNTHESIS

## BƯỚC 9 – Sửa file run.tcl của LAB3

```bash
python3 -c "
import re
with open('./Genus_BoundFlasher/LAB3/run.tcl', 'r') as f:
    content = f.read()

content = content.replace('set DESIGN dtmf_recvr_core', 'set DESIGN bound_flasher')
content = re.sub(r'read_hdl \".*?\"', 'read_hdl \"bound_flasher.v\"', content, flags=re.DOTALL)
content = content.replace('read_sdc ../constraints/dtmf_recvr_core_gate.sdc', 'read_sdc ../constraints/bound_flasher_gate.sdc')
content = content.replace('## write_hdl  > \${_OUTPUTS_PATH}/\${DESIGN}_m.v', 'write_hdl  > \${_OUTPUTS_PATH}/\${DESIGN}_m.v')

with open('./Genus_BoundFlasher/LAB3/run.tcl', 'w') as f:
    f.write(content)
print('Done')
"
```

Thêm cấu hình Low-Power vào `run.tcl` của LAB3:

**Thêm TRƯỚC lệnh `elaborate`:**
```tcl
set_db / .lp_insert_clock_gating true
set_db / .leakage_power_effort medium
```

**Thêm SAU lệnh `elaborate`:**
```tcl
set_db "design:$DESIGN" .max_leakage_power            0.0
set_db "design:$DESIGN" .lp_power_optimization_weight 0.5
set_db "design:$DESIGN" .max_dynamic_power            100
```

> 📌 `lp_insert_clock_gating true` bắt buộc phải đặt **trước** `elaborate`.

---

## BƯỚC 10 – Chạy Synthesis LAB3

```bash
cd /home/share_file/cadence
source add_path
source add_license
cd ~/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB3
genus -f run.tcl | tee -i sync.log
```

---

## BƯỚC 11 – Kiểm tra Log & Report LAB3

```bash
vi sync.log
```

```bash
vi reports_Apr10-XX:XX:XX/final_time.rpt
```

Gõ `/Slack` → CPS >= 0 là đạt ✅

---

# 🔍 PHẦN 3: TÌM TẦN SỐ TỐI ĐA

> Mục tiêu: **giảm period đến mức nhỏ nhất mà CPS vẫn >= 0**.
> **f_max = 1 / period_nhỏ_nhất_đạt_yêu_cầu**

## BƯỚC 12 – Sửa SDC và chạy lại nhiều lần

Dùng lệnh này để sửa SDC nhanh (thay số period và delay tương ứng):

```bash
cat > ~/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/constraints/bound_flasher_gate.sdc << 'EOF'
current_design bound_flasher

create_clock -name "clk" -add -period X.X -waveform {0.0 Y.Y} [get_ports clk]

set_input_delay  -clock [get_clocks clk] -add_delay Y.Y [get_ports flick]
set_input_delay  -clock [get_clocks clk] -add_delay Y.Y [get_ports rst_n]
set_output_delay -clock [get_clocks clk] -add_delay Y.Y [get_ports lamp ]

set_max_fanout 15.000 [current_design]
set_max_transition 1.2 [current_design]
EOF
```

> 📌 **Quy tắc:** `Y.Y` (delay & waveform) luôn = **50% của X.X** (period).

### Bảng kết quả đã chạy thực tế

| Lần | Period (ns) | Delay (ns) | Tần số | CPS (ps) | Kết quả |
|-----|-------------|------------|--------|----------|---------|
| 1 | 5.0 | 2.5 | 200 MHz | 1556 | ✅ |
| 2 | 3.5 | 1.75 | 286 MHz | 668 | ✅ |
| 3 | 3.0 | 1.5 | 333 MHz | 168 | ✅ |
| 4 | 2.5 | 1.25 | 400 MHz | 16 | ✅ |
| 5 | 1.5 | 0.75 | 667 MHz | 1 | ✅ |
| 6 | **1.4** | **0.7** | **714 MHz** | **0** | ✅ **f_max** |

> 🎯 **f_max = 714 MHz** (period = 1.4 ns, CPS = 0 ps)

Sau mỗi lần sửa SDC, chạy lại synthesis:

```bash
cd /home/share_file/cadence && source add_path && source add_license
cd ~/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB1
genus -f run.tcl | tee -i sync.log
```

Kiểm tra CPS:
```bash
ls -td reports_*/ | head -1   # xem tên thư mục mới nhất
vi reports_Apr10-XX:XX:XX/final_time.rpt
```

---

# 📤 NỘP BÀI

> ⚠️ **LAB1 (basic) và LAB3 (low-power) chỉ để thực hành, không cần nộp.**
> Chỉ nộp **4 file kết quả** từ lần synthesis với **f_max = 1.4 ns**.

Xem thư mục output và report mới nhất:

```bash
ls -td ~/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB1/outputs_*/
ls -td ~/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB1/reports_*/
```

| File cần nộp | Đường dẫn |
|---|---|
| **Netlist** | `~/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB1/outputs_Apr10-XX:XX:XX/bound_flasher_m.v` |
| **Area report** | `~/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB1/reports_Apr10-XX:XX:XX/final_area.rpt` |
| **QoR report** | `~/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB1/reports_Apr10-XX:XX:XX/final_qor.rpt` |
| **Timing report** | `~/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB1/reports_Apr10-XX:XX:XX/final_time.rpt` |

---

# 🎬 DEMO – CHẠY SHOW KẾT QUẢ

> Chạy theo thứ tự này khi demo nộp bài.

### 1. Show cấu trúc thư mục
```bash
ls ~/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/
```

### 2. Show file RTL
```bash
cat ~/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/RTL/bound_flasher.v
```

### 3. Show file SDC với f_max = 1.4 ns
```bash
cat ~/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/constraints/bound_flasher_gate.sdc
```

### 4. Show run.tcl đã sửa
```bash
grep -n "set DESIGN\|read_hdl\|read_sdc\|write_hdl" ~/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB1/run.tcl
```

### 5. Chạy lại synthesis LAB1 với f_max
```bash
cd /home/share_file/cadence && source add_path && source add_license
cd ~/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB1
genus -f run.tcl | tee -i sync.log
```

### 6. Kiểm tra log
```bash
vi sync.log
```
Gõ `/Error` → `Pattern not found` ✅ → `:q`

### 7. Show report Area
```bash
vi $(ls -td reports_*/| head -1)final_area.rpt
```

### 8. Show report QoR
```bash
vi $(ls -td reports_*/| head -1)final_qor.rpt
```

### 9. Show report Timing – CPS = 0
```bash
vi $(ls -td reports_*/| head -1)final_time.rpt
```
Gõ `/Slack` → CPS = **0 ps** ✅ → `:q`

### 10. Mở GUI xem Schematic
```bash
cd ~/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB1
genus -f gui.tcl -gui
```
Right click `bound_flasher` → **Schematic** → chụp màn hình

### 11. Chạy LAB3 Low-Power
```bash
cd /home/share_file/cadence && source add_path && source add_license
cd ~/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB3
genus -f run.tcl | tee -i sync.log
```

### 12. Show report Timing LAB3
```bash
vi $(ls -td reports_*/| head -1)final_time.rpt
```
Gõ `/Slack` → CPS = **16 ps** ✅ → `:q`

### 13. Show bảng kết quả tìm f_max

| Lần | Period (ns) | Delay (ns) | Tần số | CPS (ps) | Kết quả |
|-----|-------------|------------|--------|----------|---------|
| 1 | 5.0 | 2.5 | 200 MHz | 1556 | ✅ |
| 2 | 3.5 | 1.75 | 286 MHz | 668 | ✅ |
| 3 | 3.0 | 1.5 | 333 MHz | 168 | ✅ |
| 4 | 2.5 | 1.25 | 400 MHz | 16 | ✅ |
| 5 | 1.5 | 0.75 | 667 MHz | 1 | ✅ |
| 6 | **1.4** | **0.7** | **714 MHz** | **0** | ✅ **f_max** |

> 🎯 **f_max = 714 MHz**

### 14. Show file netlist nộp bài
```bash
ls $(ls -td ~/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB1/outputs_*/ | head -1)
```

---

## 📌 TÓM TẮT TOÀN BỘ QUY TRÌNH

```
BƯỚC 1  → cd ~/vlsi/2313946/work/synthesis_env
           cp -rf /home/share_file/cadence/installs/Genus_CUI_RAK/ ./Genus_BoundFlasher

BƯỚC 2  → cp ../simulation_env/bound_flasher.v ./Genus_BoundFlasher/RTL/

BƯỚC 3  → vi ./Genus_BoundFlasher/constraints/bound_flasher_gate.sdc
           (Nhập nội dung SDC, lưu :wq)
─────────────────────────────────────────────────────────────────────
PHẦN 1: LAB1 – BASIC SYNTHESIS
BƯỚC 4  → python3 sửa LAB1/run.tcl tự động
BƯỚC 5  → cd /home/share_file/cadence && source add_path && source add_license
           cd ~/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB1
           genus -f run.tcl | tee -i sync.log
BƯỚC 6  → vi sync.log  (tìm Error bằng /Error)
BƯỚC 7  → vi reports_Apr10-XX:XX:XX/final_area.rpt
           vi reports_Apr10-XX:XX:XX/final_qor.rpt
           vi reports_Apr10-XX:XX:XX/final_time.rpt  (CPS >= 0 là đạt ✅)
BƯỚC 8  → vi gui.tcl → genus -f gui.tcl -gui → Right click → Schematic
─────────────────────────────────────────────────────────────────────
PHẦN 2: LAB3 – LOW-POWER SYNTHESIS
BƯỚC 9  → python3 sửa LAB3/run.tcl + thêm set_db low-power
BƯỚC 10 → source license → cd LAB3 → genus -f run.tcl | tee -i sync.log
BƯỚC 11 → vi sync.log và reports_*/final_time.rpt (CPS = 16 ps ✅)
─────────────────────────────────────────────────────────────────────
PHẦN 3: TÌM TẦN SỐ TỐI ĐA
BƯỚC 12 → Giảm period trong SDC → chạy lại LAB1 → kiểm tra CPS
           5.0ns(1556ps) → 3.5ns(668ps) → 3.0ns(168ps) → 2.5ns(16ps)
           → 1.5ns(1ps) → 1.4ns(0ps) ← f_max = 714 MHz 🎉
─────────────────────────────────────────────────────────────────────
NỘP BÀI → 4 file từ lần chạy f_max (period = 1.4 ns):
           outputs_Apr10-XX:XX:XX/bound_flasher_m.v
           reports_Apr10-XX:XX:XX/final_area.rpt
           reports_Apr10-XX:XX:XX/final_qor.rpt
           reports_Apr10-XX:XX:XX/final_time.rpt
```

*Gặp lỗi ở bước nào, đọc `sync.log` và tìm dòng có từ khóa `Error` để xác định nguyên nhân.*
