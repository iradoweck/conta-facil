import subprocess
import sys

def main():
    print("Running flutter build web...")
    proc = subprocess.Popen(
        ['flutter', 'build', 'web'],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        encoding='utf-8',
        errors='replace',
        shell=True
    )
    
    with open('clean_build_log.txt', 'w', encoding='utf-8') as f:
        for line in proc.stdout:
            f.write(line)
            # Only print actual errors to stdout so we can catch them cleanly
            if 'Error' in line or 'Exception' in line or 'Failed' in line:
                print("CRITICAL: " + line.strip())

    proc.wait()
    sys.exit(proc.returncode)

if __name__ == '__main__':
    main()
