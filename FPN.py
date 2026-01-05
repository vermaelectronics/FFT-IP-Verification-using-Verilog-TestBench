import numpy as np

# Parameters
N = 16                  # 8-point FFT
Fs = 100000000             # Sampling frequency
f = 12500000               # Signal frequency
Q = 7                  # Q7 format
scale = 2**Q

# Time index
n = np.arange(N)

# Floating-point signal
x_float = 0.08 * np.sin(2 * np.pi * f * n / Fs)

# Convert to fixed-point (8-bit signed)
x_fixed = np.round(x_float * scale).astype(np.int8)

# -------- PRINT --------
print("Fixed-point input samples:")
for i, val in enumerate(x_fixed):
    print(f"Sample {i}: {val}")

# -------- SAVE TO TXT (for Vivado) --------
np.savetxt(
    "fft_input.txt",
    x_fixed,
    fmt="%d"
)

print("\nSaved fixed-point input to fft_input.txt")
