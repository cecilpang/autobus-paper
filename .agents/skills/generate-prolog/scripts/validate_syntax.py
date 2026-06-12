import subprocess
import sys
import os

def validate_prolog(file_path):
    if not os.path.exists(file_path):
        print(f"Error: File {file_path} not found.")
        return False
    
    try:
        # swipl -c file.pl runs the compiler check
        result = subprocess.run(
            ['swipl', '-c', file_path],
            capture_output=True,
            text=True
        )
        
        if result.returncode == 0:
            print(f"Syntax Check Passed: {file_path}")
            return True
        else:
            print(f"Syntax Check Failed: {file_path}")
            print("Errors:")
            print(result.stderr)
            return False
            
    except FileNotFoundError:
        print("Error: swipl (SWI-Prolog) not found in PATH.")
        return False

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python validate_syntax.py <file.pl>")
        sys.exit(1)
        
    success = validate_prolog(sys.argv[1])
    sys.exit(0 if success else 1)
