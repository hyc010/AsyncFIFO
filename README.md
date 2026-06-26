# AsyncFIFO

Asynchronous FIFO for educational purpose.

## Architecture

```
                    ┌──────────────┐
   wclk ───────────►│ wptr_full    │──► waddr ──┐
   winc ───────────►│ (binary+gray)│──► wptr ──┐│
   w_rst_n ────────►│              │            ││
                     └──────┬───────┘            ││
                            │                    ││
   ┌────────────────────────┘                    ││
   │        ┌──────────┐                         ││
   │  wptr ─►│sync_dff  │──► r2w_rptr ──────────►││
   │        │(2-stage) │                         ││
   │        └──────────┘                         ││
   │                                             ││
   │        ┌──────────┐                         ││
   └──rptr ─►│sync_dff  │──► w2r_wptr ──────────►││
            │(2-stage) │                         ││
            └──────────┘                         ││
                                                 ││
                     ┌──────────────┐            ││
   rclk ────────────►│ rptr_empty   │──► raddr ──┘│
   rinc ────────────►│ (binary+gray)│──► rptr ────┘
   r_rst_n ─────────►│              │
                     └──────────────┘

   ┌─────────────────────────────────────────────┐
   │              fifo_mem (SRAM)                 │
   │   wen ──► write port  │  ren ──► read port   │
   │   waddr ─► addr       │  raddr ─► addr        │
   │   wdata ─► data in    │  rdata ◄─ data out   │
   └─────────────────────────────────────────────┘
```

## Key Features

- **Dual-clock domain**: Independent write/read clocks (wclk/rclk)
- **Gray-code pointers**: Binary pointers for addressing, Gray code for CDC synchronization
- **2-stage synchronizers**: `sync_dff` module reusable for cross-clock handshaking
- **Optional fall-through**: Parameter `FALL_THROUGH` for 0-cycle read latency (default: classic 1-cycle)
- **Registered outputs**: `wptr`/`rptr` registered to eliminate combinational glitches going into synchronizers

## File List

| File | Description |
|------|-------------|
| `rtl/async_fifo.sv` | Top-level wrapper |
| `rtl/fifo_mem.sv` | Dual-port SRAM with optional fall-through |
| `rtl/wptr_full.sv` | Write pointer + full flag generation |
| `rtl/rptr_empty.sv` | Read pointer + empty flag generation |
| `rtl/sync_dff.sv` | Parameterizable multi-stage synchronizer |

## Modified (2026-06-21)

- `fifo_mem`: Added `rdata` reset, simplified interface (wen/ren), optional fall-through
- `rptr_empty`/`wptr_full`: Gray pointers now registered outputs
- Replaced dedicated `sync_r2w`/`sync_w2r` with reusable `sync_dff`
- Removed unused `dff.v`

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `DATA_WIDTH` | 8 | Data bus width |
| `ADDR_WIDTH` | 4 | Address width → FIFO depth = 2^ADDR_WIDTH |
| `FALL_THROUGH` | 0 | 0=1-cycle read latency, 1=write-through (immediate visibility) |

## Notes

- Both `w_rst_n` and `r_rst_n` should be asserted simultaneously during system reset.
- `FALL_THROUGH=1` uses cross-domain address comparison; safe for simulation, but production designs should synchronize `waddr` to `rclk` first.
