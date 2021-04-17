import random


def generate(n, min=2, max=20, path="data.dzn"):
    with open(path, "w") as f:
        f.write("rectangles = [|\n")
        for _ in range(0, n):
            a = random.randrange(min, max + 1)
            b = random.randrange(min, max + 1)
            f.write(f"  {a}, {b} |\n")
        f.write("|]")


if __name__ == "__main__":
    generate(15, min=2, max=20)
