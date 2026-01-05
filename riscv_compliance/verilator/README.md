
## Example of launching RVX using Verilator

In some cases it is convenient to write and run testbench using Verilator tools.

For convenient operation, an execution shell has been created with the ability to display messages on the command line or output a RAM memory dump.


Available commands:

  - **--out-wave**

    If specified, saves the trace file in `*.fst` format. By default, no tracing is performed.

  - **--ram-init-h32**

    If specified, initializes ram in the format `$readmemh`. By default, no initializes ram.

  - **--ram-dump-h32**

    If specified, writed a ram dump in `$readmemh` format after `--wr-addr` is detected. By default, no write ram.

  - **--cycles**

    The maximum number of `clock` cycles after which execution ends. The default cycles is 500000.

  - **--wr-addr**

    When a record is found at this address, execution ends. The default address is 0x00001000.

  - **--host-out**

    Any entries to this address will print the messages as terminal output. The default address is 0x00000000, which means no messages.

  - **--quiet**

    Disable all messages.

  - **--log-out**

    Output file log, not specified by default.

  - **--log-level**

    Log level available: `DEBUG, INFO, WARNING, ERROR, CRITICAL, QUIET`. Default log level `DEBUG`.


> Documentation for installing `Verilator` can be found here: [Installation](https://veripool.org/guide/latest/install.html)

> Was tested on version `Verilator 4.214`