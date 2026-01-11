import os
import sys
import argparse
import subprocess
from pathlib import Path


class scolor:
    NORMAL  = '\033[0m'
    PASS    = '\033[32m'
    SKIP    = '\033[33m'
    FAIL    = '\033[31m'


prg_index = 0
ref_index = 1
run_index = 2


unit_test = [
    ["riscv_test_suite/test_programs/add-01.mem",             "riscv_test_suite/signatures/add-01.signature",              True,   ],
    ["riscv_test_suite/test_programs/addi-01.mem",            "riscv_test_suite/signatures/addi-01.signature",             True,   ],
    ["riscv_test_suite/test_programs/and-01.mem",             "riscv_test_suite/signatures/and-01.signature",              True,   ],
    ["riscv_test_suite/test_programs/andi-01.mem",            "riscv_test_suite/signatures/andi-01.signature",             True,   ],
    ["riscv_test_suite/test_programs/auipc-01.mem",           "riscv_test_suite/signatures/auipc-01.signature",            True,   ],
    ["riscv_test_suite/test_programs/beq-01.mem",             "riscv_test_suite/signatures/beq-01.signature",              True,   ],
    ["riscv_test_suite/test_programs/bge-01.mem",             "riscv_test_suite/signatures/bge-01.signature",              True,   ],
    ["riscv_test_suite/test_programs/bgeu-01.mem",            "riscv_test_suite/signatures/bgeu-01.signature",             True,   ],
    ["riscv_test_suite/test_programs/blt-01.mem",             "riscv_test_suite/signatures/blt-01.signature",              True,   ],
    ["riscv_test_suite/test_programs/bltu-01.mem",            "riscv_test_suite/signatures/bltu-01.signature",             True,   ],
    ["riscv_test_suite/test_programs/bne-01.mem",             "riscv_test_suite/signatures/bne-01.signature",              True,   ],
    ["riscv_test_suite/test_programs/ebreak.mem",             "riscv_test_suite/signatures/ebreak.signature",              True,   ],
    ["riscv_test_suite/test_programs/ecall.mem",              "riscv_test_suite/signatures/ecall.signature",               True,   ],
    ["riscv_test_suite/test_programs/fence-01.mem",           "riscv_test_suite/signatures/fence-01.signature",            True,   ],
    ["riscv_test_suite/test_programs/jal-01.mem",             "riscv_test_suite/signatures/jal-01.signature",              True,   ],
    ["riscv_test_suite/test_programs/jalr-01.mem",            "riscv_test_suite/signatures/jalr-01.signature",             True,   ],
    ["riscv_test_suite/test_programs/lb-align-01.mem",        "riscv_test_suite/signatures/lb-align-01.signature",         True,   ],
    ["riscv_test_suite/test_programs/lbu-align-01.mem",       "riscv_test_suite/signatures/lbu-align-01.signature",        True,   ],
    ["riscv_test_suite/test_programs/lh-align-01.mem",        "riscv_test_suite/signatures/lh-align-01.signature",         True,   ],
    ["riscv_test_suite/test_programs/lhu-align-01.mem",       "riscv_test_suite/signatures/lhu-align-01.signature",        True,   ],
    ["riscv_test_suite/test_programs/lui-01.mem",             "riscv_test_suite/signatures/lui-01.signature",              True,   ],
    ["riscv_test_suite/test_programs/lw-align-01.mem",        "riscv_test_suite/signatures/lw-align-01.signature",         True,   ],
    ["riscv_test_suite/test_programs/misalign-beq-01.mem",    "riscv_test_suite/signatures/misalign-beq-01.signature",     True,   ],
    ["riscv_test_suite/test_programs/misalign-bge-01.mem",    "riscv_test_suite/signatures/misalign-bge-01.signature",     True,   ],
    ["riscv_test_suite/test_programs/misalign-bgeu-01.mem",   "riscv_test_suite/signatures/misalign-bgeu-01.signature",    True,   ],
    ["riscv_test_suite/test_programs/misalign-blt-01.mem",    "riscv_test_suite/signatures/misalign-blt-01.signature",     True,   ],
    ["riscv_test_suite/test_programs/misalign-bltu-01.mem",   "riscv_test_suite/signatures/misalign-bltu-01.signature",    True,   ],
    ["riscv_test_suite/test_programs/misalign-bne-01.mem",    "riscv_test_suite/signatures/misalign-bne-01.signature",     True,   ],
    ["riscv_test_suite/test_programs/misalign-jal-01.mem",    "riscv_test_suite/signatures/misalign-jal-01.signature",     True,   ],
    ["riscv_test_suite/test_programs/misalign-lh-01.mem",     "riscv_test_suite/signatures/misalign-lh-01.signature",      True,   ],
    ["riscv_test_suite/test_programs/misalign-lhu-01.mem",    "riscv_test_suite/signatures/misalign-lhu-01.signature",     True,   ],
    ["riscv_test_suite/test_programs/misalign-lw-01.mem",     "riscv_test_suite/signatures/misalign-lw-01.signature",      True,   ],
    ["riscv_test_suite/test_programs/misalign-sh-01.mem",     "riscv_test_suite/signatures/misalign-sh-01.signature",      True,   ],
    ["riscv_test_suite/test_programs/misalign-sw-01.mem",     "riscv_test_suite/signatures/misalign-sw-01.signature",      True,   ],
    ["riscv_test_suite/test_programs/misalign1-jalr-01.mem",  "riscv_test_suite/signatures/misalign1-jalr-01.signature",   True,   ],
    ["riscv_test_suite/test_programs/misalign2-jalr-01.mem",  "riscv_test_suite/signatures/misalign2-jalr-01.signature",   True,   ],
    ["riscv_test_suite/test_programs/mul-01.mem",             "riscv_test_suite/signatures/mul-01.signature",              True,   ],
    ["riscv_test_suite/test_programs/mulh-01.mem",            "riscv_test_suite/signatures/mulh-01.signature",             True,   ],
    ["riscv_test_suite/test_programs/mulhu-01.mem",           "riscv_test_suite/signatures/mulhu-01.signature",            True,   ],
    ["riscv_test_suite/test_programs/mulhsu-01.mem",          "riscv_test_suite/signatures/mulhsu-01.signature",           True,   ],
    ["riscv_test_suite/test_programs/or-01.mem",              "riscv_test_suite/signatures/or-01.signature",               True,   ],
    ["riscv_test_suite/test_programs/ori-01.mem",             "riscv_test_suite/signatures/ori-01.signature",              True,   ],
    ["riscv_test_suite/test_programs/sb-align-01.mem",        "riscv_test_suite/signatures/sb-align-01.signature",         True,   ],
    ["riscv_test_suite/test_programs/sh-align-01.mem",        "riscv_test_suite/signatures/sh-align-01.signature",         True,   ],
    ["riscv_test_suite/test_programs/sll-01.mem",             "riscv_test_suite/signatures/sll-01.signature",              True,   ],
    ["riscv_test_suite/test_programs/slli-01.mem",            "riscv_test_suite/signatures/slli-01.signature",             True,   ],
    ["riscv_test_suite/test_programs/slt-01.mem",             "riscv_test_suite/signatures/slt-01.signature",              True,   ],
    ["riscv_test_suite/test_programs/slti-01.mem",            "riscv_test_suite/signatures/slti-01.signature",             True,   ],
    ["riscv_test_suite/test_programs/sltiu-01.mem",           "riscv_test_suite/signatures/sltiu-01.signature",            True,   ],
    ["riscv_test_suite/test_programs/sltu-01.mem",            "riscv_test_suite/signatures/sltu-01.signature",             True,   ],
    ["riscv_test_suite/test_programs/sra-01.mem",             "riscv_test_suite/signatures/sra-01.signature",              True,   ],
    ["riscv_test_suite/test_programs/srai-01.mem",            "riscv_test_suite/signatures/srai-01.signature",             True,   ],
    ["riscv_test_suite/test_programs/srl-01.mem",             "riscv_test_suite/signatures/srl-01.signature",              True,   ],
    ["riscv_test_suite/test_programs/srli-01.mem",            "riscv_test_suite/signatures/srli-01.signature",             True,   ],
    ["riscv_test_suite/test_programs/sub-01.mem",             "riscv_test_suite/signatures/sub-01.signature",              True,   ],
    ["riscv_test_suite/test_programs/sw-align-01.mem",        "riscv_test_suite/signatures/sw-align-01.signature",         True,   ],
    ["riscv_test_suite/test_programs/xor-01.mem",             "riscv_test_suite/signatures/xor-01.signature",              True,   ],
    ["riscv_test_suite/test_programs/xori-01.mem",            "riscv_test_suite/signatures/xori-01.signature",             True,   ],
]

