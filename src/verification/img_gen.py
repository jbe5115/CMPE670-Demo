import random
import sys

def main():

    if len(sys.argv) < 2:
        num_rows = 64
        weight = 256
    else :
        # get payload dim
        num_rows = int(sys.argv[1])
        weight = int(sys.argv[2])

    if 4096 % num_rows != 0:
        print("Row size must be multiple of 4096")
        sys.exit(1)

    num_cols = int(4096 / num_rows)

    # file IO
    payload_file_name = f"payload.txt"
    with open(payload_file_name, 'w', encoding="utf-8") as file:
        for r in range (num_rows):
            for c in range(num_cols):
                byte = random.randrange(weight - 1)
                if byte < 16 :  #python mega doodoo
                    file.write('0')
                file.write(f'{byte:x} ')
            
            file.write('\n')
    file.close()


if __name__ == "__main__":
    main()