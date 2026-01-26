import os, sys, argparse, subprocess, shutil, pathlib
from enum import Enum

# These test programs are expected to fail due to misaligned accesses.
# RVX supports only aligned memory accesses.
expected_to_fail = [
    "riscv_test_suite/test_programs/misalign-beq-01.mem",
    "riscv_test_suite/test_programs/misalign-bge-01.mem",
    "riscv_test_suite/test_programs/misalign-bgeu-01.mem",
    "riscv_test_suite/test_programs/misalign-blt-01.mem",
    "riscv_test_suite/test_programs/misalign-bltu-01.mem",
    "riscv_test_suite/test_programs/misalign-bne-01.mem",
    "riscv_test_suite/test_programs/misalign-jal-01.mem",
    "riscv_test_suite/test_programs/misalign2-jalr-01.mem"
]

# These tests are ignored because RVX only multiplication (Zmmul extension).
# Division and remainder instructions are not supported.
ignored_tests = [
    "riscv_test_suite/test_programs/div-01.mem",
    "riscv_test_suite/test_programs/divu-01.mem",
    "riscv_test_suite/test_programs/rem-01.mem",
    "riscv_test_suite/test_programs/remu-01.mem"
]

def discover_tests():
    """Discover test programs and their corresponding signatures."""
    test_programs_dir = pathlib.Path('riscv_test_suite/test_programs')
    signatures_dir = pathlib.Path('riscv_test_suite/signatures')

    tests = []
    for mem_file in sorted(test_programs_dir.glob('**/*.mem')):
        test_name = mem_file.stem
        signature_file = signatures_dir / f'{test_name}.signature'
        tests.append([str(mem_file), str(signature_file)])

    return tests

def log(text: str):
    print(f'\033[0m{text}')

def log_passed(text: str):
    print(f'\033[32mPASSED  \033[0m{text}')

def log_failed(text: str):
    print(f'\033[31mFAILED  \033[0m{text}')

def file_exists(path: str):
    """Check if a file exists."""
    if not os.path.isfile(path):
        log(f'No such file or directory: {path}')
        return False
    return True

def run_simulator(simulator_path: str, test_program: str, output_dir: str):
    """Run the RVX simulator on a given test program. Returns True if execution was successful, False otherwise."""
    test_name = pathlib.Path(test_program).stem
    args = [f'{simulator_path}',
            f'{test_program}',
            f'--signature={output_dir}/{test_name}.signature',
            f'--max-cycles={500000}',
            '--verbose']
    with open(f'{output_dir}/{test_name}.log', 'w') as fd:
      return True if subprocess.run(args, stdout=fd).returncode == 0 else False

def compare_signature(golden_reference: str, output_signature: str):
    """Compare the output signature with the golden reference signature."""
    try:
        with open(golden_reference, mode='r', encoding='utf-8') as gold_file:
            with open(output_signature, mode='r', encoding='utf-8') as sig_file:
                gold_lines = gold_file.readlines()
                sig_lines = sig_file.readlines()
                for line_num, (gold_line, sig_line) in enumerate(zip(gold_lines, sig_lines), start=1):
                    if gold_line.strip() != sig_line.strip():
                        return False, line_num, gold_line.strip(), sig_line.strip()
        return True, None, None, None
    except:
        return False, None, None, None

def main(argv = None):
    """Run RISC-V compliance tests on RVX simulator."""

    # Argument parsing
    argv = sys.argv[1:] if argv is None else argv
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('--simulator',
                        type=str,
                        default='../../simulator/build/rvx_simulator',
                        help='Path to RVX simulator')
    parser.add_argument('--output-dir',
                        type=str,
                        default='test_output',
                        help='Path to test output directory (will be created if does not exist)')
    args = parser.parse_args(argv)

    # Check simulator exists
    if not file_exists(args.simulator):
        log(f'RVX Simulator not found: {args.simulator}')
        log('Please build the simulator before running the tests.')

    # Discover tests
    all_tests = discover_tests()

    # Prepare output directory
    if os.path.exists(args.output_dir):
        log(f'\nRemoving existing test output directory: {args.output_dir}')
        shutil.rmtree(args.output_dir)
    if not os.path.exists(args.output_dir):
        os.makedirs(args.output_dir)

    passed_count = 0
    skipped_count = 0
    failed_count = 0

    # Run tests
    log(f'\nRunning {len(all_tests) - len(ignored_tests)} RISC-V compliance tests on RVX simulator...\n')
    for test_program, test_signature in all_tests:

        if test_program in ignored_tests:
            continue

        if not file_exists(test_program) or not file_exists(test_signature):
            failed_count += 1
            log_failed(f'{test_program}')
            log('-- Test program or signature file not found.')
            continue

        run_status = run_simulator(
                simulator_path=args.simulator,
                test_program=test_program,
                output_dir=args.output_dir)

        if not run_status:
            failed_count +=1
            log_failed(f'{test_program}')
            log('-- Simulator returned a non-zero exit code.')
            continue

        output_file = os.path.join(args.output_dir, f'{pathlib.Path(test_program).stem}.signature')

        if not file_exists(output_file):
            failed_count += 1
            log_failed(f'{test_program}')
            continue

        if not file_exists(output_file):
            failed_count += 1
            log_failed(f'{test_program}')
            log(f'-- Test output file not found: {output_file}')
            continue

        result, diff_line, gold_line, sig_line = compare_signature(golden_reference=test_signature,
                                                                   output_signature=output_file)

        if not result and test_program not in expected_to_fail:
            failed_count += 1
            log_failed(f'{test_program}')
            log(f'-- Signature at line {diff_line} differs from golden reference.')
            log(f'-- Signature: {hex(sig_line)}. Golden reference: {hex(gold_line)}')
        else:
            passed_count += 1
            log_passed(f'{test_program}')

    log(f'\nTotals:\n\n  Passed: {passed_count}\n  Failed: {failed_count}')

    if passed_count == 58: # Yes, hardcoded.
                           # This is the exact number of tests that should pass.
                           # discover_tests() may find less or more tests depending on
                           # the files present in the riscv_test_suite directory,
                           # so hardcoding the expected number ensures correctness.
                           # If more tests are added in the future, this number must be updated.
      print("\nRVX Processor Core passed all RISC-V Test Suite tests.\n")
    else:
      print("\n[ERROR] RVX Processor Core failed on RISC-V Test Suite tests.\n")

if __name__ == "__main__":
    main()