expected_to_fail = [
    "riscv_test_suite/test_programs/misalign-beq-01.mem"    ,
    "riscv_test_suite/test_programs/misalign-bge-01.mem"    ,
    "riscv_test_suite/test_programs/misalign-bgeu-01.mem"   ,
    "riscv_test_suite/test_programs/misalign-blt-01.mem"    ,
    "riscv_test_suite/test_programs/misalign-bltu-01.mem"   ,
    "riscv_test_suite/test_programs/misalign-bne-01.mem"    ,
    "riscv_test_suite/test_programs/misalign-jal-01.mem"    ,
    "riscv_test_suite/test_programs/misalign2-jalr-01.mem"
]

def print_status(clr: scolor, text: str):
    if clr == scolor.NORMAL:
        print(f'{clr}{text}')

    if clr == scolor.PASS:
        print(f'{scolor.NORMAL}TEST {clr}PASS {scolor.NORMAL}: {text}')

    if clr == scolor.SKIP:
        print(f'{scolor.NORMAL}TEST {clr}SKIP {scolor.NORMAL}: {text}')

    if clr == scolor.FAIL:
        print(f'{scolor.NORMAL}TEST {clr}FAIL {scolor.NORMAL}: {text}')


def check_file(path: str):
    if not os.path.isfile(path):
        print_status(scolor.NORMAL, f'No such file or directory: {path}')
        return False
    return True


