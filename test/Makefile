# ============================================================
#  Makefile for tt-i2c-master (TinyTapeout / OpenLane)
#  Usage:
#    make sim        → compile + run iverilog simulation
#    make waves      → open GTKWave
#    make lint       → run Verilator lint check
#    make clean      → remove build artifacts
#    make help       → show all targets
# ============================================================

# ── Paths ────────────────────────────────────────────────────
SRC_DIR    := src
TEST_DIR   := test
BUILD_DIR  := build

TOP_MODULE := tt_um_example
SRC_FILE   := $(SRC_DIR)/project.v
TB_FILE    := $(TEST_DIR)/tb.v
SIM_BIN    := $(BUILD_DIR)/sim
VCD_FILE   := $(BUILD_DIR)/tb.vcd

# ── Tools ────────────────────────────────────────────────────
IVERILOG   := iverilog
VVP        := vvp
GTKWAVE    := gtkwave
VERILATOR  := verilator

# ── Iverilog flags ───────────────────────────────────────────
IFLAGS     := -g2012 \
              -Wall \
              -Wno-timescale \
              -I$(SRC_DIR)

# ============================================================
#  Default target
# ============================================================
.PHONY: all
all: sim

# ============================================================
#  Create build directory
# ============================================================
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# ============================================================
#  Compile + Simulate
# ============================================================
.PHONY: sim
sim: $(BUILD_DIR)
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "  Compiling I2C Master..."
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	$(IVERILOG) $(IFLAGS) \
		-o $(SIM_BIN) \
		$(TB_FILE) $(SRC_FILE)
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "  Running simulation..."
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	cd $(BUILD_DIR) && $(VVP) sim
	@echo ""
	@echo "  ✅  Simulation complete → $(VCD_FILE)"
	@echo ""

# ============================================================
#  Open GTKWave
# ============================================================
.PHONY: waves
waves: $(VCD_FILE)
	@echo "  Opening GTKWave..."
	$(GTKWAVE) $(VCD_FILE) &

$(VCD_FILE):
	@echo "  ⚠  VCD not found. Run 'make sim' first."
	@exit 1

# ============================================================
#  Lint with Verilator
# ============================================================
.PHONY: lint
lint:
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "  Linting $(SRC_FILE)..."
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	$(VERILATOR) --lint-only \
		-Wall \
		--top-module $(TOP_MODULE) \
		$(SRC_FILE)
	@echo "  ✅  Lint passed"
	@echo ""

# ============================================================
#  Check tools are installed
# ============================================================
.PHONY: check-tools
check-tools:
	@echo "Checking required tools..."
	@command -v $(IVERILOG)  >/dev/null 2>&1 && echo "  ✅  iverilog  found" || echo "  ❌  iverilog  missing → sudo apt install iverilog"
	@command -v $(VVP)       >/dev/null 2>&1 && echo "  ✅  vvp       found" || echo "  ❌  vvp       missing → sudo apt install iverilog"
	@command -v $(GTKWAVE)   >/dev/null 2>&1 && echo "  ✅  gtkwave   found" || echo "  ❌  gtkwave   missing → sudo apt install gtkwave"
	@command -v $(VERILATOR) >/dev/null 2>&1 && echo "  ✅  verilator found" || echo "  ❌  verilator missing → sudo apt install verilator"

# ============================================================
#  Install tools (Ubuntu / Debian / WSL)
# ============================================================
.PHONY: install-tools
install-tools:
	@echo "  Installing simulation tools..."
	sudo apt update
	sudo apt install -y iverilog gtkwave verilator
	@echo "  ✅  Done"

# ============================================================
#  Show file sizes and stats
# ============================================================
.PHONY: stats
stats:
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "  Design Statistics"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "  Source lines:"
	@wc -l $(SRC_FILE)
	@echo "  Testbench lines:"
	@wc -l $(TB_FILE)
	@echo "  Module name:"
	@grep "^module" $(SRC_FILE)
	@echo ""

# ============================================================
#  Clean build artifacts
# ============================================================
.PHONY: clean
clean:
	@echo "  Cleaning build artifacts..."
	rm -rf $(BUILD_DIR)
	rm -f  *.vcd *.vvp sim
	@echo "  ✅  Clean complete"

# ============================================================
#  Full flow: lint → sim → waves
# ============================================================
.PHONY: flow
flow: lint sim waves
	@echo ""
	@echo "  ✅  Full flow complete"
	@echo ""

# ============================================================
#  Git shortcuts
# ============================================================
.PHONY: push
push:
	@echo "  Staging all changes..."
	git add src/project.v test/tb.v info.yaml src/config.json Makefile
	git status
	@read -p "  Commit message: " msg; \
	git commit -m "$$msg"
	git push origin main
	@echo "  ✅  Pushed → GitHub Actions will run automatically"

.PHONY: status
status:
	git status
	git log --oneline -5

# ============================================================
#  Help
# ============================================================
.PHONY: help
help:
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "   tt-i2c-master Makefile targets"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "  Simulation"
	@echo "    make sim           Compile + run iverilog simulation"
	@echo "    make waves         Open GTKWave waveform viewer"
	@echo "    make flow          lint → sim → waves in one shot"
	@echo ""
	@echo "  Verification"
	@echo "    make lint          Run Verilator lint check"
	@echo "    make stats         Show line counts and module info"
	@echo ""
	@echo "  Setup"
	@echo "    make check-tools   Check all tools are installed"
	@echo "    make install-tools Install iverilog/gtkwave/verilator"
	@echo ""
	@echo "  Git"
	@echo "    make push          Stage, commit, push to GitHub"
	@echo "    make status        git status + last 5 commits"
	@echo ""
	@echo "  Cleanup"
	@echo "    make clean         Remove build/ and .vcd files"
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
