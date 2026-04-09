# 🔬 HƯỚNG DẪN CHI TIẾT LAB2 – SYNTHESIS VỚI CADENCE GENUS

> **Thông tin sinh viên:**
> - Group: `group08`
> - Student ID: `2313946`
> - File RTL có sẵn tại: `/group08/vlsi/2313946/work/simulation_env/bound_flasher.v`
> - Thư mục làm việc LAB2: `/group08/vlsi/2313946/work/synthesis_env/`

---

## 📋 TỔNG QUAN

LAB2 gồm 3 phần chính:

| Phần | Nội dung |
|------|----------|
| **Phần 1 – LAB1** | Basic Genus Flow (Synthesis cơ bản) |
| **Phần 2 – LAB3** | Low-Power Synthesis (Synthesis tiết kiệm điện) |
| **Phần 3** | Tìm tần số tối đa & Nộp bài |

> ✅ Thư mục đã được tạo sẵn từ LAB1. File `bound_flasher.v` và `bound_flasher_tb.v` đã có sẵn tại `simulation_env/`.

---

## 📦 BƯỚC 1 – Copy Sample Environment Kit

Đây là bước đầu tiên, copy toàn bộ kit mẫu từ Cadence về thư mục synthesis của bạn:

```bash
cd /group08/vlsi/2313946/work/synthesis_env
```

```bash
cp -rf /home/share_file/cadence/installs/Genus_CUI_RAK/ ./Genus_BoundFlasher
```

Kiểm tra đã copy thành công chưa:

```bash
ls Genus_BoundFlasher
```

✅ Kết quả phải thấy các thư mục: `RTL/` `LIB/` `LEF/` `constraints/` `LAB1/` `LAB3/`

> 📌 **Lưu ý:** Toàn bộ thư mục `LAB1/`, `LAB3/`, `LIB/`, `LEF/` đều **có sẵn trong kit**, không cần tự tạo. File `run.tcl` bên trong cũng đã có sẵn, bạn chỉ cần **sửa** cho đúng tên design.

---

## 📁 BƯỚC 2 – Copy file RTL vào đúng chỗ

Copy `bound_flasher.v` từ thư mục simulation (LAB1) sang thư mục RTL của kit:

```bash
cp /group08/vlsi/2313946/work/simulation_env/bound_flasher.v \
   /group08/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/RTL/
```

Kiểm tra đã copy thành công chưa:

```bash
ls /group08/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/RTL/
```

✅ Phải thấy file `bound_flasher.v` trong đó.

---

## ✏️ BƯỚC 3 – Tạo file Constraint (SDC)

File này định nghĩa clock và timing cho quá trình synthesis:

```bash
vi /group08/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/constraints/bound_flasher_gate.sdc
```

Nhập toàn bộ nội dung bên dưới vào, sau đó lưu lại bằng `:wq`:

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

---

# 🔬 PHẦN 1: LAB1 – BASIC GENUS FLOW

---

## ✏️ BƯỚC 4 – Sửa file run.tcl của LAB1

File `run.tcl` **đã có sẵn** trong kit, bạn chỉ cần mở và sửa đúng các chỗ:

```bash
vi /group08/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB1/run.tcl
```

Tìm và sửa **đúng 4 chỗ** sau (giữ nguyên toàn bộ phần còn lại của file):

```tcl
# Chỗ 1: Tên module design
set DESIGN bound_flasher

# Chỗ 2: Tên file RTL
read_hdl "bound_flasher.v"

# Chỗ 3: File constraint
read_sdc ../constraints/bound_flasher_gate.sdc

# Chỗ 4: Output netlist (thường đã đúng, kiểm tra lại)
write_hdl > ${_OUTPUTS_PATH}/${DESIGN}_m.v
```

> 📌 Đảm bảo cuối file có dòng `quit` — nếu không có thì thêm vào. Thiếu dòng này Genus sẽ không thoát sau khi synthesis xong.

Lưu lại: `:wq`

---

## ▶️ BƯỚC 5 – Chạy Synthesis

Thực hiện **lần lượt từng lệnh** theo đúng thứ tự:

```bash
# Bước 5.1 – Vào thư mục cadence để lấy license
cd /home/share_file/cadence
```

```bash
# Bước 5.2 – Load đường dẫn tool
source add_path
```

```bash
# Bước 5.3 – Load license
source add_license
```

```bash
# Bước 5.4 – Vào thư mục LAB1
cd /group08/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB1
```

```bash
# Bước 5.5 – Chạy synthesis và lưu log
genus -f run.tcl | tee -i sync.log
```

> ⏳ Chờ đến khi terminal trở về dấu nhắc lệnh. Synthesis mất khoảng **1–3 phút**.  
> ⚠️ Nếu quá **5 phút** mà chưa xong → có thể bị hang, nhấn `Ctrl + C` để dừng và kiểm tra lại.

