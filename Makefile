.PHONY: all build lean rust test clean serve crawl hf-push status

all: lean rust

# ── Lean4 proofs ─────────────────────────────────────────────────
lean:
	lake build

lean-run:
	./.lake/build/bin/solfunmeme-lean

lean-clean:
	lake clean

# ── Rust service (builds in ~/erdfa-publish) ─────────────────────
ERDFA := $(HOME)/erdfa-publish
BIN := $(ERDFA)/target/release/solfunmeme-service
BUDGET ?= 95000
RATE ?= 8

rust:
	cd $(ERDFA) && nix develop -c cargo build --release --bin solfunmeme-service

# ── Service management ───────────────────────────────────────────
serve:
	systemctl --user restart solfunmeme-service
	systemctl --user status solfunmeme-service --no-pager

stop:
	systemctl --user stop solfunmeme-service

status:
	@systemctl --user status solfunmeme-service --no-pager 2>/dev/null || true
	@systemctl --user status solfunmeme-crawl.timer --no-pager 2>/dev/null || true
	@curl -s http://127.0.0.1:7780/status 2>/dev/null || echo "service not running"

# ── Crawl ────────────────────────────────────────────────────────
crawl:
	$(BIN) batch-crawl --budget $(BUDGET) --rate $(RATE)

crawl-systemd:
	systemctl --user start solfunmeme-crawl.service
	journalctl --user -u solfunmeme-crawl -f --no-pager

timer:
	systemctl --user enable --now solfunmeme-crawl.timer

logs:
	journalctl --user -u solfunmeme-service -u solfunmeme-crawl -f --no-pager

# ── Python frontend ──────────────────────────────────────────────
py-run:
	python3 run_introspector.py

py-collect:
	python3 collect_s_io.py

# ── HuggingFace dataset ─────────────────────────────────────────
HF_DIR ?= $(HOME)/.solfunmeme/hf-dataset

hf-push:
	cd $(HF_DIR) && git add -A && git commit -m "batch-crawl update $$(date -I)" && git push

hf-status:
	@echo "TX files: $$(ls $(HF_DIR)/method_getTransaction_* 2>/dev/null | wc -l)"
	@echo "Sig files: $$(ls $(HF_DIR)/method_getSignaturesForAddress_* 2>/dev/null | wc -l)"
	@du -sh $(HF_DIR)

# ── Test & clean ─────────────────────────────────────────────────
test: lean
	cd $(ERDFA) && nix develop -c cargo test -- ingest

clean: lean-clean
