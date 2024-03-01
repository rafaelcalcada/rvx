# SoC IP Simulations

## How do I run the simulation?

### Using Verilator

To run the simulation using Verilator do:

```bash
cd verilator
make # build soc verilator
make run # running the simulation
```

For the available options run:

```bash
cd obj_dir
soc_sim --help
```

> Verilator version 5.0 or higher is required.