def run_sim(sim_path: str, prog_dir: str, prog_name: str, dump_dir: str, wave: bool):
    args = [f'{sim_path}',
            f'--ram-init-h32={prog_dir}/{prog_name}',
            f'--ram-dump-h32={dump_dir}/{prog_name}',
            f'--cycles={500000}',
            f'--wr-addr={0x00000000}']

    if wave:
        args.append(f'--out-wave={dump_dir}/{prog_name}.fst')

    with open(f'{dump_dir}/{prog_name}.log', 'w') as fd:
        subprocess.run(args, stdout=fd)


def compare_dump(ref: str, dut: str):
    with open(ref, mode='r', encoding='utf-8') as ref_file:
        with open(dut, mode='r', encoding='utf-8') as dut_file:
            line = 0
            while True:
                line += 1

                str_ref = ref_file.readline()
                str_dut = dut_file.readline()

                if not str_ref or not str_dut:
                    return (True, line, 0, 0)

                int_ref = int(str_ref, 16)
                int_dut = int(str_dut, 16)

                if int_ref != int_dut:
                    return (False, line, int_ref, int_dut)


def main(argv=None):
    if argv is None:
        argv = sys.argv[1:]

    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('--sim',
                        type=str,
                        default='/workspaces/rvx/simulator/build/rvx_simulator',
                        help='Path to the simulator')

    parser.add_argument('--dump',
                        type=str,
                        default='test_output',
                        help='Dump directory')

    parser.add_argument('--wave',
                        action='store_true',
                        help='Enable gen wave *.fst')

    args = parser.parse_args(argv)

    if not check_file(args.sim):
        print_status(scolor.NORMAL, f'Please build file: {args.sim}')
        return

    if not os.path.exists(args.dump):
        os.makedirs(args.dump)

    passed = 0
    skipped = 0
    failed = 0

    for item in unit_test:
        prog_path = item[prg_index]
        ref_path = item[ref_index]
        is_run = item[run_index]

        if not check_file(prog_path):
            continue

        if not is_run:
            skipped += 1
            print_status(scolor.SKIP, prog_path)
            continue

        prog_dir = Path(prog_path).parent
        prog_name = Path(prog_path).name
        dump_path = f'{args.dump}/{prog_name}'
        run_sim(sim_path=args.sim,
                prog_dir=prog_dir,
                prog_name=prog_name,
                dump_dir=args.dump,
                wave=args.wave)

        if not check_file(ref_path):
            continue

        if not check_file(dump_path):
            failed +=1
            print_status(scolor.FAIL, prog_path)
            print_status(scolor.NORMAL, f'-- Dump file not generated: {dump_path}')
            continue

        result, line, ref, dut = compare_dump(ref=ref_path, dut=dump_path)

        if not result and prog_path not in expected_to_fail:
            failed +=1
            print_status(scolor.FAIL, prog_path)
            print_status(scolor.NORMAL, f'-- Signature at line {line} differs from golden reference.')
            print_status(scolor.NORMAL, f'-- Signature: {hex(dut)}. Golden reference: {hex(ref)}')
        else:
            passed += 1
            print_status(scolor.PASS, prog_path)

    print_status(scolor.NORMAL, f'Total: passed {passed}, skipped {skipped}, failed {failed}')

    if passed == len(unit_test):
      print("------------------------------------------------------------------------------------------")
      print("RVX Core IP passed ALL unit tests from RISC-V Architectural Test")
      print("------------------------------------------------------------------------------------------")


if __name__ == "__main__":
    main()