---

## 🔍 BƯỚC 6 – Kiểm tra Log (bắt buộc)

```bash
vi /group08/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB1/sync.log
```

> 💡 Dùng `/Error` trong vi để tìm nhanh từ khóa lỗi.

- ✅ **Không có từ `Error`** → synthesis thành công, tiếp tục Bước 7
- ❌ **Có `Error`** → phải đọc lỗi, sửa file rồi chạy lại từ Bước 5

---

## 📊 BƯỚC 7 – Kiểm tra Synthesis Report

```bash
cd /group08/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB1
```

Xem từng report:

```bash
# Report 1: Diện tích chip
vi reports*/final_area.rpt
```

```bash
# Report 2: Quality of Results
vi reports*/final_qor.rpt
```

```bash
# Report 3: Timing – QUAN TRỌNG NHẤT
vi reports*/final_time.rpt
```

> ✅ Trong `final_time.rpt`, tìm dòng **Critical Path Slack (CPS)**:
> - CPS **`>= 0 ps`** → **PASS** ✅ Netlist hợp lệ, đạt yêu cầu
> - CPS **`< 0 ps`** → **FAIL** ❌ Cần giảm tần số hoặc kiểm tra lại design

---

## 🖥️ BƯỚC 8 – Tạo file gui.tcl để xem Schematic (tùy chọn)

```bash
vi /group08/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB1/gui.tcl
```

Nhập toàn bộ nội dung sau, lưu lại bằng `:wq`:

```tcl
set DESIGN bound_flasher

read_libs "../LIB/slow.lib ../LIB/pll.lib ../LIB/CDK_S128x16.lib ../LIB/CDK_S256x16.lib ../LIB/CDK_R512x16.lib"

read_physical -lef "../LEF/gsclib045_tech.lef ../LEF/gsclib045_macro.lef ../LEF/pll.lef ../LEF/CDK_S128x16.lef ../LEF/CDK_S256x16.lef ../LEF/CDK_R512x16.lef"

read_hdl "./outputs/bound_flasher_m.v"

elaborate $DESIGN
```

Mở GUI:

```bash
genus -f gui.tcl -gui
```

> Trong cửa sổ GUI: **Right Click** vào tên design → chọn **Schematic** để xem netlist dạng sơ đồ.

---

---

# ⚡ PHẦN 2: LAB3 – LOW-POWER SYNTHESIS

> LAB3 giống hệt LAB1, chỉ khác ở 2 điểm: dùng thư mục `LAB3/` và thêm cấu hình tiết kiệm điện vào `run.tcl`.

---

## ✏️ BƯỚC 9 – Sửa file run.tcl của LAB3

```bash
vi /group08/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB3/run.tcl
```

**Sửa 4 chỗ tên design và file** giống hệt Bước 4 của LAB1:

```tcl
set DESIGN bound_flasher
read_hdl "bound_flasher.v"
read_sdc ../constraints/bound_flasher_gate.sdc
write_hdl > ${_OUTPUTS_PATH}/${DESIGN}_m.v
```

**Thêm thêm** 2 block cấu hình Low-Power sau:

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

Lưu lại: `:wq`

> 📌 Giải thích các thuộc tính Low-Power:
> - `lp_insert_clock_gating true` → Bật tính năng Clock Gating để tiết kiệm điện động
> - `leakage_power_effort medium` → Mức độ tối ưu hóa điện rò rỉ
> - `lp_power_optimization_weight 0.5` → Cân bằng giữa tối ưu điện động và điện rò (0=chỉ leakage, 1=chỉ dynamic)
> - `max_dynamic_power 100` → Giới hạn công suất động tối đa

---

## ▶️ BƯỚC 10 – Chạy Synthesis LAB3

```bash
# Bước 10.1
cd /home/share_file/cadence
```

```bash
# Bước 10.2
source add_path
```

```bash
# Bước 10.3
source add_license
```

```bash
# Bước 10.4
cd /group08/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB3
```

```bash
# Bước 10.5
genus -f run.tcl | tee -i sync.log
```

---

## 🔍 BƯỚC 11 – Kiểm tra Log & Report LAB3

Kiểm tra log:

```bash
vi /group08/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB3/sync.log
```

Kiểm tra report:

```bash
cd /group08/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB3

vi reports*/final_area.rpt   # Diện tích
vi reports*/final_qor.rpt    # QoR
vi reports*/final_time.rpt   # Timing – CPS >= 0 là đạt
```

---

---

# 🔍 PHẦN 3: TÌM TẦN SỐ TỐI ĐA

> Tái sử dụng LAB1. Mục tiêu: **giảm period đến mức nhỏ nhất mà CPS vẫn >= 0**.  
> Tần số tối đa = `1 / period_nhỏ_nhất_đạt_yêu_cầu`

---

## ✏️ BƯỚC 12 – Sửa SDC và chạy lại nhiều lần

Mở file SDC:

```bash
vi /group08/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/constraints/bound_flasher_gate.sdc
```

Thay đổi **3 giá trị** theo bảng thử nghiệm dưới đây:

| Lần thử | Period (ns) | Waveform | Delay (ns) | Tần số tương đương |
|---------|-------------|----------|------------|-------------------|
| 1 (mặc định) | `5.0` | `{0.0 2.5}` | `2.5` | 200 MHz |
| 2 | `4.0` | `{0.0 2.0}` | `2.0` | 250 MHz |
| 3 | `3.0` | `{0.0 1.5}` | `1.5` | 333 MHz |
| 4 | `2.0` | `{0.0 1.0}` | `1.0` | 500 MHz |
| 5 | `1.5` | `{0.0 0.75}` | `0.75` | 667 MHz |

Ví dụ khi thử với `period = 4.0 ns`:

```tcl
create_clock -name "clk" -add -period 4.0 -waveform {0.0 2.0} [get_ports clk]

set_input_delay  -clock [get_clocks clk] -add_delay 2.0 [get_ports flick]
set_input_delay  -clock [get_clocks clk] -add_delay 2.0 [get_ports rst_n]
set_output_delay -clock [get_clocks clk] -add_delay 2.0 [get_ports lamp ]
```

> 📌 **Quy tắc:** Waveform và delay luôn = **50% của period**.  
> Ví dụ: period `4.0` → waveform `{0.0 2.0}` → delay `2.0`.

Sau mỗi lần sửa SDC, **chạy lại toàn bộ Bước 5 → 7** và kiểm tra CPS trong `final_time.rpt`.

> 🎯 **Dừng lại** ở mức period nhỏ nhất mà **CPS vẫn >= 0** — đó chính là **tần số tối đa** của design.

---

---

# 📤 NỘP BÀI

> ⚠️ **Chú ý quan trọng:**
> - LAB1 (basic) và LAB3 (low-power) chỉ để **thực hành**, không cần nộp
> - Chỉ nộp **4 file kết quả** từ lần synthesis với **tần số tối đa**

| File cần nộp | Đường dẫn đầy đủ |
|---|---|
| **Netlist** | `/group08/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB1/outputs/bound_flasher_m.v` |
| **Area report** | `/group08/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB1/reports*/final_area.rpt` |
| **QoR report** | `/group08/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB1/reports*/final_qor.rpt` |
| **Timing report** | `/group08/vlsi/2313946/work/synthesis_env/Genus_BoundFlasher/LAB1/reports*/final_time.rpt` |

---

## 📌 TÓM TẮT TOÀN BỘ QUY TRÌNH

```
BƯỚC 1  → Copy kit Genus về synthesis_env/Genus_BoundFlasher/
BƯỚC 2  → Copy bound_flasher.v vào Genus_BoundFlasher/RTL/
BƯỚC 3  → Tạo file constraints/bound_flasher_gate.sdc
─────────────────────────────────────────────────────────
PHẦN 1: LAB1 – BASIC SYNTHESIS
BƯỚC 4  → Sửa LAB1/run.tcl (tên design, file RTL, SDC)
BƯỚC 5  → Source license + chạy: genus -f run.tcl | tee -i sync.log
BƯỚC 6  → Kiểm tra sync.log (không có Error)
BƯỚC 7  → Kiểm tra reports (CPS >= 0 là đạt)
BƯỚC 8  → (Tùy chọn) Tạo gui.tcl, mở GUI xem schematic
─────────────────────────────────────────────────────────
PHẦN 2: LAB3 – LOW-POWER SYNTHESIS
BƯỚC 9  → Sửa LAB3/run.tcl (thêm cấu hình low-power)
BƯỚC 10 → Source license + chạy: genus -f run.tcl | tee -i sync.log
BƯỚC 11 → Kiểm tra log và report
─────────────────────────────────────────────────────────
PHẦN 3: TÌM TẦN SỐ TỐI ĐA
BƯỚC 12 → Giảm period trong SDC → chạy lại LAB1 → kiểm tra CPS
          Lặp đến khi tìm được period nhỏ nhất mà CPS >= 0
─────────────────────────────────────────────────────────
NỘP BÀI → 4 file: netlist, area report, qor report, timing report
```

---

*Gặp lỗi ở bước nào, hãy đọc nội dung `sync.log` và tìm dòng có từ khóa `Error` để xác định nguyên nhân.*
